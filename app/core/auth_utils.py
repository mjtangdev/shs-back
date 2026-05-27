import bcrypt
import jwt
from datetime import datetime, timedelta, timezone
from app.core.config import settings

def hash_password(password: str) -> str:
    """将明文密码转换为哈希值"""
    # 将字符串转为字节流
    pwd_bytes = password.encode('utf-8')
    # 生成盐并哈希
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(pwd_bytes, salt)
    # 返回字符串格式方便数据库存储
    return hashed_password.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """验证明文密码是否正确"""
    return bcrypt.checkpw(
        plain_password.encode('utf-8'),
        hashed_password.encode('utf-8')
    )

    
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt