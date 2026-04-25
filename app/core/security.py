import bcrypt
import jwt
from datetime import datetime, timedelta, timezone
from typing import Any, Union
from app.core.config import settings

# JWT 配置
ALGORITHM = "HS256"
SECRET_KEY = getattr(settings, "SECRET_KEY", "your-super-secret-key")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    使用 bcrypt 验证明文密码
    """
    # bcrypt 存储的是 bytes，所以需要转换
    password_byte = plain_password.encode('utf-8')
    hashed_byte = hashed_password.encode('utf-8')
    return bcrypt.checkpw(password_byte, hashed_byte)

def get_password_hash(password: str) -> str:
    """
    使用 bcrypt 生成哈希密码
    """
    # 生成盐并哈希
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(pwd_bytes, salt)
    # 存入数据库通常用字符串，所以转回 utf-8
    return hashed_password.decode('utf-8')

def create_access_token(subject: Union[str, Any], expires_delta: timedelta = None) -> str:
    """
    生成 JWT Token
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=30)
    
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt