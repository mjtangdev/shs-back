from fastapi import APIRouter, Depends, HTTPException, status, Body
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
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
    
    # 注入绑定的 POS 信息
    if user.pos_machine:
        data["pos_sn"] = user.pos_machine.pos_sn
                
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
        
        # 核心逻辑：业务员 (Role 2) 必须且只能分配到第三层级 (Purok, level=2)
        if user_in.role == 2:
            if region.level != 2:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Invalid Assignment: Operators must be assigned to a Purok (Level 3). Selected region '{region.name}' is at level {region.level + 1}."
                )
    
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

    users = query.order_by(User.id.desc()).offset(skip).limit(limit).all()
    
    # 这里可以进一步根据 current_admin 的地区权限过滤列表
    # 例如：如果管理员只能看自己市的用户...
    return [enrich_user_response(db, u) for u in users]


@router.get("/{user_id}", response_model=UserRead)
def read_user_by_id(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    """根据 ID 获取特定用户信息"""
    user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # 权限保护：禁止普通管理员查看比自己高级别或同级别的账号详细隐私
    if user.role <= current_admin.role and user.id != current_admin.id and current_admin.role != 0:
         # 允许查看，但可能需要脱敏？这里暂时允许查看，因为编辑页面需要数据
         pass
         
    return enrich_user_response(db, user)

# --- 3. 更新用户 ---
def _perform_user_update(db: Session, db_user: User, user_in: UserUpdate, current_admin: User):
    """内部通用的用户更新逻辑"""
    # 权限保护：禁止修改同级或更高级别的账号
    if db_user.role <= current_admin.role and db_user.id != current_admin.id and current_admin.role != 0:
        raise HTTPException(status_code=403, detail="Permission denied: Cannot modify a higher-level account")

    update_data = user_in.model_dump(exclude_unset=True)
    update_data.pop("user_id", None) # ID 已在外部提取，此处移除防止干扰

    if "region_id" in update_data:
        rid = update_data["region_id"]
        if rid is not None and rid != 0:
            region = db.query(Region).filter(Region.id == rid).first()
            if not region: raise HTTPException(status_code=404, detail="Region not found")
            target_role = update_data.get("role", db_user.role)
            if target_role == 2 and region.level != 2:
                raise HTTPException(status_code=400, detail="Operators must be assigned to a Purok")

    if "password" in update_data:
        pw = update_data.pop("password")
        if pw and pw.strip():
            if pw == "admin123":
                 raise HTTPException(status_code=400, detail="Cannot use default password")
            db_user.password_hash = hash_password(pw)

    for field, value in update_data.items():
        if hasattr(db_user, field): setattr(db_user, field, value)

    db.commit()
    db.refresh(db_user)
    return db_user

@router.patch("/update", response_model=UserRead)
def update_user_body(
    user_in: UserUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    """更新用户 (通过 Body 传 ID)"""
    db_user = db.query(User).filter(User.id == user_in.user_id, User.is_deleted == False).first()
    if not db_user: raise HTTPException(status_code=404, detail="User not found")
    updated = _perform_user_update(db, db_user, user_in, current_admin)
    return enrich_user_response(db, updated)

@router.patch("/{user_id}", response_model=UserRead)
def update_user_path(
    user_id: int,
    user_in: UserUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    """更新用户 (通过路径传 ID)"""
    db_user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not db_user: raise HTTPException(status_code=404, detail="User not found")
    updated = _perform_user_update(db, db_user, user_in, current_admin)
    return enrich_user_response(db, updated)

# --- 4. 删除用户 ---
@router.delete("/delete")
def delete_user(
    user_id: int = Body(..., embed=True),
    admin_password: str = Body(..., embed=True),
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user)
):
    """逻辑删除用户 - 自动解绑 POS 且需要管理员密码"""
    from app.core.auth_utils import verify_password

    # 1. 验证管理员密码
    if not verify_password(admin_password, current_admin.password_hash):
        raise HTTPException(status_code=401, detail="Administrative authorization failed: Incorrect password")

    # 2. 查找目标用户
    db_user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # 3. 权限保护：禁止删除同级或更高级别的账号
    if db_user.role <= current_admin.role and db_user.id != current_admin.id and current_admin.role != 0:
        raise HTTPException(status_code=403, detail="Permission denied: Cannot delete an account at this level")

    if db_user.id == current_admin.id:
        raise HTTPException(status_code=400, detail="Administrative accounts cannot self-terminate")

    # 4. 自动解绑关联资产 (POS)
    if db_user.pos_machine:
        pos = db_user.pos_machine
        pos.assigned_user_id = None
        pos.status = 0  # 自动回库
        db.add(pos)
        logger.info(f"📋 User {db_user.username} deleted. POS {pos.pos_sn} automatically unassigned and returned to stock.")

    # 5. 执行逻辑删除
    db_user.is_active = False
    db_user.is_deleted = True
    db.commit()
    return {"status": "success", "message": f"User {db_user.username} deactivated and unassigned"}

# --- 5. 用户修改自己的密码 ---
@router.patch("/me/change-password")
def change_my_password(
    password: str = Body(None, embed=True), # 兼容通用字段名
    new_password: str = Body(None, embed=True), # 兼容当前参数名
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    允许任何已登录用户修改自己的密码。
    支持 'password' 或 'new_password' 字段名。
    """
    final_password = new_password or password
    if not final_password:
        raise HTTPException(status_code=400, detail="New password is required")

    if final_password == "admin123":
        raise HTTPException(status_code=400, detail="Cannot use default password, please set a more complex password")

    current_user.password_hash = hash_password(final_password)
    db.commit()
    return {"status": "success", "message": "Password updated successfully"}
