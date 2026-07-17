import re
import io
import logging
from datetime import datetime, timedelta
from sqlalchemy import text
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.db.base_class import Base
from app.models.customer import Customer
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.org import Region
from app.models.users import User
from app.models.pos import POSMachine
from app.models.transaction import TransactionLog
from app.models.config import ProviderConfig
from app.core.auth_utils import hash_password

logger = logging.getLogger("app.maintenance")

def parse_sql_content(content: str):
    """优化后的逐行解析"""
    results = []
    val_marker = "VALUES ("
    start_idx = content.find(val_marker)
    if start_idx == -1: return []

    data_part = content[start_idx + len(val_marker):].strip()
    if data_part.endswith(";"): data_part = data_part[:-1]
    if data_part.endswith(")"): data_part = data_part[:-1]

    rows = data_part.split("),(")
    for row in rows:
        items = re.findall(r"(?:'((?:''|[^'])*)'|([^,]+))", row)
        cleaned = [i[0].replace("''", "'") if i[0] else (i[1].strip() if i[1] else "NULL") for i in items]
        results.append(cleaned)
    return results

def run_legacy_sql_migration(files_dict: dict):
    """
    执行 SQL 全量迁移 (完全同步 migrate_real_data.py 的业务逻辑)
    """
    db = SessionLocal()
    try:
        logger.info("Starting legacy migration: Cleaning and patching...")

        # 1. 清理业务表 (保留 Regions)
        db.execute(text("DELETE FROM transaction_logs;"))
        db.execute(text("DELETE FROM customers;"))
        db.execute(text("DELETE FROM cards;"))
        db.execute(text("DELETE FROM solar_units;"))
        db.execute(text("DELETE FROM pos_machines;"))
        db.execute(text("DELETE FROM users WHERE role NOT IN (0, 1);"))
        db.commit()

        # 2. 关键补丁：修复卡号唯一索引 (允许空卡号共存)
        try:
            db.execute(text('DROP INDEX IF EXISTS "ix_cards_card_number" CASCADE;'))
            db.execute(text('ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_card_number_key CASCADE;'))
            db.execute(text("CREATE UNIQUE INDEX ix_cards_card_number ON cards (card_number) WHERE card_number != '';"))
            db.commit()
        except: db.rollback()

        # 3. 根节点与管理员初始化
        root = db.query(Region).filter(Region.level == 0).first()
        if not root:
            root = Region(name="QUEZELCO-1", level=0)
            db.add(root); db.flush()

        # 确保 Fina 账号存在
        if not db.query(User).filter(User.username == "fina").first():
            db.add(User(
                username="fina", password_hash=hash_password("test123"),
                role=3, mobile="09222222222", first_name="Finance", last_name="Manager",
                region_id=root.id, is_active=True
            ))

        db.execute(text(f"UPDATE users SET region_id = {root.id} WHERE role IN (0, 1);"))
        db.commit()

        # 4. 建立区域查找索引
        region_name_map = {r.name.lower(): r.id for r in db.query(Region).all()}

        # 5. POS 资产
        if "shsv1_ic_dev_pos.sql" in files_dict:
            pos_raw = parse_sql_content(files_dict["shsv1_ic_dev_pos.sql"])
            for row in pos_raw:
                if len(row) < 4: continue
                sn = row[3]
                if sn and sn != "NULL":
                    db.add(POSMachine(pos_sn=sn, status=1 if row[5] == '1' else 0, created_at=datetime.now()))
            db.flush()

        # 6. 客户迁移
        customer_map = {}
        if "shsv1_ic_clients.sql" in files_dict:
            clients_raw = parse_sql_content(files_dict["shsv1_ic_clients.sql"])
            for row in clients_raw:
                if len(row) < 13: continue
                c_uuid = row[2]
                if not c_uuid or c_uuid == "NULL": continue
                r_id = region_name_map.get(row[11].lower(), region_name_map.get(row[12].lower(), root.id))
                db.add(Customer(
                    uuid=c_uuid, first_name=row[3], last_name=row[4],
                    gender="female" if row[5] == '1' else "male",
                    mobile=row[7][:20] if row[7] != "NULL" else f"09{c_uuid}",
                    region_id=r_id, status=1, created_at=datetime.now()
                ))
                customer_map[c_uuid] = True
            db.flush()

        # 7. 财务流水
        if "shsv1_ic_fin_accounting.sql" in files_dict:
            accounting_raw = parse_sql_content(files_dict["shsv1_ic_fin_accounting.sql"])
            count = 0
            for row in accounting_raw:
                if len(row) < 11: continue
                if row[4] in customer_map:
                    db.add(TransactionLog(
                        transaction_id=row[1], customer_uuid=row[4],
                        amount=float(row[10]), days=int(row[14]) if row[14] != "NULL" else 0,
                        transaction_time=datetime.strptime(row[12], '%Y-%m-%d %H:%M:%S'),
                        action_type="RECHARGE", operator_username=row[18] if len(row)>18 else "legacy",
                        pos_sn=row[17] if len(row)>17 else "LEGACY"
                    ))
                    count += 1
                    if count % 500 == 0: db.commit()
            db.commit()

        # 8. SHS 设备套件拼装
        if "shsv1_ic_dev_equipment.sql" in files_dict:
            all_parts_raw = parse_sql_content(files_dict["shsv1_ic_dev_equipment.sql"])
            owned_units = {}
            if "shsv1_ic_clients_equipment.sql" in files_dict:
                for b in parse_sql_content(files_dict["shsv1_ic_clients_equipment.sql"]):
                    if len(b) > 6: owned_units[b[6]] = b[3]

            for i in range(0, len(all_parts_raw), 5):
                chunk = all_parts_raw[i:i+5]
                p_map = {int(p[4]): p[5] for p in chunk if len(p)>5}
                mid = p_map.get(1)
                if mid:
                    owner = owned_units.get(mid)
                    db.add(SolarUnit(
                        shs_machine_id=mid, solar_equipment_id=p_map.get(2,f"P{mid}"),
                        radio_id=p_map.get(3,f"R{mid}"), flashlight_id=p_map.get(4,f"F{mid}"),
                        led_light_id=p_map.get(5,f"L{mid}"),
                        customer_uuid=owner if owner in customer_map else None,
                        shs_status=1 if owner in customer_map else 0, bound_at=datetime.now()
                    ))
            db.flush()

        # 9. IC 卡与到期时间同步
        if "shsv1_ic_dev_card.sql" in files_dict:
            master_cards = {}
            for row in parse_sql_content(files_dict["shsv1_ic_dev_card.sql"]):
                if len(row) < 3: continue
                u_id = row[2].upper()
                c_obj = Card(card_uuid=u_id, card_number="", status=0, created_at=datetime.now())
                db.add(c_obj); master_cards[u_id] = c_obj
            db.flush()

            if "shsv1_ic_clients_card.sql" in files_dict:
                for row in parse_sql_content(files_dict["shsv1_ic_clients_card.sql"]):
                    cid, uid = row[1], row[4].upper()
                    if uid in master_cards and cid in customer_map:
                        master_cards[uid].customer_uuid, master_cards[uid].status = cid, 1
                        master_cards[uid].bound_at = datetime.now()
                        if len(row) > 9 and row[9] != "NULL":
                            try:
                                base = datetime.strptime(row[9], '%Y-%m-%d %H:%M:%S')
                                db.execute(text("UPDATE customers SET expiry_time = :exp WHERE uuid = :uid"),
                                          {"exp": base + timedelta(days=int(row[6])), "uid": cid})
                            except: pass
            db.commit()

        # 10. 同步序列
        for table in ["users", "customers", "cards", "solar_units", "transaction_logs", "regions", "pos_machines"]:
            try:
                max_id = db.execute(text(f"SELECT MAX(id) FROM {table}")).scalar() or 1
                seq = db.execute(text(f"SELECT pg_get_serial_sequence('{table}', 'id')")).scalar()
                if seq: db.execute(text(f"SELECT setval('{seq}', {max_id}, true)"))
            except: pass
        db.commit()

        return True, "Migration successful"
    except Exception as e:
        logger.error(f"Migration error: {str(e)}")
        db.rollback()
        return False, str(e)
    finally:
        db.close()
