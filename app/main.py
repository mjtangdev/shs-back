from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.api.v1.api import api_router
from app.db.base_class import Base
from app.db.session import engine, SessionLocal
from app.models.users import User
from app.core.auth_utils import hash_password

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 【启动时执行】
    
    # 1. 第一步：强制确保所有表结构已经建立 (核心修复点)
    print("--- 正在检查并创建表结构 ---")
    Base.metadata.create_all(bind=engine)
    
    # 2. 第二步：初始化管理员
    db = SessionLocal()
    try:
        # 创建供应商超级管理员 (sysadmin)
        sys_admin = db.query(User).filter(User.username == "sysadmin").first()
        if not sys_admin:
            print("--- 系统初始化：创建供应商超级管理员 ---")
            db.add(User(
                username="sysadmin",
                password_hash=hash_password("Supplier_Secure_Pwd_2026"), # 请务必使用更复杂的固定密码
                first_name="Supplier",
                last_name="Support",
                role=0, # Super Admin
                mobile="1111111111",
                email="support@provider.com",
                province="Main Office",
                city_id=0, town_id=0, address="Supplier HQ"
            ))
            db.commit()

        # 创建客户默认管理员 (admin)
        admin = db.query(User).filter(User.username == "admin").first()
        if not admin:
            print("--- 系统初始化：创建内置管理员 ---")
            new_admin = User(
                username="admin",
                password_hash=hash_password("admin123"),
                first_name="System",
                last_name="Admin",
                role=1,
                mobile="0000000000",
                email="admin@shs.com",
                province="Initial System",
                city_id=0,
                town_id=0,
                address="System Root"
            )
            db.add(new_admin)
            db.commit()
            print("--- 初始化成功：admin / admin123 ---")
    except Exception as e:
        print(f"--- 初始化管理员失败 (可能是表尚未就绪): {e} ---")
        db.rollback()
    finally:
        db.close()
        
    yield
    # 【关闭时执行】
    pass

app = FastAPI(
    title="SHS Management System API",
    version="1.0.0",
    lifespan=lifespan
)

# --- [ 跨域配置 ] ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")

@app.get("/")
def root():
    return {"status": "Backend is running"}