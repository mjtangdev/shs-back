import os
import json
import logging
from datetime import datetime
from sqlalchemy import text
from app.db.session import SessionLocal
from app.db.base_class import Base
from app.models.users import User
from app.models.org import Region
from app.models.customer import Customer
from app.models.card import Card
from app.models.pos import POSMachine
from app.models.config import ProviderConfig
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog

logger = logging.getLogger(__name__)

def perform_db_restore(json_content: dict = None, json_file_path: str = "production_data.json"):
    """
    从 JSON 数据恢复/同步数据库
    :param json_content: 直接传入 JSON 字典内容（优先级高）
    :param json_file_path: 如果 content 为空，则从文件读取
    """
    db = SessionLocal()
    try:
        if not json_content:
            if not os.path.exists(json_file_path):
                return False, f"JSON file not found: {json_file_path}"
            with open(json_file_path, "r", encoding="utf-8") as f:
                json_content = json.load(f)

        logger.info("🚀 Starting database restore from JSON...")

        # 1. 清理业务数据
        # [全量重置] 包含 users 表，确保云端环境与本地准备好的迁移数据完全一致
        tables = ["transaction_logs", "cards", "solar_units", "pos_machines", "customers", "users", "configs", "regions"]
        for table in tables:
            db.execute(text(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE"))
        db.commit()

        # 2. 恢复 Region
        if "regions" in json_content:
            for r in json_content["regions"]:
                db.execute(text("INSERT INTO regions (id, name, level, parent_id, daily_rate) VALUES (:id, :name, :level, :parent_id, :daily_rate) ON CONFLICT (id) DO NOTHING"), r)
            db.commit()

        # 3. 恢复 Configs
        if "configs" in json_content:
            for c in json_content["configs"]:
                db.add(ProviderConfig(**c))

        # 4. 恢复 Users
        if "users" in json_content:
            for u in json_content["users"]:
                if u.get('created_at'): u['created_at'] = datetime.fromisoformat(u['created_at'])
                db.add(User(**u))
        db.flush()

        # [安全兜底] 检查关键账号是否存在，如果 JSON 里没带，则强制补全
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

        # 5. 恢复 Customers
        if "customers" in json_content:
            for c in json_content["customers"]:
                if c.get('created_at'): c['created_at'] = datetime.fromisoformat(c['created_at'])
                if c.get('expiry_time'): c['expiry_time'] = datetime.fromisoformat(c['expiry_time'])
                db.add(Customer(**c))
        db.flush()

        # 6. 恢复 Assets (Cards, SolarUnits, POS)
        if "cards" in json_content:
            for c in json_content["cards"]:
                if c.get('created_at'): c['created_at'] = datetime.fromisoformat(c['created_at'])
                if c.get('bound_at'): c['bound_at'] = datetime.fromisoformat(c['bound_at'])
                db.add(Card(**c))

        if "solar_units" in json_content:
            for s in json_content["solar_units"]:
                if s.get('created_at'): s['created_at'] = datetime.fromisoformat(s['created_at'])
                if s.get('bound_at'): s['bound_at'] = datetime.fromisoformat(s['bound_at'])
                if s.get('production_date'): s['production_date'] = datetime.fromisoformat(s['production_date'])
                db.add(SolarUnit(**s))

        if "pos_machines" in json_content:
            for p in json_content["pos_machines"]:
                if p.get('created_at'): p['created_at'] = datetime.fromisoformat(p['created_at'])
                if p.get('last_login_at'): p['last_login_at'] = datetime.fromisoformat(p['last_login_at'])
                if p.get('reconciliation_deadline'): p['reconciliation_deadline'] = datetime.fromisoformat(p['reconciliation_deadline'])
                if p.get('last_reconciliation_at'): p['last_reconciliation_at'] = datetime.fromisoformat(p['last_reconciliation_at'])
                db.add(POSMachine(**p))

        # 7. 恢复 Transactions
        if "transactions" in json_content:
            for t in json_content["transactions"]:
                if t.get('transaction_time'): t['transaction_time'] = datetime.fromisoformat(t['transaction_time'])
                if t.get('created_at'): t['created_at'] = datetime.fromisoformat(t['created_at'])
                db.add(TransactionLog(**t))

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
