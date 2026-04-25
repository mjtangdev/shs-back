from datetime import timedelta
from typing import Any
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

# 1. 导入项目依赖
from app.api import deps
from app.core.config import settings
from app.core.auth_utils import verify_password, create_access_token, hash_password
from app.models.users import User      
from app.models.org import Region      
from app.models.config import GlobalRate  # ✅ 新增：导入费率模型

router = APIRouter()

@router.post("/token")
def login_access_token(
    db: Session = Depends(deps.get_db), 
    form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """
    定制登录逻辑：
    - 验证用户身份
    - 管理员登录时额外检查系统初始化状态 (地区 + 费率)
    """
    
    # --- [第一步：查找用户] ---
    user = db.query(User).filter(User.username == form_data.username).first()
    if not user:
        user = db.query(User).filter(User.email == form_data.username).first()

    if not user:
        raise HTTPException(status_code=400, detail="Incorrect username or email")
    
    # --- [第二步：验证密码] ---
    if not verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect password")
    
    # 状态检查
    if not user.is_active:
        raise HTTPException(status_code=400, detail="User has been disabled")

    # --- [检测是否为初始默认密码] ---
    is_default_password = form_data.password == "admin123"

    # --- [第三步：初始化检查] ---
    # 定义详细的初始化状态，方便前端展示具体的缺失项
    setup_status = {
        "region_set": True,
        "rate_set": True
    }
    need_init = False

    # 仅针对管理员 (role == 1) 进行检查
    if user.role == 1:
        # 1. 检查地区（是否至少有一个省份记录）
        province_exists = db.query(Region).filter(Region.level == 0).first()
        if not province_exists:
            setup_status["region_set"] = False
            need_init = True
            
        # 2. 检查费率（是否至少有一条费率记录）
        rate_exists = db.query(GlobalRate).first()
        if not rate_exists:
            setup_status["rate_set"] = False
            need_init = True

    # --- [第四步：生成 Token] ---
    token_data = {"sub": str(user.id)}
    token = create_access_token(data=token_data)

    # 返回结果中包含了详细的初始化状态
    return {
        "access_token": token,
        "token_type": "bearer",
        "need_init": need_init,
        "setup_status": setup_status,  # ✅ 新增：告诉前端到底是哪个没设
        "is_default_password": is_default_password, # ✅ 新增：标记是否需要强制改密
        "user_role": user.role,        # ✅ 新增：方便前端做权限分流
        "username": user.username
    }


@router.post("/emergency-reset-admin")
def emergency_reset_admin_password(
    db: Session = Depends(deps.get_db), # 数据库会话依赖
    current_user: User = Depends(deps.get_current_user) # 必须是已登录用户
) -> Any:
    """
    重置客户管理员密码。

    此接口仅限供应商超级管理员 (Role 0) 登录后执行。
    用途：用于供应商在远程支持时，帮客户重置丢失的 admin (Role 1) 账号密码为默认密码 'admin123'。
    """
    # 权限校验：只有角色为 0 的供应商账号可以操作
    if current_user.role != 0:
        raise HTTPException(
            status_code=403, 
            detail="Permission denied: This reset operation is limited to Suppliers (Role 0)"
        )

    admin_user = db.query(User).filter(User.username == "admin").first()
    if not admin_user:
        raise HTTPException(status_code=404, detail="Super administrator user does not exist.")

    # 重置超级管理员密码为默认的 "admin123"
    admin_user.password_hash = hash_password("admin123")
    db.commit()

    # 记录操作日志（可以在控制台看到是哪个供应商账号干的）
    print(f"SECURITY EVENT: Supplier User [{current_user.username}] reset the customer admin password.")

    return {"status": "success", "message": "客户管理员密码已重置为 'admin123'"}