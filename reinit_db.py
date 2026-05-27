import sys
import os
import bcrypt

# --- 1. 路径设置：确保脚本能找到 app 目录 ---
# 假设脚本放在项目根目录，将当前目录加入 Python 路径
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "."))
sys.path.insert(0, BASE_DIR)

from sqlalchemy.orm import Session
from app.db.session import SessionLocal
# 根据你核对的文件名进行导入
from app.models.users import User
from app.models.region_subsidiary import Region

def hash_password(password: str) -> str:
    """使用原生 bcrypt 对密码进行哈希处理"""
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(pwd_bytes, salt)
    return hashed.decode('utf-8')

def seed_data():
    """初始化基础业务数据"""
    db: Session = SessionLocal()
    try:
        print("--- 开始数据库数据初始化 (本地开发完善版) ---")

        # 1. 初始化管理员账号
        admin_username = "admin"
        admin = db.query(User).filter(User.username == admin_username).first()
        
        if not admin:
            print(f"正在创建管理员账号: {admin_username}...")
            new_admin = User(
                username=admin_username,
                password_hash=hash_password("admin123"), # 默认初始密码
                first_name="Admin",
                last_name="System",
                mobile="09123456789",
                role=1,         # 1 代表管理员权限
                is_active=True,
                province="Pangasinan",
                region_id=0
            )
            db.add(new_admin)
            print("✅ Admin 用户已创建 (默认密码: admin123)")
        else:
            print(f"ℹ️ Admin 用户 [{admin_username}] 已存在，跳过。")

        # 2. 初始化地理信息 (Root Region)
        region_name = "Pangasinan"
        root_region = db.query(Region).filter(Region.name == region_name).first()
        
        if not root_region:
            print(f"正在创建基础区域: {region_name}...")
            new_reg = Region(
                name=region_name, 
                level=0,  # 0 代表省级
                daily_rate=7.0
            )
            db.add(new_reg)
            print(f"✅ 基础省份 {region_name} 已创建")
        else:
            print(f"ℹ️ 区域 [{region_name}] 已存在，跳过。")

        # 3. 提交事务
        db.commit()
        print("\n🚀 所有基础数据同步完成！你可以开始登录系统了。")

    except Exception as e:
        print(f"\n❌ 初始化过程中发生错误: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    # 运行前检查依赖
    try:
        import bcrypt
    except ImportError:
        print("❌ 错误: 未检测到 bcrypt 库。请运行: pip install bcrypt")
        sys.exit(1)
        
    seed_data()