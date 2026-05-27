from app.db.session import SessionLocal, engine
from app.db.base_class import Base
from app.models.users import User
from app.models.org import Region
from app.models.config import ProviderConfig
# 导入其他模型以确保表被正确创建
from app.models.customer import Customer
from app.models.card import Card
from app.models.pos import POSMachine, POSActionLog
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer
from app.core.auth_utils import hash_password
from datetime import datetime

def init_db_clean():
    print(f"--- [Clean Mode] 数据库连接尝试：{engine.url.host}:{engine.url.port}/{engine.url.database} ---")
    
    # 1. 强制重置所有表结构
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        print("✨ 正在以 [纯净生产模式] 初始化数据库...")
        
        # 2. 创建基础根区域 (User 模型需要 region_id)
        root_region = Region(name="Pangasinan", level=0, daily_rate=7.0)
        db.add(root_region)
        db.flush() # 获取 ID

        # 3. 创建超级管理员 (Role 0)
        db.add(User(
            username="sysadmin",
            password_hash=hash_password("Supplier_Secure_Pwd_2026"),
            first_name="Supplier", last_name="Support",
            role=0, mobile="1111111111", region_id=root_region.id,
            is_active=True
        ))
        print("✅ 已创建超级管理员: sysadmin")

        # 4. 创建系统管理员 (Role 1)
        db.add(User(
            username="admin",
            password_hash=hash_password("admin123"),
            first_name="System", last_name="Admin",
            role=1, mobile="09123456789", region_id=root_region.id,
            is_active=True
        ))
        print("✅ 已创建管理员: admin")

        # 5. 初始化供应商基础配置 (未初始化状态)
        db.add(ProviderConfig(
            name="Default SHS Provider",
            tin="TIN_INIT_0000",
            is_initialized=False
        ))

        db.commit()
        print(f"\n🎉 纯净数据库初始化成功！仅保留 admin 及基础架构。")
        
    except Exception as e:
        print(f"\n❌ 初始化失败: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_db_clean()
