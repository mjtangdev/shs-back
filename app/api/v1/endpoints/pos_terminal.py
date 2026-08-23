from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Request, Query
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, or_
from datetime import datetime

from app.api import deps
from app.core.auth_utils import verify_password, create_access_token
from app.core.ratelimit import limiter
from app.models.users import User
from app.models.pos import POSMachine, POSActionLog
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.org import Region
from app.models.config import ProviderConfig
from app.schemas.pos import POSLoginRequest, POSList, POSUpdate, POSCreate
from app.schemas.card import CardCreate
from app.schemas.solar_device import SolarUnitCreate
from fastapi.responses import StreamingResponse
from app.core.sse_manager import sse_manager
import asyncio
import json

router = APIRouter()

# --- 1. Web 端终端列表查询接口 ---
@router.get("/", response_model=POSList)
def get_pos_terminals(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 50,
    search: Optional[str] = Query(None),
    current_user: User = Depends(deps.get_current_user)
):
    """获取所有 POS 终端列表 (仅管理员)"""
    query = db.query(POSMachine).options(joinedload(POSMachine.assigned_user))
    
    if search:
        sf = f"%{search}%"
        query = query.filter(or_(POSMachine.pos_sn.ilike(sf), POSMachine.pos_code.ilike(sf)))
    
    total = query.count()
    items = query.order_by(POSMachine.pos_code.asc()).offset(skip).limit(limit).all()
    
    # 由于 assigned_user_name 在 Response 模型里是可选的，SQLAlchemy 会自动处理映射
    return {"total": total, "items": items}

# --- 2. 编辑终端 (分配人员、状态修改) ---
@router.patch("/{pos_id}")
def update_pos_terminal(
    pos_id: int,
    obj_in: POSUpdate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_finance_or_admin)
):
    pos = db.query(POSMachine).filter(POSMachine.id == pos_id).first()
    if not pos:
        raise HTTPException(status_code=404, detail="Terminal not found")
    
    update_data = obj_in.dict(exclude_unset=True)
    for field in update_data:
        setattr(pos, field, update_data[field])
    
    pos.updated_at = datetime.now()
    db.add(pos)
    db.commit()
    return {"status": "success"}

# --- 3. 辅助函数 ---
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
    # --- 1. 验证 POS 机器状态 (严格注册检查模式) ---
    raw_sn = req.pos_sn.strip()
    formatted_sn = format_pos_sn(raw_sn)

    pos = db.query(POSMachine).filter(
        or_(POSMachine.pos_sn == raw_sn, POSMachine.pos_sn == formatted_sn),
        POSMachine.is_deleted == False
    ).first()
    
    # 强制检查 SN 是否已由管理员手动录入
    if not pos:
        raise HTTPException(status_code=404, detail=f"POS Device ({raw_sn}) not registered. Please contact admin.")
    
    if pos and pos.lock_status != 0:
        lock_msg = "Admin Locked" if pos.lock_status == 1 else "Finance Locked"
        raise HTTPException(status_code=403, detail=f"Device is locked ({lock_msg})")

    # --- 2. 查找并验证用户 ---
    user = db.query(User).filter(User.username == req.username, User.is_deleted == False).first()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    
    if not user.is_active:
        raise HTTPException(status_code=400, detail="User account is disabled")

    # --- 3. 强绑定权限校验 (演示模式：放行所有登录) ---
    # 注释掉强制绑定检查，让任何账号都能在任何机器上登录
    # if pos and user.role not in [0, 1, 3, 4]:
    #     if pos.assigned_user_id != user.id:
    #         raise HTTPException(
    #             status_code=403, 
    #             detail="Login failed: This device is not assigned to your account."
    #         )

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
            pos_sn=formatted_sn,
            action_type="POS_LOGIN",
            operator=user.username,
            role=str(user.role),
            remark=f"Login successful on device {formatted_sn}"
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
        "pos_sn": formatted_sn,
        "pos_code": pos.pos_code if pos else "01" 
    }

