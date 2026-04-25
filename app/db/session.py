import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# 1. 优先读取完整连接字符串 (生产环境/Docker 推荐)
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

# 2. 如果没有 DATABASE_URL，则通过拆分变量构建 (本地开发环境)
if not SQLALCHEMY_DATABASE_URL:
    DB_USER = os.getenv("POSTGRES_USER", "solar_admin")
    DB_PASS = os.getenv("POSTGRES_PASSWORD", "Webdev123")
    DB_SERVER = os.getenv("POSTGRES_SERVER", "localhost")
    DB_PORT = os.getenv("POSTGRES_PORT", "5432")
    DB_NAME = os.getenv("POSTGRES_DB", "shs_db")
    SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_SERVER}:{DB_PORT}/{DB_NAME}"

# 打印一下连接地址（脱敏后），方便在日志里排查问题
# 注意：正式上线后可以删除这行，但在调试阶段非常管用
print(f"--- 数据库连接尝试：{SQLALCHEMY_DATABASE_URL.split('@')[-1]} ---")

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, 
    pool_pre_ping=True  # 👈 自动检查连接有效性，防止断连
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)