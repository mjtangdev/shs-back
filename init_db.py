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

def init_db():
    print(f"--- 数据库连接尝试：{engine.url.host}:{engine.url.port}/{engine.url.database} ---")
    
    # 强制重置结构
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        if IS_AUTO_CREATE_TESTDATA:
            print("🧪 正在以 [测试数据模式] 初始化数据库...")
            
            # 1. 地区树 (示例：菲律宾层级)
            municipality = Region(name="Pangasinan Municipality", level=0, daily_rate=20.0) 
            db.add(municipality)
            db.flush()

            barangays = {
                "Barangay Alpha": ["Purok 1", "Purok 2", "Purok 3"],
                "Barangay Beta": ["Purok 4", "Purok 5", "Purok 6"]
            }

            test_regions = []
            for brgy_name, puroks in barangays.items():
                brgy = Region(name=brgy_name, level=1, parent_id=municipality.id, daily_rate=25.0)
                db.add(brgy)
                db.flush()
                for purok_name in puroks:
                    purok = Region(name=purok_name, level=2, parent_id=brgy.id, daily_rate=30.0)
                    db.add(purok)
                    db.flush()
                    test_regions.append(purok)

            # 账号初始化 (fina & regional operators)
            db.add(User(
                username="fina",
                password_hash=hash_password("test123"),
                first_name="Finance", last_name="Manager",
                role=3, mobile="09888888888", region_id=municipality.id,
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
                print(f"✅ 已创建业务员: {u_name} (所属区域: {reg.name})")

            # 3. 随机客户 (每区10人)
            first_names = ["James", "Robert", "John", "Michael", "David", "William", "Richard", "Joseph", "Thomas", "Christopher"]
            last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"]
            for reg in test_regions:
                for _ in range(10):
                    db.add(Customer(
                        uuid=get_snowflake_id(),
                        first_name=random.choice(first_names), last_name=random.choice(last_names),
                        gender=random.choice(["male", "female"]),
                        mobile=f"09{random.randint(100000000, 999999999)}",
                        region_id=reg.id, status=1, created_at=datetime.now()
                    ))
            
            # 基础管理员绑定到根节点
            base_region_id = municipality.id
            provider_name = "SHS Philippines Branch"

        else:
            print("✨ 正在以 [纯净模式] 初始化数据库...")
            # 1. 基础根区域
            root_region = Region(name="Pangasinan", level=0)
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
        print("✅ 已创建超级管理员: sysadmin")

        db.add(User(
            username="admin",
            password_hash=hash_password("admin123"),
            first_name="System", last_name="Admin",
            role=1, mobile="09123456789", region_id=base_region_id,
            is_active=True
        ))
        print("✅ 已创建管理员: admin")

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
            print(f"✅ 已创建测试卡片: {[c['card_number'] for c in test_cards]}")

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
            print("✅ 已创建 5 套测试设备 (纯数字 4 位 ID)")

        db.commit()
        print(f"\n🎉 数据库初始化成功！(测试数据模式: {IS_AUTO_CREATE_TESTDATA})")
        
    except Exception as e:
        print(f"\n❌ 初始化失败: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_db()
