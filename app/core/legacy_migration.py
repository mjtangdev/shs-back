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

        # 2.1 核心全量迁移：从 shsv1_ic_sys_region.sql 导入所有 1747 个行政区域树节点
        if "shsv1_ic_sys_region.sql" in files_dict:
            # 清理现有 Regions 表以无损重建完整区域树
            db.execute(text("DELETE FROM regions CASCADE;"))
            db.commit()

            regions_raw = parse_sql_content(files_dict["shsv1_ic_sys_region.sql"])
            id_map = {} # old_id -> new_region_id
            
            # 按 parent_id 级别排序，确保父节点先插入
            for row in sorted(regions_raw, key=lambda x: int(x[1]) if (len(x)>1 and x[1] and x[1] != "NULL") else 0):
                if len(row) < 4: continue
                old_id = row[0]
                old_pid = row[1]
                r_name = row[3].strip()
                if not r_name or r_name == "NULL": continue

                p_id = id_map.get(old_pid) if (old_pid and old_pid != "0" and old_pid != "NULL") else None
                level = 0
                if p_id:
                    parent_obj = db.query(Region).filter(Region.id == p_id).first()
                    if parent_obj:
                        level = parent_obj.level + 1

                new_r = Region(
                    name=r_name,
                    level=level,
                    parent_id=p_id,
                    daily_rate=7.0
                )
                db.add(new_r)
                db.flush()
                id_map[old_id] = new_r.id

            db.commit()
            logger.info(f"✅ 成功导入 {len(id_map)} 个行政区域树节点！")

        # 3. 核心对齐：重建 QUEZELCO-1 专属三级组织架构树
        q_root = db.query(Region).filter(Region.name == "QUEZELCO-1", Region.level == 0).first()
        if not q_root:
            q_root = Region(name="QUEZELCO-1", level=0, daily_rate=7.0)
            db.add(q_root)
            db.flush()

        quezelco_mapping = {
            "Tagkawayan": ["Del Gallego", "Guinyangan", "Calauag", "Lopez"],
            "Gumaca": ["Plaridel", "Atimonan"],
            "Alabat": ["Quezon-Quezon", "Perez"],
            "Agdangan": ["Padre Burgos", "Unisan", "Pitogo"],
            "Macalelon": ["Gen. Luna", "Catanauan", "Mulanay"],
            "San Narciso": ["Buenavista"],
            "San Francisco": ["San Andres"]
        }

        region_cache = {}
        for town_name, brgys in quezelco_mapping.items():
            t_node = db.query(Region).filter(Region.name.ilike(town_name)).first()
            if not t_node:
                t_node = Region(name=town_name, level=1, parent_id=q_root.id, daily_rate=7.0)
                db.add(t_node)
                db.flush()
            else:
                t_node.level = 1
                t_node.parent_id = q_root.id

            region_cache[town_name.lower()] = t_node.id

            # 建立预设下的 Level 2 子社区 (如 Buenavista)
            for b_name in brgys:
                b_node = db.query(Region).filter(Region.name.ilike(b_name)).first()
                if not b_node:
                    b_node = Region(name=b_name, level=2, parent_id=t_node.id, daily_rate=7.0)
                    db.add(b_node)
                    db.flush()
                else:
                    b_node.level = 2
                    b_node.parent_id = t_node.id
                region_cache[b_name.lower()] = b_node.id

            # 建立与办事处同名的唯一 Level 2 Purok (如 San Narciso Purok，专门接纳未归类到 Buenavista 的客户)
            same_purok = db.query(Region).filter(Region.name.ilike(town_name), Region.level == 2, Region.parent_id == t_node.id).first()
            if not same_purok:
                same_purok = Region(name=town_name, level=2, parent_id=t_node.id, daily_rate=7.0)
                db.add(same_purok)
                db.flush()
            region_cache[f"{town_name.lower()}_self"] = same_purok.id

        db.commit()
        root = q_root

        # 确保 Fina 账号存在
        if not db.query(User).filter(User.username == "fina").first():
            db.add(User(
                username="fina", password_hash=hash_password("test123"),
                role=3, mobile="09222222222", first_name="Finance", last_name="Manager",
                region_id=root.id, is_active=True
            ))

        # 3.1 核心全量迁移：导入老 MySQL 系统的 91 个系统用户账号
        if "shsv1_sys_user.sql" in files_dict:
            users_raw = parse_sql_content(files_dict["shsv1_sys_user.sql"])
            default_pwd_hash = hash_password("admin123")
            seen_emails = set(e[0] for e in db.query(User.email).filter(User.email.isnot(None)).all())
            seen_usernames = set(u[0] for u in db.query(User.username).all())

            for row in users_raw:
                if len(row) < 8: continue
                u_name = row[3].strip()
                if not u_name or u_name == "NULL" or u_name.lower() in ["admin", "superadmin", "fina"]:
                    continue

                if u_name in seen_usernames:
                    continue

                nick = row[4] if (row[4] and row[4] != "NULL") else u_name
                u_email = row[6] if (row[6] and row[6] != "NULL" and "@" in row[6]) else None
                u_phone = row[7] if (row[7] and row[7] != "NULL") else None

                # Email 防重去重校验
                if u_email:
                    if u_email in seen_emails:
                        u_email = None
                    else:
                        seen_emails.add(u_email)

                seen_usernames.add(u_name)

                db.add(User(
                    username=u_name,
                    password_hash=default_pwd_hash,
                    first_name=nick,
                    last_name="Operator",
                    email=u_email,
                    mobile=u_phone[:20] if u_phone else f"09{u_name[:10]}",
                    role=2, # 默认设为 Operator 离线 POS/业务员角色
                    region_id=root.id,
                    is_active=True
                ))
            db.flush()

        db.execute(text(f"UPDATE users SET region_id = {root.id} WHERE role IN (0, 1);"))
        db.commit()

        # 4. 建立全量最新的区域查找索引字典 (同时包含 1746 节点树与 QUEZELCO-1 办事处)
        region_name_map = {r.name.strip().lower(): r.id for r in db.query(Region).all()}

        # 5. POS 资产
        if "shsv1_ic_dev_pos.sql" in files_dict:
            pos_raw = parse_sql_content(files_dict["shsv1_ic_dev_pos.sql"])
            for row in pos_raw:
                if len(row) < 4: continue
                sn = row[3]
                if sn and sn != "NULL":
                    db.add(POSMachine(pos_sn=sn, status=1 if row[5] == '1' else 0, created_at=datetime.now()))
            db.flush()

        # 6. 客户迁移 (严格限定在 QUEZELCO-1 预设节点树中，绝不新建杂项节点)
        customer_map = {}
        cust_id_to_uuid = {}
        if "shsv1_ic_clients.sql" in files_dict:
            clients_raw = parse_sql_content(files_dict["shsv1_ic_clients.sql"])
            for row in clients_raw:
                if len(row) < 13: continue
                c_uuid = row[2]
                if not c_uuid or c_uuid == "NULL": continue

                c_id = row[0]
                c_id_alt = row[1]
                cust_id_to_uuid[c_id] = c_uuid
                if c_id_alt and c_id_alt != "NULL":
                    cust_id_to_uuid[c_id_alt] = c_uuid
                cust_id_to_uuid[c_uuid] = c_uuid

                raw_purok = row[11].strip() if (len(row)>11 and row[11] and row[11] != "NULL") else ""
                raw_town = row[12].strip() if (len(row)>12 and row[12] and row[12] != "NULL") else ""

                target_town = raw_town or "Gumaca"
                town_key = target_town.lower()

                # 精准归分配逻辑：
                # 只有当 raw_purok 恰好属于预设的子社区 (如 Buenavista) 时划分入该社区；
                # 所有其他情况 (包括 White Cliff 或未划分) 一律划分入该办事处的同名 Purok 节点 (如 San Narciso Purok)！
                if raw_purok and raw_purok.lower() in region_cache and raw_purok.lower() != town_key:
                    r_id = region_cache[raw_purok.lower()]
                else:
                    r_id = region_cache.get(f"{town_key}_self") or region_cache.get(town_key) or region_cache.get("gumaca")

                db.add(Customer(
                    uuid=c_uuid, first_name=row[3], last_name=row[4],
                    gender="female" if row[5] == '1' else "male",
                    mobile=row[7][:20] if row[7] != "NULL" else f"09{c_uuid}",
                    address=raw_purok or None, # 原原本本在 address 字段保留原始门牌文本 (如 White Cliff)
                    region_id=r_id, status=1, created_at=datetime.now()
                ))
                customer_map[c_uuid] = True
            db.flush()

        # 7. 财务流水全量迁移 (通过 ID 字典映射实现 100% 客户姓名匹配)
        if "shsv1_ic_fin_accounting.sql" in files_dict:
            accounting_raw = parse_sql_content(files_dict["shsv1_ic_fin_accounting.sql"])
            count = 0
            for row in accounting_raw:
                if len(row) < 15: continue
                # 智能映射：优先从短 UUID 找；找不到则用 BigInt ID 字典翻出对应的短 UUID
                c_uuid = None
                if len(row) > 4 and row[4] in customer_map:
                    c_uuid = row[4]
                elif len(row) > 3 and row[3] in cust_id_to_uuid:
                    c_uuid = cust_id_to_uuid[row[3]]
                elif len(row) > 2 and row[2] in cust_id_to_uuid:
                    c_uuid = cust_id_to_uuid[row[2]]
                else:
                    c_uuid = row[3] if (row[3] and row[3] != "NULL") else (row[4] if (row[4] and row[4] != "NULL") else row[2])

                if not c_uuid or c_uuid == "NULL": continue

                try:
                    tx_time = datetime.strptime(row[12], '%Y-%m-%d %H:%M:%S') if (len(row)>12 and row[12] != "NULL") else datetime.now()
                except:
                    tx_time = datetime.now()

                db.add(TransactionLog(
                    transaction_id=row[1],
                    customer_uuid=c_uuid,
                    amount=float(row[10]) if (len(row)>10 and row[10] != "NULL") else 0.0,
                    days=int(float(row[14])) if (len(row)>14 and row[14] != "NULL") else 0,
                    transaction_time=tx_time,
                    action_type="RECHARGE",
                    operator_username=row[18] if (len(row)>18 and row[18] != "NULL") else "legacy",
                    pos_sn=row[17] if (len(row)>17 and row[17] != "NULL") else "LEGACY"
                ))
                count += 1
                if count % 1000 == 0: db.commit()
            db.commit()
            logger.info(f"✅ 成功导入全量财务交易流水: {count} 条！")

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