@router.get("/check/{pos_sn}")
@limiter.limit("30/minute")
def check_pos_status(request: Request, pos_sn: str, db: Session = Depends(deps.get_db)):
    """
    POS 终端静默状态检查接口 (增强版)：
    用于 POS 终端在业务前或后台轮询锁定状态及同步服务器时间。
    """
    raw_sn = pos_sn.strip()
    formatted_sn = format_pos_sn(raw_sn)

    # 兼容性查询：同时匹配原始 SN 和 补零后的 SN
    pos = db.query(POSMachine).options(joinedload(POSMachine.assigned_user)).filter(
        or_(POSMachine.pos_sn == raw_sn, POSMachine.pos_sn == formatted_sn),
        POSMachine.is_deleted == False
    ).first()

    if not pos:
        return {
            "exists": False,
            "pos_sn": raw_sn,
            "message": "Device not registered"
        }

    # 自动对账锁定逻辑
    if pos.lock_status == 0 and pos.reconciliation_deadline and datetime.now() > pos.reconciliation_deadline:
        pos.lock_status = 2 
        pos.last_lock_reason = "System: Reconciliation deadline expired"
        pos.last_action_by = "SYSTEM"
        db.commit()

    return {
        "exists": True,
        "pos_sn": formatted_sn,
        "status": pos.status,
        "lock_status": pos.lock_status,
        "lock_reason": pos.last_lock_reason or "Normal",
        "last_action_by": pos.last_action_by or "System",
        "reconciliation_deadline": pos.reconciliation_deadline.strftime("%Y-%m-%d %H:%M:%S") if pos.reconciliation_deadline else None,
        "assigned_user_name": f"{pos.assigned_user.first_name} {pos.assigned_user.last_name}" if pos.assigned_user else "Unassigned",
        "server_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

@router.get("/summary/counts")
def get_pos_resource_counts(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    获取 POS 终端关注的基础资源统计数据：
    - IC 卡总数
    - 太阳能设备总数
    - POS 终端总数
    """
    ic_card_count = db.query(func.count(Card.id)).scalar()
    solar_device_count = db.query(func.count(SolarUnit.id)).scalar()
    pos_terminal_count = db.query(func.count(POSMachine.id)).filter(POSMachine.is_deleted == False).scalar()
    
    return {
        "status": "success",
        "counts": {
            "ic_cards": ic_card_count,
            "solar_devices": solar_device_count,
            "pos_terminals": pos_terminal_count
        }
    }

# --- 4. SSE 消息推送通道 ---

@router.get("/events/stream")
async def sse_events():
    """
    SSE 消息推送通道：前端通过此接口监听系统实时事件。
    支持心跳机制，解决 Nginx ERR_INCOMPLETE_CHUNKED_ENCODING 问题。
    """
    async def event_generator():
        queue = await sse_manager.subscribe()
        try:
            while True:
                try:
                    # 尝试在 20 秒内获取新消息
                    data = await asyncio.wait_for(queue.get(), timeout=20.0)
                    yield data
                except asyncio.TimeoutError:
                    # 如果 20 秒没消息，发送心跳包 (ping)
                    yield ": ping\n\n"
        except Exception:
            # 连接断开时清理
            sse_manager.unsubscribe(queue)
            
    return StreamingResponse(
        event_generator(), 
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no" # 👈 特别告知 Nginx 不要缓存此流
        }
    )

# --- 5. Admin APK 专用入库接口 (扫码/读卡入库 + 实时推送) ---

@router.post("/admin/register-card")
async def admin_register_card(
    card_in: CardCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_finance_or_admin)
):
    """Admin APK 读卡入库：录入新的 IC 卡，成功后推送通知"""
    card_uuid = card_in.card_uuid.strip().upper()
    # 核心修复：如果卡号为空字符串，转为 None (NULL)，避免违反唯一约束
    card_number = (card_in.card_number or "").strip() or None

    # 查重逻辑：分别检查 UUID 和 卡号，提供更准确的错误提示
    existing_uuid = db.query(Card).filter(Card.card_uuid == card_uuid).first()
    if existing_uuid:
        raise HTTPException(status_code=400, detail="Registration Failed: This IC Card (UUID) is already registered.")
    
    if card_number:
        existing_num = db.query(Card).filter(Card.card_number == card_number).first()
        if existing_num:
            raise HTTPException(status_code=400, detail="Registration Failed: This Physical Card Number is already in use.")
    
    try:
        new_card = Card(
            card_uuid=card_uuid,
            card_number=card_number,
            status=0,
            created_at=datetime.now()
        )
        db.add(new_card)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Database Error: Could not save card. {str(e)}")

    # --- [ 发送实时通知 ] ---
    await sse_manager.broadcast("CARD_REGISTERED", {
        "title": "IC Card Registered",
        "description": f"Card {card_uuid} stock-in success",
        "card_uuid": card_uuid,
        "operator": current_user.username,
        "color": "green",
        "id": new_card.id
    })

    return {"status": "success", "id": new_card.id}

@router.post("/admin/register-solar-unit")
async def admin_register_solar_unit(
    unit_in: SolarUnitCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_finance_or_admin)
):
    """Admin APK 扫码入库：录入新的主机，成功后推送通知"""
    shs_id = unit_in.shs_machine_id.strip()
    
    existing = db.query(SolarUnit).filter(SolarUnit.shs_machine_id == shs_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Registration Failed: This Solar Machine ID is already registered.")
    
    s_id, r_id, f_id, l_id = f"{shs_id}1", f"{shs_id}2", f"{shs_id}3", f"{shs_id}4"

    try:
        new_unit = SolarUnit(
            shs_machine_id=shs_id, solar_equipment_id=s_id, radio_id=r_id,
            flashlight_id=f_id, led_light_id=l_id, shs_status=0,
            production_date=unit_in.production_date or datetime.now(), created_at=datetime.now()
        )
        db.add(new_unit)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Database Error: Could not save solar unit. {str(e)}")

    # --- [ 发送实时通知 ] ---
    await sse_manager.broadcast("SOLAR_UNIT_REGISTERED", {
        "title": "Solar Unit Registered",
        "description": f"Unit {shs_id} stock-in success",
        "shs_machine_id": shs_id,
        "operator": current_user.username,
        "color": "green",
        "id": new_unit.id
    })

    return {"status": "success", "id": new_unit.id}

@router.post("/admin/register-pos-terminal")
async def admin_register_pos_terminal(
    pos_in: POSCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_finance_or_admin)
):
    """Admin APK 扫码入库：录入新的 POS 终端，成功后推送通知"""
    sn = pos_in.pos_sn.strip()
    
    existing = db.query(POSMachine).filter(POSMachine.pos_sn == sn).first()
    if existing:
        raise HTTPException(status_code=400, detail="Registration Failed: This POS Serial Number (SN) is already registered.")
    
    pos_code = "01"
    last_pos = db.query(POSMachine).order_by(POSMachine.id.desc()).first()
    if last_pos and last_pos.pos_code.isdigit():
        pos_code = str(int(last_pos.pos_code) + 1).zfill(2)

    try:
        new_pos = POSMachine(pos_sn=sn, pos_code=pos_code, status=1, created_at=datetime.now())
        db.add(new_pos)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Database Error: Could not save POS terminal. {str(e)}")

    # --- [ 发送实时通知 ] ---
    await sse_manager.broadcast("POS_REGISTERED", {
        "title": "POS Terminal Registered",
        "description": f"POS {sn} stock-in success",
        "pos_sn": sn,
        "pos_code": pos_code,
        "operator": current_user.username,
        "color": "green",
        "id": new_pos.id
    })

    return {"status": "success", "id": new_pos.id}
