from app.db.session import SessionLocal, engine
from app.db.base_class import Base
from app.models.users import User
from app.models.org import Region
from app.models.config import ProviderConfig
from app.core.auth_utils import hash_password

def init_db():
    print("--- 正在初始化数据库基础数据 ---")
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # 1. 初始化顶级区域 (Root Province)
        root_region = db.query(Region).filter(Region.level == 0).first()
        if not root_region:
            db.add(Region(name="Pangasinan", level=0))
            print("✅ Created Root Province (Level 0)")
            db.commit()

        # 2. 创建供应商超级管理员 (sysadmin)
        sys_admin = db.query(User).filter(User.username == "sysadmin").first()
        if not sys_admin:
            db.add(User(
                username="sysadmin",
                password_hash=hash_password("Supplier_Secure_Pwd_2026"),
                first_name="Supplier", last_name="Support",
                role=0, mobile="1111111111", email="support@provider.com",
                province="Main Office", region_id=0, address="Supplier HQ"
            ))
            print("✅ Created sysadmin User")
            db.commit()
        
        # 3. 创建客户默认管理员 (admin)
        if not db.query(User).filter(User.username == "admin").first():
            db.add(User(
                username="admin",
                password_hash=hash_password("admin123"),
                first_name="System", last_name="Admin",
                role=1, mobile="0000000000", email="admin@shs.com",
                province="Initial System", region_id=0, address="System Root"
            ))
            print("✅ Created admin User")
            db.commit()

        # 4. 初始化默认总公司配置 (ProviderConfig)
        provider_config = db.query(ProviderConfig).first()
        if not provider_config:
            db.add(ProviderConfig(
                name="Default Provider Name",
                tin="DEFAULT_TIN_001",
                email="default@provider.com",
                phone="123-456-7890",
                address="Default Provider Address",
                is_initialized=False
            ))
            print("✅ Created default ProviderConfig")
            db.commit()
            
        print("🎉 数据库初始化完成！")
    except Exception as e:
        print(f"❌ 数据库初始化失败: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_db()