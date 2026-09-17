import os
import json
import logging
import time
from datetime import datetime
from sqlalchemy import text
from app.db.session import SessionLocal, engine
from app.db.base_class import Base
from app.models.users import User
from app.models.org import Region, BusinessEntity
from app.models.customer import Customer
from app.models.card import Card
from app.models.pos import POSMachine, POSActionLog
from app.models.config import ProviderConfig
from app.models.solar_device import SolarUnit, SolarPVPanel
from app.models.transaction import TransactionLog

logger = logging.getLogger(__name__)

def perform_db_restore(json_content: dict = None, json_file_path: str = "production_data.json"):
    """
    从 JSON 数据恢复/同步数据库
    """
    logger.info("⏳ Waiting 2 seconds for existing API sessions to close...")
    time.sleep(2) # 👈 关键：给 API 线程留出释放数据库锁的时间

    db = SessionLocal()
    try:
        if not json_content:
            if not os.path.exists(json_file_path):
                return False, f"JSON file not found: {json_file_path}"
            with open(json_file_path, "r", encoding="utf-8") as f:
                json_content = json.load(f)

        logger.info("🚀 Starting database restore from JSON...")

        # 0. 设置锁等待超时，防止永久卡死
        db.execute(text("SET lock_timeout = '10s'"))
        db.commit()

        # 1. 清理业务数据
        tables = [
            "transaction_logs", "cards", "solar_units", "solar_pv_panels", "pos_action_logs", 
            "pos_machines", "customers", "business_entities", "users", 
            "provider_configs", "regions"
        ]
        for table in tables:
            logger.info(f"🧹 Truncating table: {table}...")
            # CASCADE 会自动处理外键关联
            db.execute(text(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE"))
        db.commit()
        logger.info("✅ All tables cleared.")

        # 2. 恢复 Region (按 level 排序确保父级先插入)
        if "regions" in json_content:
            regions = json_content["regions"]
            # 简单排序：level 0 -> 1 -> 2
            regions.sort(key=lambda x: x.get('level', 0))
            for r in regions:
                db.execute(text("INSERT INTO regions (id, name, level, parent_id, daily_rate) VALUES (:id, :name, :level, :parent_id, :daily_rate) ON CONFLICT (id) DO NOTHING"), r)
            db.commit()

        # 3. 恢复 Configs
        if "configs" in json_content:
            for c in json_content["configs"]:
                db.add(ProviderConfig(**c))
        db.flush()

        # 4. 恢复 Users
        if "users" in json_content:
            user_list = []
            for u in json_content["users"]:
                if u.get('created_at'): u['created_at'] = datetime.fromisoformat(u['created_at'])
                user_list.append(u)
            db.bulk_insert_mappings(User, user_list)
        db.flush()

        # [安全兜底] 检查关键账号是否存在
        from app.core.auth_utils import hash_password
        existing_usernames = [r[0] for r in db.execute(text("SELECT username FROM users")).fetchall()]

        if "superadmin" not in existing_usernames:
            db.add(User(
                username="superadmin",
                password_hash=hash_password("Supplier_Secure_Pwd_2026"),
                role=0, first_name="Supplier", last_name="Support", is_active=True
            ))
        if "admin" not in existing_usernames:
            db.add(User(
                username="admin",
                password_hash=hash_password("admin123"),
                role=1, first_name="System", last_name="Admin", is_active=True
            ))
        db.commit()

        # 5. 恢复 Business Entities
        if "business_entities" in json_content:
            for b in json_content["business_entities"]:
                db.add(BusinessEntity(**b))
            db.commit()

        # 6. 恢复 Customers (批量)
        if "customers" in json_content:
            cust_list = []
            for c in json_content["customers"]:
                if c.get('created_at'): c['created_at'] = datetime.fromisoformat(c['created_at'])
                if c.get('expiry_time'): c['expiry_time'] = datetime.fromisoformat(c['expiry_time'])
                cust_list.append(c)
            db.bulk_insert_mappings(Customer, cust_list)
        db.flush()

        # 7. 恢复 Assets (批量)
        if "cards" in json_content:
            card_list = []
            for c in json_content["cards"]:
                if c.get('created_at'): c['created_at'] = datetime.fromisoformat(c['created_at'])
                if c.get('bound_at'): c['bound_at'] = datetime.fromisoformat(c['bound_at'])
                card_list.append(c)
            db.bulk_insert_mappings(Card, card_list)

        if "solar_units" in json_content:
            unit_list = []
            for s in json_content["solar_units"]:
                if s.get('created_at'): s['created_at'] = datetime.fromisoformat(s['created_at'])
                if s.get('bound_at'): s['bound_at'] = datetime.fromisoformat(s['bound_at'])
                if s.get('production_date'): s['production_date'] = datetime.fromisoformat(s['production_date'])
                unit_list.append(s)
            db.bulk_insert_mappings(SolarUnit, unit_list)

        if "solar_pv_panels" in json_content:
            pv_list = []
            for p in json_content["solar_pv_panels"]:
                if p.get('created_at'): p['created_at'] = datetime.fromisoformat(p['created_at'])
                if p.get('bound_at'): p['bound_at'] = datetime.fromisoformat(p['bound_at'])
                if p.get('production_date'): p['production_date'] = datetime.fromisoformat(p['production_date'])
                pv_list.append(p)
            db.bulk_insert_mappings(SolarPVPanel, pv_list)

        if "pos_machines" in json_content:
            pos_list = []
            for p in json_content["pos_machines"]:
                if p.get('created_at'): p['created_at'] = datetime.fromisoformat(p['created_at'])
                if p.get('last_login_at'): p['last_login_at'] = datetime.fromisoformat(p['last_login_at'])
                if p.get('reconciliation_deadline'): p['reconciliation_deadline'] = datetime.fromisoformat(p['reconciliation_deadline'])
                if p.get('last_reconciliation_at'): p['last_reconciliation_at'] = datetime.fromisoformat(p['last_reconciliation_at'])
                pos_list.append(p)
            db.bulk_insert_mappings(POSMachine, pos_list)

        if "pos_action_logs" in json_content:
            log_list = []
            for l in json_content["pos_action_logs"]:
                if l.get('timestamp'): l['timestamp'] = datetime.fromisoformat(l['timestamp'])
                log_list.append(l)
            db.bulk_insert_mappings(POSActionLog, log_list)

        # 8. 恢复 Transactions (批量)
        if "transactions" in json_content:
            tx_list = []
            for t in json_content["transactions"]:
                if t.get('transaction_time'): t['transaction_time'] = datetime.fromisoformat(t['transaction_time'])
                if t.get('created_at'): t['created_at'] = datetime.fromisoformat(t['created_at'])
                tx_list.append(t)
            db.bulk_insert_mappings(TransactionLog, tx_list)

        db.commit()

        # 8. 同步序列
        for table in tables:
            try:
                max_id = db.execute(text(f"SELECT MAX(id) FROM {table}")).scalar() or 1
                seq = db.execute(text(f"SELECT pg_get_serial_sequence('{table}', 'id')")).scalar()
                if seq:
                    db.execute(text(f"SELECT setval('{seq}', {max_id}, true)"))
            except Exception as e:
                logger.warning(f"Failed to sync sequence for {table}: {e}")
        db.commit()

        logger.info("🎉 Database restore completed successfully!")
        return True, "Success"
    except Exception as e:
        db.rollback()
        logger.error(f"❌ Restore failed: {e}")
        return False, str(e)
    finally:
        db.close()
