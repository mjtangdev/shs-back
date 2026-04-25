from app.db.session import SessionLocal
from app.models.users import User
from app.core.auth_utils import hash_password

def create_superuser():
    db = SessionLocal()
    
    try:
        # 1. 检查是否已经存在管理员
        user = db.query(User).filter(User.username == "admin").first()
        
        if user:
            print("超级管理员 admin 已存在，正在强制重置密码为 admin123...")
            user.password_hash = hash_password("admin123")
            db.commit()
            print("密码已重置！")
            return

        # 2. 创建超级管理员实例
        # 注意：role=1 代表 Admin，这是我们之前的约定
        superuser = User(
            username="admin",
            password_hash=hash_password("admin123"),  # 👈 建议第一次登录后立即修改
            first_name="Super",
            last_name="Admin",
            mobile="0000000000",
            email="admin@shs.com",
            role=1,  # 1: Admin, 2: Operator
            province="Pangasinan",
            city_id=0, # 超级管理员可以不设具体的市
            town_id=0, # 超级管理员可以不设具体的镇
            address="System Root"
        )

        db.add(superuser)
        db.commit()
        print("成功创建超级管理员！")
        print("用户名: admin")
        print("密  码: admin123")
        
    except Exception as e:
        print(f"创建失败: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    create_superuser()