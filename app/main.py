import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from fastapi.staticfiles import StaticFiles
from pathlib import Path

# 导入你的 API 路由
from app.api.v1.api import api_router
from app.models.config import ProviderConfig # 导入 ProviderConfig 模型
from app.models.org import Region # 导入 Region 模型
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer # 导入暂存模型
from app.models.transaction import TransactionLog # 导入流水模型
from app.db.base_class import Base
from app.db.session import engine, SessionLocal
from app.models.users import User
from app.core.auth_utils import hash_password

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 【启动时执行】
    
    # 强制确保所有表结构已经建立。具体的默认数据初始化逻辑已迁移至独立的 init_db.py 脚本中。
    print("--- 正在检查并创建表结构 ---")
    Base.metadata.create_all(bind=engine)
        
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
# 计算项目根目录
# 假设 main.py 在 app/ 目录下
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# 定义 Logo 文件的物理存储路径
LOGO_PHYSICAL_DIR = PROJECT_ROOT / "static" / "uploads" / "logos"

# 挂载静态文件目录，将 /static URL 路径映射到 LOGO_PHYSICAL_DIR
app.mount("/static", StaticFiles(directory=LOGO_PHYSICAL_DIR), name="static")

# 包含你的所有 API 路由
app.include_router(api_router, prefix="/api/v1")

# 你可能还有其他根路由，例如：
@app.get("/")
async def root():
    return {"status": "Backend is running", "message": "Welcome to SHS Backend API"}