from typing import Any, Optional
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from datetime import datetime

from app.api import deps
from app.core.auth_utils import verify_password, create_access_token
from app.core.ratelimit import limiter
from app.models.users import User
from app.models.pos import POSMachine, POSActionLog
from app.models.org import Region
from app.models.config import ProviderConfig
from app.schemas.pos import POSLoginRequest

router = APIRouter()

def format_pos_sn(sn: str) -> str:
    sn = sn.strip()
    if len(sn) == 15:
        return "0" + sn
    return sn

@router.post("/login")
@limiter.limit("10/minute")
def pos_terminal_login(
    request: Request,
    req: POSLoginRequest,
    db: Session = Depends(deps.get_db)
) -> Any:
    """
    POS 终端专用登录接口：
    1. 验证用户名/密码
    2. 验证 POS SN 码是否存在且未锁定 (临时放行模式)
    3. 强绑定校验：Operator (Role 2) 只能在分配给自己的 POS 上登录
    """
    # --- 1. 验证 POS 机器状态 ---
    sn = format_pos_sn(req.pos_sn)
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == sn, POSMachine.is_deleted == False).first()
    
    # [BYPASS MODE] 临时放行未注册或已锁定的 SN 码，方便测试
    # --- 老的 SN 检测逻辑 (已注释) ---
    # if not pos:
    #     raise HTTPException(status_code=404, detail="POS Device not registered")
    # if pos.lock_status != 0:
    #     lock_msg = "Admin Locked" if pos.lock_status == 1 else "Finance Locked"
    #     raise HTTPException(status_code=403, detail=f"Device is locked ({lock_msg})")
    # ----------------------------

    # --- 2. 查找并验证用户 ---
    user = db.query(User).filter(User.username == req.username, User.is_deleted == False).first()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    
    if not user.is_active:
        raise HTTPException(status_code=400, detail="User account is disabled")

    # --- 3. 强绑定权限校验 (仅在机器已注册时校验) ---
    # Role 0: SuperAdmin, 1: Admin, 3: Finance, 4: Management 可以登录任何机器
    if pos and user.role not in [0, 1, 3, 4]:
        # Role 2: Operator (业务员) 必须检查绑定关系
        if pos.assigned_user_id != user.id:
            raise HTTPException(
                status_code=403, 
                detail="Login failed: This device is not assigned to your account."
            )

    # --- 4. 初始化状态检查 (保持与 login.py 一致) ---
    is_default_password = req.password == "admin123"
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

    # --- 5. 获取详细环境配置 (Provider & Hierarchy) ---
    daily_rate = 0.0
    region_name = ""
    hierarchy = {"municipality": "", "barangay": "", "purok": ""}
    
    if user.region_id:
        region = db.query(Region).filter(Region.id == user.region_id).first()
        if region:
            region_name = region.full_name
            # 解析层级名称 / Parse hierarchy names
            curr = region
            while curr:
                if curr.level == 0: hierarchy["municipality"] = curr.name
                elif curr.level == 1: hierarchy["barangay"] = curr.name
                elif curr.level == 2: hierarchy["purok"] = curr.name
                
                # 顺便寻找费率 (递归向上)
                if daily_rate == 0.0 and curr.daily_rate is not None:
                    daily_rate = float(curr.daily_rate)
                
                curr = curr.parent

    # 获取总公司/供应商信息
    provider = db.query(ProviderConfig).first()
    # 增加缓存刷新参数，确保 POS 每次登录都能拿到最新的 Logo
    ts = int(datetime.now().timestamp())
    provider_info = {
        "name": provider.name if provider else "SHS Provider",
        "tin": provider.tin if provider else "",
        "phone": provider.phone if provider else None,
        "address": provider.address if provider else "",
        "logo_url": f"{provider.logo_url}?t={ts}" if provider and provider.logo_url else f"/static/logo.png?t={ts}"
    }

    # --- 6. 生成 Token ---
    token_data = {"sub": str(user.id)}
    token = create_access_token(data=token_data)

    # --- 7. 更新 POS 机实时状态 (仅在机器已注册时执行) ---
    if pos:
        pos.last_login_at = datetime.now()
        pos.last_ip = request.client.host if request.client else "Unknown"
        if req.app_version: pos.app_version = req.app_version
        if req.version_type: pos.version_type = req.version_type
        if req.mac_address: pos.mac_address = req.mac_address
        if req.latitude: pos.latitude = req.latitude
        if req.longitude: pos.longitude = req.longitude

        # 记录登录日志
        log = POSActionLog(
            pos_sn=sn,
            action_type="POS_LOGIN",
            operator=user.username,
            role=str(user.role),
            remark=f"Login successful on device {sn}"
        )
        db.add(log)
    
    db.commit()

    return {
        "access_token": token,
        "token_type": "bearer",
        "setup_status": setup_status,
        "user_role": user.role,
        "username": user.username,
        "user_id": user.id,
        "daily_rate": daily_rate,
        "region_name": region_name,
        "hierarchy": hierarchy,
        "provider": provider_info,
        "pos_sn": sn
    }

@router.get("/check/{pos_sn}")
@limiter.limit("5/minute")
def check_pos_status(request: Request, pos_sn: str, db: Session = Depends(deps.get_db)):
    """
    POS 终端静默状态检查接口
    [BYPASS MODE] 临时改为永远返回 exists=True，无论该 SN 是否在库
    """
    sn = format_pos_sn(pos_sn)
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == sn, POSMachine.is_deleted == False).first()

    # --- 老的 SN 检测逻辑 (已注释) ---
    # if not pos:
    #     return {"exists": False, "message": "Device not registered"}
    # ----------------------------

    # 自动对账锁定逻辑 (仅对已存在的机器有效)
    if pos and pos.reconciliation_deadline and datetime.now() > pos.reconciliation_deadline:
        if pos.lock_status == 0:
            pos.lock_status = 2 
            db.commit()

    return {
        "exists": True, # 临时强制放行
        "pos_sn": sn,
        "lock_status": pos.lock_status if pos else 0,
        "reconciliation_deadline": pos.reconciliation_deadline if pos else None,
        "assigned_user_name": pos.assigned_user.username if (pos and pos.assigned_user) else None,
    }
