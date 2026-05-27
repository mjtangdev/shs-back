from datetime import timedelta
from typing import Any
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel

# 1. 导入项目依赖
from app.api import deps
from app.core.config import settings
from app.core.auth_utils import verify_password, create_access_token, hash_password
from app.models.users import User
from app.models.org import Region      
from app.models.config import ProviderConfig 

router = APIRouter()

class LoginJSONRequest(BaseModel):
    username: str
    password: str

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
    user = db.query(User).filter(User.username == form_data.username, User.is_deleted == False).first()
    if not user:
        user = db.query(User).filter(User.email == form_data.username, User.is_deleted == False).first()

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
    # 将所有初始化项并入 setup_status，包括密码状态
    setup_status = {
        "password_updated": not is_default_password, # 检查是否已修改默认密码
        "region_set": True,
        "provider_config_set": True, # ✅ 新增：总公司配置检查
    }

    # 针对管理员 (role == 1) 额外检查业务数据初始化
    if user.role == 1:
        # 1. 检查地区初始化：不但要存在顶级区域，且该区域必须已被改名（非默认的 "Pangasinan"）
        # 这能确保管理员在系统启用前至少完成了一次地区配置
        province = db.query(Region).filter(Region.level == 0).first()
        if not province or province.name == "Pangasinan":
            setup_status["region_set"] = False
            
        # 3. 检查总公司配置 (不仅要有记录，且必须是已初始化状态)
        provider_config_exists = db.query(ProviderConfig).first()
        if not provider_config_exists or not provider_config_exists.is_initialized:
            setup_status["provider_config_set"] = False

    # --- [获取当前用户的费率和详细层级信息 (支持递归继承)] ---
    daily_rate = 0.0
    region_name = ""
    hierarchy = {"municipality": "", "barangay": "", "purok": ""}

    if user.region_id:
        region = db.query(Region).filter(Region.id == user.region_id).first()
        if region:
            region_name = region.full_name
            # 解析层级名称
            curr = region
            while curr:
                if curr.level == 0: hierarchy["municipality"] = curr.name
                elif curr.level == 1: hierarchy["barangay"] = curr.name
                elif curr.level == 2: hierarchy["purok"] = curr.name
                
                # 寻找费率
                if daily_rate == 0.0 and curr.daily_rate is not None:
                    daily_rate = float(curr.daily_rate)
                curr = curr.parent

    # 获取总公司信息
    provider = db.query(ProviderConfig).first()
    provider_info = {
        "company_name": provider.name if provider else "SHS Provider",
        "tin": provider.tin if provider else "",
        "logo_url": provider.logo_url if provider else None
    }

    # --- [第四步：生成 Token] ---
    token_data = {"sub": str(user.id)}
    token = create_access_token(data=token_data)

    # 返回结果中包含了详细的初始化状态
    return {
        "access_token": token,
        "token_type": "bearer",
        "setup_status": setup_status,
        "user_role": user.role,
        "username": user.username,
        "user_id": user.id,
        "region_id": user.region_id,
        "daily_rate": daily_rate,
        "region_name": region_name,
        "hierarchy": hierarchy,
        "provider": provider_info
    }


@router.post("/token-json")
def login_access_token_json(
    req: LoginJSONRequest,
    db: Session = Depends(deps.get_db)
) -> Any:
    """
    专门为前端提供的 JSON 格式登录接口。
    接收标准的 application/json 格式数据：{"username": "...", "password": "..."}
    """
    # --- [第一步：查找用户] ---
    user = db.query(User).filter(User.username == req.username, User.is_deleted == False).first()
    if not user:
        user = db.query(User).filter(User.email == req.username, User.is_deleted == False).first()

    if not user:
        raise HTTPException(status_code=400, detail="Incorrect username or email")
    
    # --- [第二步：验证密码] ---
    if not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect password")
    
    # 状态检查
    if not user.is_active:
        raise HTTPException(status_code=400, detail="User has been disabled")

    # --- [检测是否为初始默认密码] ---
    is_default_password = req.password == "admin123"

    # --- [第三步：初始化检查] ---
    setup_status = {
        "password_updated": not is_default_password,
        "region_set": True,
        "provider_config_set": True,
    }

    if user.role == 1:
        province = db.query(Region).filter(Region.level == 0).first()
        if not province or province.name == "Pangasinan":
            setup_status["region_set"] = False
            
        provider_config_exists = db.query(ProviderConfig).first()
        if not provider_config_exists or not provider_config_exists.is_initialized:
            setup_status["provider_config_set"] = False

    # --- [获取当前用户的费率和详细层级信息 (支持递归继承)] ---
    daily_rate = 0.0
    region_name = ""
    hierarchy = {"municipality": "", "barangay": "", "purok": ""}

    if user.region_id:
        region = db.query(Region).filter(Region.id == user.region_id).first()
        if region:
            region_name = region.full_name
            curr = region
            while curr:
                if curr.level == 0: hierarchy["municipality"] = curr.name
                elif curr.level == 1: hierarchy["barangay"] = curr.name
                elif curr.level == 2: hierarchy["purok"] = curr.name
                if daily_rate == 0.0 and curr.daily_rate is not None:
                    daily_rate = float(curr.daily_rate)
                curr = curr.parent

    provider = db.query(ProviderConfig).first()
    provider_info = {
        "company_name": provider.name if provider else "SHS Provider",
        "tin": provider.tin if provider else "",
        "logo_url": provider.logo_url if provider else None
    }

    # --- [第四步：生成 Token] ---
    token_data = {"sub": str(user.id)}
    token = create_access_token(data=token_data)

    return {
        "access_token": token,
        "token_type": "bearer",
        "setup_status": setup_status,
        "user_role": user.role,
        "username": user.username,
        "user_id": user.id,
        "region_id": user.region_id,
        "daily_rate": daily_rate,
        "region_name": region_name,
        "hierarchy": hierarchy,
        "provider": provider_info
    }

@router.post("/emergency-reset-admin")
def emergency_reset_admin_password(
    db: Session = Depends(deps.get_db), # 数据库会话依赖
    current_user: User = Depends(deps.get_current_super_admin) # ✅ 使用专门的超级管理员依赖
) -> Any:
    """
    重置客户管理员密码。

    此接口仅限供应商超级管理员 (Role 0) 登录后执行。
    用途：用于供应商在远程支持时，帮客户重置丢失的 admin (Role 1) 账号密码为默认密码 'admin123'。
    """
    admin_user = db.query(User).filter(User.username == "admin").first()
    if not admin_user:
        raise HTTPException(status_code=404, detail="Super administrator user does not exist.")

    # 重置超级管理员密码为默认的 "admin123"
    admin_user.password_hash = hash_password("admin123")
    db.commit()

    # 记录操作日志（可以在控制台看到是哪个供应商账号干的）
    print(f"SECURITY EVENT: Supplier User [{current_user.username}] reset the customer admin password.")

    return {"status": "success", "message": "客户管理员密码已重置为 'admin123'"}