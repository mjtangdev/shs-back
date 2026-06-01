from app.db.session import SessionLocal, engine
from app.db.base_class import Base
from app.models.users import User
from app.models.org import Region, BusinessEntity
from app.models.customer import Customer
from app.models.card import Card
from app.models.pos import POSMachine, POSActionLog
from app.models.config import ProviderConfig
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer
from app.core.auth_utils import hash_password
from datetime import datetime
import random
from snowflake import SnowflakeGenerator

# ==========================================
# 配置开关：是否自动创建测试数据 (地区树、业务员、随机客户)
# Set to True for testing, False for a clean start
# ==========================================
IS_AUTO_CREATE_TESTDATA = True

# 初始化雪花算法生成器 (Worker ID=1)
snowflake_gen = SnowflakeGenerator(1)

def get_snowflake_id():
    """使用雪花算法生成 ID (同主程序)"""
    return str(next(snowflake_gen))

# 用于记录本次运行已生成的 4 位 ID，防止碰撞
generated_ids = set()

def get_4digit_id():
    """生成唯一的 4 位纯数字 ID (用于设备)"""
    while True:
        new_id = f"{random.randint(1000, 9999)}"
        if new_id not in generated_ids:
            generated_ids.add(new_id)
            return new_id

import os
from sqlalchemy import text
from app.db.session import SessionLocal, engine
# ... 其他导入保持不变 ...

import os
import json
from sqlalchemy import text
from app.db.session import SessionLocal, engine
from app.db.base_class import Base
from app.models.users import User
from app.models.org import Region, BusinessEntity
from app.models.customer import Customer
from app.models.card import Card
from app.models.pos import POSMachine, POSActionLog
from app.models.config import ProviderConfig
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer
from app.core.auth_utils import hash_password
from datetime import datetime
import random

