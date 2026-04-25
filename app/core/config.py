import os
from typing import Optional

class Settings:
    SECRET_KEY = "your-super-secret-key-change-me"
    ALGORITHM = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24

    # 对应你 Docker 配置中的参数
    POSTGRES_USER = "solar_admin"
    POSTGRES_PASSWORD = "Webdev123"
    POSTGRES_SERVER = "127.0.0.1"
    POSTGRES_PORT = "5432"
    POSTGRES_DB = "shs_db"

    # 动态拼接成 SQLAlchemy 需要的 URI 格式
    SQLALCHEMY_DATABASE_URI = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_SERVER}:{POSTGRES_PORT}/{POSTGRES_DB}"

settings = Settings()