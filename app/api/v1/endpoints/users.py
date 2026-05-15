from fastapi import APIRouter, Depends, HTTPException, status, Body
from sqlalchemy.orm import Session, joinedload
from typing import List
from app.api.deps import get_db, get_current_user, get_finance_or_admin, get_current_admin_user

from app.models.users import User
from app.models.org import Region
from app.schemas.users import UserCreate, UserRead, UserUpdate
from app.core.auth_utils import hash_password

router = APIRouter()

def enrich_user_response(db: Session, user: User) -> dict:
    """辅助函数：为用户响应数据注入地区及子公司名称"""
    # 将模型转为字典，以便注入额外字段
    data = UserRead.model_validate(user).model_dump()
    target_id = user.region_id
    
    if target_id:
        # 联动查询：预加载关联的业务主体 (entity)
        region = db.query(Region).options(joinedload(Region.entity)).filter(Region.id == target_id).first()
        if region:
            if region.level == 2:
                data["town_name"] = region.name
                parent = db.query(Region).filter(Region.id == region.parent_id).first()
                data["city_name"] = parent.name if parent else None
            else:
                data["city_name"] = region.name
            
            # 核心改进：如果该地区关联了子公司，带入其名称
            if region.entity:
                data["entity_name"] = region.entity.name
                
    return data

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

    # 字段清洗与查重
    username = user_in.username.strip()
    email = user_in.email.strip() if user_in.email else None
    mobile = user_in.mobile.strip()

    if db.query(User).filter(User.username == username, User.is_deleted == False).first():
        raise HTTPException(status_code=400, detail="Username already registered")
    if email and db.query(User).filter(User.email == email, User.is_deleted == False).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if db.query(User).filter(User.mobile == mobile, User.is_deleted == False).first():
        raise HTTPException(status_code=400, detail="Mobile number already registered")
    
    user_data = user_in.model_dump()
    user_data["username"] = username
    user_data["email"] = email
    user_data["mobile"] = mobile

    password = user_data.pop("password")
    
    # 显式构建模型实例，确保 role 等字段被传入
    db_obj = User(
        **user_data,
        password_hash=hash_password(password)
    )

    # 验证分配的区域是否存在
    region_id = user_data.get("region_id")
    if region_id is not None and region_id != 0:
        region = db.query(Region).filter(Region.id == region_id).first()
        if not region:
            raise HTTPException(status_code=404, detail="Assigned region not found")
    
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return enrich_user_response(db, db_obj)

# --- 2. 获取用户列表 ---
@router.get("/", response_model=List[UserRead])
def read_users(
    db: Session = Depends(get_db), 
    current_admin: User = Depends(get_current_admin_user), 
    skip: int = 0, 
    limit: int = 100
):
    # 逻辑删除过滤：仅显示未删除的用户
    query = db.query(User).filter(User.is_deleted == False)
    # 隐私保护：不显示比自己级别更高的用户
    if current_admin.role == 1:
        query = query.filter(User.role != 0)

    users = query.offset(skip).limit(limit).all()
    
    # 这里可以进一步根据 current_admin 的地区权限过滤列表
    # 例如：如果管理员只能看自己市的用户...
    return [enrich_user_response(db, u) for u in users]

# --- 3. 更新用户 ---
@router.patch("/update", response_model=UserRead)
def update_user(
    user_id: int = Body(..., embed=True),
    user_in: UserUpdate = Body(...),
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    """更新用户信息 - ID 通过 Body 传递"""
    db_user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # 权限保护：禁止修改同级或更高级别的账号
    if db_user.role <= current_admin.role and db_user.id != current_admin.id and current_admin.role != 0:
        raise HTTPException(status_code=403, detail="Permission denied: Cannot modify a higher-level account")

    update_data = user_in.model_dump(exclude_unset=True)

    # 更新时检查 region_id 是否存在
    if "region_id" in update_data:
        rid = update_data["region_id"]
        if rid is not None and rid != 0:
            region = db.query(Region).filter(Region.id == rid).first()
            if not region:
                raise HTTPException(status_code=404, detail="Assigned region not found")

    if "password" in update_data:
        pw = update_data.pop("password")
        db_user.password_hash = hash_password(pw)

    for field, value in update_data.items():
        setattr(db_user, field, value)

    db.commit()
    db.refresh(db_user)
    return enrich_user_response(db, db_user)

# --- 4. 删除用户 ---
@router.delete("/delete")
def delete_user(
    user_id: int = Body(..., embed=True),
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    """逻辑删除用户 - ID 通过 Body 传递"""
    db_user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # 权限保护：禁止删除同级或更高级别的账号
    if db_user.role <= current_admin.role and current_admin.role != 0:
        raise HTTPException(status_code=403, detail="Permission denied: Cannot delete an account at this level")

    if db_user.id == current_admin.id:
        raise HTTPException(status_code=400, detail="Administrative accounts cannot self-terminate")

    # 执行逻辑删除
    db_user.is_deleted = True
    db.commit()
    return {"status": "success", "message": f"User {user_id} has been deactivated"}

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