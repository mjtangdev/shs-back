from fastapi import APIRouter, Depends, HTTPException, status, Body
from sqlalchemy.orm import Session
from typing import List
from app.api.deps import get_db, get_current_user, get_finance_or_admin, get_current_admin_user

from app.models.users import User
from app.schemas.users import UserCreate, UserRead, UserUpdate
from app.core.auth_utils import hash_password

router = APIRouter()

# --- 1. 创建用户 ---
@router.post("/", response_model=UserRead, status_code=status.HTTP_201_CREATED)
def create_user(
    user_in: UserCreate, 
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    # 权限保护：只能创建比自己角色等级低的用户 (Role ID 更大)
    if user_in.role <= current_admin.role and current_admin.role != 0:
        raise HTTPException(status_code=403, detail="Permission denied: Cannot create an account with same or higher role")

    # 查重：用户名和邮箱
    if db.query(User).filter(User.username == user_in.username).first():
        raise HTTPException(status_code=400, detail="Username already registered")
    if user_in.email and db.query(User).filter(User.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    
    user_data = user_in.model_dump()
    password = user_data.pop("password")
    
    # 显式构建模型实例，确保 role, position 等字段被传入
    db_obj = User(
        **user_data,
        password_hash=hash_password(password)
    )
    
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

# --- 2. 获取用户列表 ---
@router.get("/", response_model=List[UserRead])
def read_users(
    db: Session = Depends(get_db), 
    current_admin: User = Depends(get_current_admin_user),
    skip: int = 0, 
    limit: int = 100
):
    query = db.query(User)
    # 隐私保护：不显示比自己级别更高的用户
    if current_admin.role == 1:
        query = query.filter(User.role != 0)
    return query.offset(skip).limit(limit).all()

# --- 3. 更新用户 ---
@router.put("/{user_id}", response_model=UserRead)
def update_user(
    user_id: int,
    user_in: UserUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # 权限保护：禁止修改同级或更高级别的账号
    if db_user.role <= current_admin.role and db_user.id != current_admin.id and current_admin.role != 0:
        raise HTTPException(status_code=403, detail="Permission denied: Cannot modify a higher-level account")

    update_data = user_in.model_dump(exclude_unset=True)

    if "password" in update_data:
        pw = update_data.pop("password")
        db_user.password_hash = hash_password(pw)

    for field, value in update_data.items():
        setattr(db_user, field, value)

    db.commit()
    db.refresh(db_user)
    return db_user

# --- 4. 删除用户 ---
@router.delete("/{user_id}")
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # 权限保护：禁止删除同级或更高级别的账号
    if db_user.role <= current_admin.role and current_admin.role != 0:
        raise HTTPException(status_code=403, detail="Permission denied: Cannot delete an account at this level")

    if db_user.id == current_admin.id:
        raise HTTPException(status_code=400, detail="Administrative accounts cannot self-terminate")

    db.delete(db_user)
    db.commit()
    return {"status": "success", "message": f"User {user_id} purged"}

# --- 5. 用户修改自己的密码 ---
@router.patch("/me/change-password")
def change_my_password(
    new_password: str = Body(..., embed=True), # 通过请求体获取新密码，`embed=True` 表示直接从 JSON 根部解析
    db: Session = Depends(get_db), # 数据库会话依赖
    current_user: User = Depends(get_current_user) # 当前登录用户依赖，确保用户已认证
):
    """
    允许任何已登录用户修改自己的密码。
    这个接口主要用于：
    1. 用户首次登录时被强制修改默认密码。
    2. 用户主动修改自己的密码。
    """
    
    # 检查新密码是否仍为初始默认密码 "admin123"
    # 这是一个重要的安全措施，强制用户设置更复杂的密码
    if new_password == "admin123":
        raise HTTPException(status_code=400, detail="Cannot use default password, please set a more complex password")
    
    # 对新密码进行哈希处理
    current_user.password_hash = hash_password(new_password)
    
    # 提交数据库更改并返回成功信息
    db.commit()
    return {"status": "success", "message": "Password updated successfully"}