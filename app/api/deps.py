from typing import Generator
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import jwt
from sqlalchemy.orm import Session
from app.core.config import settings
from app.db.session import SessionLocal
from app.models.users import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/login/token")

def get_db() -> Generator:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 1级安检：只要 Token 有效就行
def get_current_user(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)) -> User:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid credentials")
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Login expired")
        
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user

# 2级安检：财务(2)、管理员(1) 或 超级管理员(0) 均可 (业务员3无权)
def get_finance_or_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role not in [0, 1, 2]:
        raise HTTPException(status_code=403, detail="Permission denied: Finance or Admin access only")
    return current_user

# 3级安检：仅限管理员(1) 或 超级管理员(0) (财务2和业务员3无权)
def get_current_admin_user(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role not in [0, 1]:
        raise HTTPException(status_code=403, detail="Core operation: Admin access only")
    return current_user