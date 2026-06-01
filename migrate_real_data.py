import re
import os
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db.session import SessionLocal, engine
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

# SQL 文件路径
SQL_PATH = "/Users/michael/dev/shs/mysqlexport"

def parse_sql_values(file_name):
    full_path = os.path.join(SQL_PATH, file_name)
    if not os.path.exists(full_path): return []
    results = []
    try:
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
            matches = re.findall(r"VALUES\s*(.*?);", content, re.DOTALL)
            if not matches: return []
            for values_part in matches:
                rows = re.split(r"\s*\)\s*,\s*\(\s*", values_part.strip())
                for row in rows:
                    row = row.strip().lstrip('(').rstrip(')')
                    items = re.findall(r"(?:'((?:''|[^'])*)'|([^,]+))", row)
                    cleaned = [i[0].replace("''", "'") if i[0] else (i[1].strip() if i[1] else "NULL") for i in items]
                    results.append(cleaned)
    except: pass
    return results

def migrate():
    db = SessionLocal()
    print("🔥 正在执行【全量迁移 + POS资产导入】脚本...")

    try:
        # 0. 级联重置
        print("Step 0: 彻底重置结构...")
        for table in reversed(Base.metadata.sorted_tables):
            db.execute(text(f"DROP TABLE IF EXISTS {table.name} CASCADE"))
        db.commit()
        Base.metadata.create_all(bind=engine)
        
        # 修正：将卡号的唯一索引改为“部分唯一索引”(Partial Unique Index)
        # 从而允许多张卡片的 card_number 都为 "" (空字符串) 而不触发唯一约束冲突
        try:
            db.execute(text('DROP INDEX IF EXISTS "ix_cards_card_number" CASCADE;'))
            db.execute(text('ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_card_number_key CASCADE;'))
            db.execute(text("CREATE UNIQUE INDEX ix_cards_card_number ON cards (card_number) WHERE card_number != '';"))
            db.commit()
        except Exception as e:
            db.rollback()

        # 1. 重建 QUEZELCO-1 组织架构
        print("Step 1: 重建组织架构...")
        root = Region(name="QUEZELCO-1", level=0)
        db.add(root); db.flush()
        db.add(ProviderConfig(name="QUEZELCO-1 SHS", tin="12345678", is_initialized=True))
        
        mapping = {
            "Tagkawayan": ["Del Gallego", "Guinyangan", "Calauag", "Lopez"],
            "Gumaca": ["Plaridel", "Atimonan"],
            "Alabat": ["Quezon-Quezon", "Perez"],
            "Agdangan": ["Padre Burgos", "Unisan", "Pitogo"],
            "Macalelon": ["Gen. Luna", "Catanauan", "Mulanay"],
            "San Narciso": ["Buenavista"],
            "San Francisco": ["San Andres"]
        }
        region_cache = {}
        for town_name, brgys in mapping.items():
            t_node = Region(name=town_name, level=1, parent_id=root.id, daily_rate=7.0)
            db.add(t_node); db.flush()
            region_cache[town_name.lower()] = t_node.id
            for b_name in brgys:
                b_node = Region(name=b_name, level=2, parent_id=t_node.id, daily_rate=7.0)
                db.add(b_node); db.flush()
                region_cache[b_name.lower()] = b_node.id

        # 2. 迁移 POS 资产 (核心新增)
        print("Step 2: 导入 POS 机资产底账...")
        pos_raw = parse_sql_values("shsv1_ic_dev_pos.sql")
        pos_count = 0
        for row in pos_raw:
            try:
                # 3: terminal_serial (SN), 5: active
                sn = row[3]
                if not sn or sn == "NULL": continue
                status = 1 if row[5] == '1' else 0
                db.add(POSMachine(pos_sn=sn, status=status, created_at=datetime.now()))
                pos_count += 1
            except: continue
        db.flush()

        # 3. 迁移客户并建立 ID 转换桥梁
        print("Step 3: 迁移客户资料...")
        id_bridge = {} 
        clients_raw = parse_sql_values("shsv1_ic_clients.sql")
        customer_map = {} 
        for row in clients_raw:
            try:
                long_id, c_uuid = row[0], row[2]
                if not c_uuid or c_uuid == "NULL": continue
                r_id = region_cache.get(row[11].lower(), region_cache.get(row[12].lower(), region_cache.get("gumaca")))
                cust = Customer(
                    uuid=c_uuid, first_name=row[3], last_name=row[4],
                    gender="female" if row[5] == '1' else "male",
                    mobile=row[7][:20] if row[7] != "NULL" else f"09{c_uuid}",
                    region_id=r_id, status=1, created_at=datetime.now()
                )
                db.add(cust)
                customer_map[c_uuid] = True
                id_bridge[long_id] = c_uuid
            except: continue
        db.flush()

        # 4. 迁移财务流水
        print("Step 4: 搬迁财务账本...")
        accounting_raw = parse_sql_values("shsv1_ic_fin_accounting.sql")
        tx_count = 0
        for row in accounting_raw:
            try:
                c_id = row[4]
                if c_id in customer_map:
                    db.add(TransactionLog(
                        transaction_id=row[1], customer_uuid=c_id,
                        amount=float(row[10]), days=int(row[14]) if row[14] != "NULL" else 0,
                        transaction_time=datetime.strptime(row[12], '%Y-%m-%d %H:%M:%S'),
                        action_type="RECHARGE", operator_username=row[18] if len(row)>18 else "legacy",
                        pos_sn=row[17] if len(row)>17 else "LEGACY"
                    ))
                    tx_count += 1
            except: continue
        db.flush()

        # 5. 拼装套件设备
        print("Step 5: 拼装 SHS 设备套件...")
        all_parts_raw = parse_sql_values("shsv1_ic_dev_equipment.sql")
        owned_units = {b[6]: b[3] for b in parse_sql_values("shsv1_ic_clients_equipment.sql") if len(b)>6}
        for i in range(0, len(all_parts_raw), 5):
            chunk = all_parts_raw[i:i+5]
            if not chunk: continue
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

        # 6. 迁移卡片
        print("Step 6: 同步 IC 卡库 (强制留空逻辑卡号)...")
        master_cards = {}
        cards_pool_raw = parse_sql_values("shsv1_ic_dev_card.sql")
        for row in cards_pool_raw:
            try:
                # 2: card_uuid (物理 UID)
                u_id = row[2].upper()
                # 根源解决：直接将没有实体卡号的设为 ""
                c_obj = Card(card_uuid=u_id, card_number="", status=0, created_at=datetime.now())
                db.add(c_obj)
                master_cards[u_id] = c_obj
            except: continue
        db.flush()

        for row in parse_sql_values("shsv1_ic_clients_card.sql"):
            try:
                cid, uid = row[1], row[4].upper()
                if uid in master_cards and cid in customer_map:
                    card_obj = master_cards[uid]
                    card_obj.customer_uuid, card_obj.status = cid, 1
                    card_obj.bound_at = datetime.now()
                    if row[9] != "NULL":
                        try:
                            base = datetime.strptime(row[9], '%Y-%m-%d %H:%M:%S')
                            db.query(Customer).filter(Customer.uuid == cid).update({"expiry_time": base + timedelta(days=int(row[6]))})
                        except: pass
            except: continue

        # 7. 初始化管理账号
        print("Step 7: 初始化系统账号...")
        db.add(User(username="admin", password_hash=hash_password("admin123"), role=1, mobile="09111111111", first_name="System", last_name="Admin"))
        db.add(User(username="fina", password_hash=hash_password("test123"), role=3, mobile="09222222222", first_name="Finance", last_name="Manager"))

        db.commit()
        
        # 8. 核心增强：同步所有表的发号器 (一劳永逸)
        print("Step 8: 正在强制同步数据库发号器...")
        tables = ["users", "customers", "cards", "solar_units", "transaction_logs", "regions", "pos_machines"]
        for table in tables:
            try:
                seq = db.execute(text(f"SELECT pg_get_serial_sequence('{table}', 'id')")).scalar()
                if seq:
                    db.execute(text(f"SELECT setval('{seq}', COALESCE((SELECT MAX(id) FROM {table}), 1), true)"))
                    print(f"   - {table} 序列已归位")
            except: pass
        db.commit()

        print(f"\n🎉 迁移大功告成！已成功导入 {pos_count} 台 POS 机资产。")

    except Exception as e:
        db.rollback()
        print(f"❌ 迁移失败: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    migrate()
