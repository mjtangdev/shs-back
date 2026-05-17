from typing import Generator
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import jwt
from sqlalchemy.orm import Session
from app.core.config import settings
from app.db.session import SessionLocal
from app.models.users import User

# 令牌地址应与 api.py 中的挂载路径一致
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
        
    # 全局账号状态检查：如果账号被禁用或被逻辑删除，Token 立即失效
    if user.is_deleted or not user.is_active:
        raise HTTPException(status_code=403, detail="User account has been locked or deleted")
        
    return user

# 2级安检：仅限管理员(1) 或 财务(3) (超级管理员0和业务员2无权)
def get_finance_or_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role not in [1, 3]:
        raise HTTPException(status_code=403, detail="Permission denied: Finance (3) or Admin (1) access only")
    return current_user

# 3级安检：仅限管理员(1) (超级管理员0、财务2和业务员3无权)
def get_current_admin_user(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != 1:
        raise HTTPException(status_code=403, detail="Permission denied: Admin access required")
    return current_user

# 新增：业务员(2)权限校验
def get_current_operator_user(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != 2:
        raise HTTPException(status_code=403, detail="Permission denied: Operator access only")
    return current_user

# 新增：管理层(4)权限校验
def get_current_management_user(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != 4:
        raise HTTPException(status_code=403, detail="Permission denied: Management access only")
    return current_user

# 4级安检：仅限超级管理员(0) (仅用于应急操作)
def get_current_super_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != 0:
        raise HTTPException(status_code=403, detail="Emergency operation: Super Admin access only")
    return current_user