def restore_from_json():
    """检测并从 production_data.json 恢复所有真实业务数据"""
    # 尝试在当前目录和项目根目录查找
    json_file = "production_data.json"
    if not os.path.exists(json_file):
        # 尝试向上找一级 (兼容 docker 目录结构)
        json_file = os.path.join(os.path.dirname(__file__), "production_data.json")
        if not os.path.exists(json_file):
            return False

    print(f"📦 Found production data JSON: {json_file}")
    print("🚀 Restoring data via SQLAlchemy...")
    db = SessionLocal()
    try:
        with open(json_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        # 1. 恢复 Region (使用原子 SQL 保证 ID 顺序一致)
        print("- Restoring Regions...")
        for r in data["regions"]:
            db.execute(text("INSERT INTO regions (id, name, level, parent_id, daily_rate) VALUES (:id, :name, :level, :parent_id, :daily_rate) ON CONFLICT (id) DO NOTHING"), r)
        db.commit()

        # 2. 恢复 Configs
        print("- Restoring Configs...")
        for c in data["configs"]:
            db.add(ProviderConfig(**c))
        
        # 3. 恢复 Users
        print("- Restoring Users...")
        for u in data["users"]:
            u['created_at'] = datetime.fromisoformat(u['created_at']) if u['created_at'] else None
            db.add(User(**u))
        
        # 4. 恢复 Customers
        print("- Restoring Customers...")
        for c in data["customers"]:
            c['created_at'] = datetime.fromisoformat(c['created_at']) if c['created_at'] else None
            c['expiry_time'] = datetime.fromisoformat(c['expiry_time']) if c['expiry_time'] else None
            db.add(Customer(**c))
        db.flush()

        # 5. 恢复 Assets
        print("- Restoring Assets...")
        for c in data["cards"]:
            c['created_at'] = datetime.fromisoformat(c['created_at']) if c['created_at'] else None
            c['bound_at'] = datetime.fromisoformat(c['bound_at']) if c['bound_at'] else None
            db.add(Card(**c))
        for s in data["solar_units"]:
            s['created_at'] = datetime.fromisoformat(s['created_at']) if s['created_at'] else None
            s['bound_at'] = datetime.fromisoformat(s['bound_at']) if s['bound_at'] else None
            s['production_date'] = datetime.fromisoformat(s['production_date']) if s['production_date'] else None
            db.add(SolarUnit(**s))
        if "pos_machines" in data:
            for p in data["pos_machines"]:
                p['created_at'] = datetime.fromisoformat(p['created_at']) if p['created_at'] else None
                p['last_login_at'] = datetime.fromisoformat(p['last_login_at']) if p['last_login_at'] else None
                p['reconciliation_deadline'] = datetime.fromisoformat(p['reconciliation_deadline']) if p['reconciliation_deadline'] else None
                p['last_reconciliation_at'] = datetime.fromisoformat(p['last_reconciliation_at']) if p['last_reconciliation_at'] else None
                db.add(POSMachine(**p))
        
        # 6. 恢复 Transactions
        print("- Restoring Transactions...")
        for t in data["transactions"]:
            t['transaction_time'] = datetime.fromisoformat(t['transaction_time']) if t['transaction_time'] else None
            t['created_at'] = datetime.fromisoformat(t['created_at']) if t['created_at'] else None
            db.add(TransactionLog(**t))
        db.commit()

        # 7. 关键修正：同步所有表的 ID 序列 (Sequence Sync)
        print("- Syncing database sequences...")
        tables = ["regions", "users", "customers", "cards", "solar_units", "transaction_logs"]
        for table in tables:
            # 找到当前表最大的 ID，并把序列设为它的下一个
            db.execute(text(f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), COALESCE(MAX(id), 1)) FROM {table}"))
        db.commit()

        print("🎉 All real data restored and sequences synced successfully!")
        return True
    except Exception as e:
        db.rollback()
        print(f"❌ JSON Restore failed: {e}")
        return False
    finally:
        db.close()

def init_db():
    print(f"--- Database connection attempt: {engine.url.host}:{engine.url.port}/{engine.url.database} ---") 
    
    # 强制彻底重置所有表结构
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    # 修正 Postgres 唯一索引：允许为空字符串
    db_tmp = SessionLocal()
    try:
        db_tmp.execute(text('DROP INDEX IF EXISTS "ix_cards_card_number" CASCADE;'))
        db_tmp.execute(text('ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_card_number_key CASCADE;'))
        db_tmp.execute(text("CREATE UNIQUE INDEX ix_cards_card_number ON cards (card_number) WHERE card_number != '';"))
        db_tmp.commit()
    except Exception:
        db_tmp.rollback()
    finally:
        db_tmp.close()

    # 优先尝试从 JSON 镜像恢复
    if restore_from_json():
        return # 恢复成功，初始化结束

    # 如果没有 JSON，则走原有的测试数据生成逻辑
    db = SessionLocal()
    # ... 原有的初始化代码 ...
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        if IS_AUTO_CREATE_TESTDATA:
            print("🧪 Initializing database in [Test Data Mode]...") # 正在以 [测试数据模式] 初始化数据库...
            
            # 1. 地区树 (QUEZELCO-1 架构)
            root_reg = Region(name="QUEZELCO-1", level=0, daily_rate=7.0)
            db.add(root_reg)
            db.flush()

            regions_mapping = {
                "Tagkawayan": ["Del Gallego", "Guinyangan", "Calauag", "Lopez"],
                "Gumaca": ["Plaridel", "Atimonan"],
                "Alabat": ["Quezon-Quezon", "Perez"],
                "Agdangan": ["Padre Burgos", "Unisan", "Pitogo"],
                "Macalelon": ["Gen. Luna", "Catanauan", "Mulanay"],
                "San Narciso": ["Buenavista"],
                "San Francisco": ["San Andres"]
            }

            test_regions = []
            for brgy_name, puroks in regions_mapping.items():
                brgy = Region(name=brgy_name, level=1, parent_id=root_reg.id, daily_rate=7.0)
                db.add(brgy)
                db.flush()
                for purok_name in puroks:
                    purok = Region(name=purok_name, level=2, parent_id=brgy.id, daily_rate=7.0)
                    db.add(purok)
                    db.flush()
                    test_regions.append(purok)

            # 账号初始化 (fina & regional operators)
            db.add(User(
                username="fina",
                password_hash=hash_password("test123"),
                first_name="Finance", last_name="Manager",
                role=3, mobile="09888888888", region_id=root_reg.id,
                is_active=True
            ))

            for i, reg in enumerate(test_regions, 1):
                u_name = "opera" if i == 1 else f"opera{i-1}"
                db.add(User(
                    username=u_name,
                    password_hash=hash_password("test123"),
                    first_name="Operator", last_name=reg.name,
                    role=2, mobile=f"097{random.randint(10000000, 99999999)}",
                    region_id=reg.id, is_active=True
                ))
                print(f"✅ Created Operator: {u_name} (Region: {reg.name})") # 已创建业务员

            # 基础管理员绑定到根节点
            base_region_id = root_reg.id
            provider_name = "SHS Philippines Branch"

            # 3. 随机客户 (每区10人)
            first_names = ["James", "Robert", "John", "Michael", "David", "William", "Richard", "Joseph", "Thomas", "Christopher"]
            last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"]
            for reg in test_regions:
                for _ in range(10):
                    f_name = random.choice(first_names)
                    l_name = random.choice(last_names)
                    db.add(Customer(
                        uuid=get_snowflake_id(),
                        first_name=f_name, last_name=l_name,
                        gender=random.choice(["male", "female"]),
                        mobile=f"09{random.randint(100000000, 999999999)}",
                        region_id=reg.id, status=1, 
                        electric_company=provider_name,
                        beneficiary_count=random.randint(1, 5),
                        representative_name=f"{f_name} {l_name}",
                        rep_relationship="-",
                        created_at=datetime.now()
                    ))

        else:
            print("✨ Initializing database in [Clean Mode]...") # 正在以 [纯净模式] 初始化数据库...
            # 1. 基础根区域
            root_region = Region(name="QUEZELCO-1", level=0, daily_rate=7.0)
            db.add(root_region)
            db.flush()
            base_region_id = root_region.id
            provider_name = "Default SHS Provider"

        # 4. 无论哪种模式都必须创建的核心数据
        db.add(User(
            username="sysadmin",
            password_hash=hash_password("Supplier_Secure_Pwd_2026"),
            first_name="Supplier", last_name="Support",
            role=0, mobile="1111111111", region_id=base_region_id,
            is_active=True
        ))
        print("✅ Created Super Admin: sysadmin") # 已创建超级管理员: sysadmin

        db.add(User(
            username="admin",
            password_hash=hash_password("admin123"),
            first_name="System", last_name="Admin",
            role=1, mobile="09123456789", region_id=base_region_id,
            is_active=True
        ))
        print("✅ Created Admin: admin") # 已创建管理员: admin

        db.add(User(
            username="manager",
            password_hash=hash_password("test123"),
            first_name="Exec", last_name="Manager",
            role=4, mobile="09222222222", region_id=base_region_id,
            is_active=True
        ))
        print("✅ Created Manager: manager") # 已创建管理层: manager

        db.add(ProviderConfig(
            name=provider_name,
            tin="TIN_INIT_2024",
            is_initialized=IS_AUTO_CREATE_TESTDATA
        ))

        # --- 新增：初始化特定测试卡片 / Initialize specific test cards ---
        if IS_AUTO_CREATE_TESTDATA:
            test_cards = [
                {"card_number": "008822224", "card_uuid": "033a63ae"},
                {"card_number": "00820497", "card_uuid": "23ac47ae"}
            ]
            for card_data in test_cards:
                db.add(Card(
                    card_number=card_data["card_number"],
                    card_uuid=card_data["card_uuid"],
                    status=0,  # In Stock
                    created_at=datetime.now()
                ))
            print(f"✅ Created test cards: {[c['card_number'] for c in test_cards]}") # 已创建测试卡片

            # --- 新增：生成 5 套设备 / Generate 5 sets of solar devices ---
            for i in range(1, 6):
                db.add(SolarUnit(
                    shs_machine_id=get_4digit_id(),
                    solar_equipment_id=get_4digit_id(),
                    radio_id=get_4digit_id(),
                    flashlight_id=get_4digit_id(),
                    led_light_id=get_4digit_id(),
                    production_date=datetime.now(),
                    shs_status=0, # In Stock
                    created_at=datetime.now()
                ))
            print("✅ Created 5 sets of test devices (4-digit numeric IDs)") # 已创建 5 套测试设备

        db.commit()
        print(f"\n🎉 Database initialized successfully! (Test Data Mode: {IS_AUTO_CREATE_TESTDATA})") # 数据库初始化成功！
        
    except Exception as e:
        print(f"\n❌ Initialization failed: {e}") # 初始化失败
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_db()
