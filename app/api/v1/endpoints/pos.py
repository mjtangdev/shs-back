import io
import pandas as pd
from datetime import datetime, timedelta
from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, Body
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, func

from app.api.deps import get_db, get_current_user, get_finance_or_admin
from app.models.pos import POSMachine, POSActionLog
from app.models.users import User
from app.schemas.pos import POSCreate, POSUpdate, POSResponse, POSList, POSLockRequest, POSLogResponse
from app.core.ratelimit import limiter
from fastapi import Request

router = APIRouter()

# 内部辅助：统一日志记录
def record_log(db: Session, sn: str, action: str, user: Any, remark: str = None):
    log = POSActionLog(
        pos_sn=sn,
        action_type=action,
        operator=getattr(user, 'username', str(user)),
        role=getattr(user, 'role', None),
        remark=remark
    )
    db.add(log)


# 内部辅助：SN 码格式化 (自动补 0)
def format_pos_sn(sn: str) -> str:
    sn = sn.strip()
    if len(sn) == 15:
        return "0" + sn
    return sn


# --- 0. 公开查询接口 (用于 POS 静默检测与心跳) ---
@router.get("/check/{pos_sn}")
@limiter.limit("30/minute")
def check_pos_existence(request: Request, pos_sn: str, db: Session = Depends(get_db)):
    """
    公开接口：查询 POS 是否在系统中登记及当前状态。
    支持频率：30次/分钟 (足以应对网络重试)
    """
    sn = format_pos_sn(pos_sn)
    pos = db.query(POSMachine).options(joinedload(POSMachine.assigned_user)).filter(POSMachine.pos_sn == sn, POSMachine.is_deleted == False).first()

    if not pos:
        return {
            "exists": False,
            "pos_sn": sn,
            "message": "Device not registered"
        }

    # --- 自动对账锁定逻辑 (仅在正常状态下触发检查) ---
    if pos.lock_status == 0 and pos.reconciliation_deadline and datetime.now() > pos.reconciliation_deadline:
        pos.lock_status = 2  # 自动设为财务锁
        pos.last_lock_reason = "System: Reconciliation deadline expired"
        pos.last_action_by = "SYSTEM"
        record_log(db, pos.pos_sn, "AUTO_LOCK", "SYSTEM", "Reconciliation deadline expired")
        db.commit()

    return {
        "exists": True,
        "pos_sn": pos.pos_sn,
        "status": pos.status,
        "lock_status": pos.lock_status,
        "lock_reason": pos.last_lock_reason or "Normal",
        "last_action_by": pos.last_action_by or "System",
        "branch_office": pos.branch_office,
        "reconciliation_deadline": pos.reconciliation_deadline.strftime("%Y-%m-%d %H:%M:%S") if pos.reconciliation_deadline else None,
        "assigned_user_name": f"{pos.assigned_user.first_name} {pos.assigned_user.last_name}" if pos.assigned_user else "Unassigned",
        "server_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }


@router.get("/sync-status/{pos_sn}")
def get_pos_heartbeat_status(
    pos_sn: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    POS 专用同步接口：
    POS 终端应每隔 15-30 秒调用此接口
    """
    sn = format_pos_sn(pos_sn)
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == sn, POSMachine.is_deleted == False).first()
    
    if not pos:
        raise HTTPException(status_code=404, detail="Device not registered")

    return {
        "is_locked": pos.lock_status != 0,
        "lock_type": pos.lock_status,
        "lock_reason": pos.last_lock_reason,
        "user_active": current_user.is_active,
        "server_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }


# --- 1. 查询列表 ---
@router.get("/", response_model=POSList)
def get_pos(
    db: Session = Depends(get_db), 
    skip: int = 0, 
    limit: int = 50, 
    search: Optional[str] = None,
    current_user: Any = Depends(get_finance_or_admin)
):
    query = db.query(POSMachine).options(joinedload(POSMachine.assigned_user)).filter(POSMachine.is_deleted == False)
    if search:
        sf = f"%{search}%"
        query = query.filter(or_(POSMachine.pos_sn.ilike(sf), POSMachine.branch_office.ilike(sf)))
    
    total = query.count()
    items = query.order_by(POSMachine.created_at.desc()).offset(skip).limit(limit).all()
    
    # 填充分配的用户名
    for item in items:
        if item.assigned_user:
            item.assigned_user_name = f"{item.assigned_user.first_name} {item.assigned_user.last_name}"

    return {"total": total, "items": items}

# --- 2. 手动创建 POS (全员开放以便排查) ---
@router.post("/create")
def create_pos(
    pos_in: POSCreate, 
    db: Session = Depends(get_db), 
    user: Any = Depends(get_current_user)
):
    sn = format_pos_sn(pos_in.pos_sn)
    if len(sn) != 16:
        raise HTTPException(400, "POS SN must be 16 digits (or 15 with leading zero)")

    existing = db.query(POSMachine).filter(POSMachine.pos_sn == sn).first()
    if existing:
        if existing.is_deleted:
            # 如果机器曾被删除，则复活它
            existing.is_deleted = False
            existing.status = 1 if pos_in.assigned_user_id else (pos_in.status or 0)
            existing.branch_office = pos_in.branch_office
            existing.assigned_user_id = pos_in.assigned_user_id
            record_log(db, sn, "CREATE_RECOVER", user, "Re-activated deleted device")
        else:
            # 这里的 400 之前可能会导致 CORS 报错
            raise HTTPException(status_code=400, detail=f"POS SN {sn} already exists in system")
    else:
        # 自动生成 pos_code (查找当前最大值并递增)
        max_code = db.query(func.max(POSMachine.pos_code)).filter(POSMachine.pos_code >= '10').scalar()
        next_code = str(int(max_code) + 1) if max_code else '10'
        
        # 正常创建新机器
        new_pos = POSMachine(
            pos_sn=sn,
            pos_code=next_code, # 👈 补全必填字段
            branch_office=pos_in.branch_office,
            status=1 if pos_in.assigned_user_id else (pos_in.status or 0),
            assigned_user_id=pos_in.assigned_user_id,
            created_by=getattr(user, 'username', 'admin')
        )
        db.add(new_pos)
        record_log(db, sn, "CREATE", user, f"Manually created device{' and assigned' if pos_in.assigned_user_id else ''}")

    db.commit()
    return {"status": "success", "pos_sn": sn}

# --- 3. 编辑 POS (PATCH / {pos_sn}) ---
@router.patch("/{pos_sn}")
def update_pos(
    pos_sn: str,
    pos_in: POSUpdate,
    db: Session = Depends(get_db),
    user: Any = Depends(get_finance_or_admin)
):
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == pos_sn, POSMachine.is_deleted == False).first()
    if not pos:
        raise HTTPException(404, "Device not found")

    update_data = pos_in.dict(exclude_unset=True)
    
    # 记录修改日志的备注
    changes = []
    for field, value in update_data.items():
        # 1. 自动同步逻辑：assigned_user_id -> status
        if field == "assigned_user_id":
            if value and pos.status == 0:
                pos.status = 1 # 自动设为 Assigned
                changes.append("status: 0 -> 1 (Auto-assign)")
            elif not value and pos.status == 1:
                pos.status = 0 # 自动回库
                changes.append("status: 1 -> 0 (Auto-unassign)")

        # 2. 自动同步逻辑：根据 lock_status 记录专门的审计动作
        if field == "lock_status" and value != pos.lock_status:
            action = "LOCK" if value != 0 else "UNLOCK"
            changes.append(f"Security: {pos.lock_status} -> {value}")
            # 注意：这里我们只把变化加入备注，PATCH 接口的主动作仍是 UPDATE

        old_val = getattr(pos, field)
        if old_val != value:
            setattr(pos, field, value)
            changes.append(f"{field}: {old_val} -> {value}")

    if changes:
        record_log(db, pos_sn, "UPDATE", user, " | ".join(changes))
        db.commit()
        db.refresh(pos)

    return {"status": "success", "pos_sn": pos_sn}

# --- 4. 独立锁定 (支持任意 Admin 密码授权) ---
@router.post("/lock")
def lock_pos(
    req: POSLockRequest, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_finance_or_admin)
):
    from app.core.security import verify_password
    
    # 查找所有管理员 (Role 0 或 1)
    admins = db.query(User).filter(User.role.in_([0, 1]), User.is_active == True, User.is_deleted == False).all()
    
    # 校验密码是否匹配任意一个管理员
    authorized_admin = next((a for a in admins if verify_password(req.password, a.password_hash)), None)
    
    if not authorized_admin:
        raise HTTPException(401, "Authorization failed: No administrator account matches this password")

    pos = db.query(POSMachine).filter(POSMachine.pos_sn == req.pos_sn, POSMachine.is_deleted == False).first()
    if not pos: raise HTTPException(404, "Device not found")
    
    # 锁定设备
    pos.lock_status = 1 if authorized_admin.role in [0, 1] else 2
    pos.last_lock_reason = req.remark or "Manual security lockout"
    pos.last_action_by = current_user.username
    
    # 审计日志：记录是谁授权的，备注中记录执行者
    record_log(db, pos.pos_sn, "MANUAL_LOCK", authorized_admin, 
               f"Authorized by {authorized_admin.username}. Executed by {current_user.username}. Remark: {req.remark}")
    
    db.commit()
    return {"status": "success", "lock_status": pos.lock_status, "authorized_by": authorized_admin.username}

# --- 5. 独立解锁 (支持任意 Admin 密码授权) ---
@router.post("/unlock")
def unlock_pos(
    req: POSLockRequest, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_finance_or_admin)
):
    from app.core.security import verify_password
    
    admins = db.query(User).filter(User.role.in_([0, 1]), User.is_active == True, User.is_deleted == False).all()
    authorized_admin = next((a for a in admins if verify_password(req.password, a.password_hash)), None)
    
    if not authorized_admin:
        raise HTTPException(401, "Authorization failed: No administrator account matches this password")

    pos = db.query(POSMachine).filter(POSMachine.pos_sn == req.pos_sn).first()
    if not pos: raise HTTPException(404, "Device not found")
    
    pos.lock_status = 0
    pos.last_lock_reason = req.remark or "Manual security restoration"
    pos.last_action_by = current_user.username
    record_log(db, pos.pos_sn, "MANUAL_UNLOCK", authorized_admin, 
               f"Authorized by {authorized_admin.username}. Executed by {current_user.username}. Remark: {req.remark}")
    
    db.commit()
    return {"status": "success", "authorized_by": authorized_admin.username}

# --- 6. 软删除 (Finance/Admin) ---
@router.delete("/{pos_sn}")
def delete_pos(pos_sn: str, db: Session = Depends(get_db), user: Any = Depends(get_finance_or_admin)):
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == pos_sn).first()
    if not pos: raise HTTPException(404, "Device not found")
    
    # 保护逻辑：已分配(status=1)的 POS 不允许直接删除
    if pos.status == 1:
        raise HTTPException(status_code=400, detail="Cannot delete an assigned POS terminal. Please unassign it first.")

    pos.is_deleted = True
    record_log(db, pos_sn, "DELETE", user, "Soft deleted from system")
    db.commit()
    return {"status": "success", "message": "Device hidden, logs preserved"}

# --- 7. 获取操作记录 ---
@router.get("/{pos_sn}/logs", response_model=List[POSLogResponse])
def get_pos_logs(
    pos_sn: str, 
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
):
    return db.query(POSActionLog).filter(POSActionLog.pos_sn == pos_sn).order_by(POSActionLog.timestamp.desc()).all()

# --- 8. 批量导入 ---
@router.post("/import")
async def import_pos(
    file: UploadFile = File(...), 
    db: Session = Depends(get_db), 
    user: Any = Depends(get_finance_or_admin)
):
    contents = await file.read()
    df = pd.read_excel(io.BytesIO(contents), dtype=str)
    df = df.where(pd.notnull(df), None)
    df.columns = [str(c).strip().lower().replace(" ", "_") for c in df.columns]

    batch_count = 0
    for _, row in df.iterrows():
        raw_sn = str(row.get('pos_sn', '')).strip()
        sn = format_pos_sn(raw_sn)
        
        if len(sn) == 16:
            existing = db.query(POSMachine).filter(POSMachine.pos_sn == sn).first()
            if existing:
                if existing.is_deleted:
                    existing.is_deleted = False
                    existing.status = 0
                    record_log(db, sn, "RE-IMPORT", user, "Device re-activated via import")
            else:
                new_pos = POSMachine(pos_sn=sn, created_by=user.username)
                db.add(new_pos)
                record_log(db, sn, "IMPORT", user, "New device registered")
            batch_count += 1
    
    db.commit()
    return {"status": "success", "imported": batch_count}

# --- 9. 导出 Excel ---
@router.get("/export")
def export_pos(
    db: Session = Depends(get_db), 
    current_user: Any = Depends(get_finance_or_admin)
):
    machines = db.query(POSMachine).filter(POSMachine.is_deleted == False).all()
    rows = []
    for p in machines:
        rows.append({
            "POS SN": p.pos_sn,
            "Status": {0: "In Stock", 1: "Assigned", 2: "Damaged"}.get(p.status, "Unknown"),
            "Lock Status": {0: "Normal", 1: "Admin Locked", 2: "Fina Locked"}.get(p.lock_status, "Normal"),
            "Region ID": p.region_id or "-",
            "Branch Office": p.branch_office or "-",
            "Created Date": p.created_at.strftime("%Y-%m-%d %H:%M") if p.created_at else "-"
        })

    df = pd.DataFrame(rows)
    out = io.BytesIO()
    with pd.ExcelWriter(out, engine='openpyxl') as w:
        df.to_excel(w, index=False)
    out.seek(0)
    
    file_name = f"POS_Export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
    return StreamingResponse(
        out, 
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={file_name}"}
    )


from app.models.transaction import TransactionLog
from sqlalchemy import func

# --- 10. 财务对账操作 ---

@router.post("/{pos_sn}/reconcile")
def confirm_reconciliation(
    pos_sn: str,
    next_deadline: Optional[datetime] = Body(None, embed=True),
    db: Session = Depends(get_db),
    user: Any = Depends(get_finance_or_admin)
):
    """
    财务确认对账 (解锁接口)：
    1. 计算自上次对账以来的交易总额
    2. 解除财务锁 (lock_status 2 -> 0)
    3. 更新最后对账时间
    4. 允许设置下次截止日期
    """
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == pos_sn).first()
    if not pos: raise HTTPException(404, "POS not found")

    # A. 统计自上次对账以来的流水金额
    start_time = pos.last_reconciliation_at or pos.created_at
    total_unreconciled = db.query(func.sum(TransactionLog.amount)).filter(
        TransactionLog.pos_sn == pos_sn,
        TransactionLog.transaction_time > start_time
    ).scalar() or 0

    # B. 执行状态变更 (这是解锁的唯一入口)
    pos.last_reconciliation_at = datetime.now()
    pos.lock_status = 0 # 无论当前是什么锁，对账成功即解锁
    
    if next_deadline:
        pos.reconciliation_deadline = next_deadline
    
    msg = f"Reconciled amount: PHP {total_unreconciled}. Status reset to NORMAL."
    record_log(db, pos_sn, "RECONCILE_SUCCESS", user, msg)
    
    db.commit()
    return {
        "status": "success", 
        "amount_reconciled": float(total_unreconciled),
        "last_reconciled": pos.last_reconciliation_at
    }


@router.post("/{pos_sn}/set-deadline")
def set_pos_deadline(
    pos_sn: str,
    deadline: Optional[datetime] = Body(None, embed=True),
    days: Optional[int] = Body(None, embed=True),
    db: Session = Depends(get_db),
    user: Any = Depends(get_finance_or_admin)
):
    """
    手动设置或延长对账截止日期。
    支持直接传日期(deadline)或传天数(days)。
    """
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == pos_sn).first()
    if not pos: raise HTTPException(404, "POS not found")

    target_date = deadline
    if days is not None:
        target_date = datetime.now() + timedelta(days=days)
    
    if not target_date:
        raise HTTPException(400, "Either 'deadline' or 'days' must be provided")

    pos.reconciliation_deadline = target_date
    record_log(db, pos_sn, "SET_DEADLINE", user, f"Deadline updated to: {target_date} ({days} days extension)")
    db.commit()
    return {"status": "success", "deadline": pos.reconciliation_deadline}


@router.post("/batch/set-deadline")
def set_global_pos_deadline(
    deadline: Optional[datetime] = Body(None, embed=True),
    days: Optional[int] = Body(None, embed=True),
    db: Session = Depends(get_db),
    user: Any = Depends(get_finance_or_admin)
):
    """
    全局设置：统一更新所有 POS 机的对账截止日期。
    常用于统一对账日（例如：每个周一）。
    """
    target_date = deadline
    if days is not None:
        target_date = datetime.now() + timedelta(days=days)
    
    if not target_date:
        raise HTTPException(400, "Either 'deadline' or 'days' must be provided")

    # 更新所有未删除的 POS 机
    db.query(POSMachine).filter(POSMachine.is_deleted == False).update({
        POSMachine.reconciliation_deadline: target_date
    }, synchronize_session=False)

    # 记录全局日志
    record_log(db, "SYSTEM", "BATCH_SET_DEADLINE", user, f"Global deadline updated to: {target_date}")
    
    db.commit()
    return {"status": "success", "target_date": target_date}


@router.post("/{pos_sn}/assign")
def assign_user_to_pos(
    pos_sn: str,
    user_id: Optional[int] = Body(None, embed=True),
    db: Session = Depends(get_db),
    user: Any = Depends(get_finance_or_admin)
):
    """
    将 POS 机分配/绑定给特定用户 (业务员、管理员等)
    传递 user_id 为空则表示解绑。
    """
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == pos_sn).first()
    if not pos: raise HTTPException(404, "POS not found")

    if user_id:
        target_user = db.query(User).filter(User.id == user_id).first()
        if not target_user: raise HTTPException(404, "User not found")
        pos.assigned_user_id = user_id
        pos.status = 1 # Assigned
        action = "ASSIGN"
        remark = f"Assigned to user: {target_user.username}"
    else:
        pos.assigned_user_id = None
        pos.status = 0 # Back to Stock
        action = "UNASSIGN"
        remark = "Unassigned from user"

    record_log(db, pos_sn, action, user, remark)
    db.commit()
    return {"status": "success", "assigned_user_id": pos.assigned_user_id}
