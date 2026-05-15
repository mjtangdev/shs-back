import os
from typing import Optional

class Settings: 
    # 确保 SECRET_KEY 至少为 32 字节 (例如 32 个字符)，HS256 算法要求 256 位密钥。
    # 建议从环境变量加载，这里提供一个足够长的默认值。
    SECRET_KEY = os.getenv("SECRET_KEY", "a_very_long_and_complex_secret_key_for_jwt_which_is_at_least_32_characters_long_and_secure")
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