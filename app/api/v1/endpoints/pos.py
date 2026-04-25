import io
import pandas as pd
from datetime import datetime
from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.api.deps import get_db, get_current_user, get_finance_or_admin
from app.models.pos import POSMachine, POSActionLog
from app.schemas.pos import POSCreate, POSUpdate, POSResponse, POSList, POSLockRequest, POSLogResponse

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

# --- 1. 查询列表 ---
@router.get("/", response_model=POSList)
def get_pos(
    db: Session = Depends(get_db), 
    skip: int = 0, 
    limit: int = 50, 
    search: Optional[str] = None,
    current_user: Any = Depends(get_current_user)
):
    query = db.query(POSMachine).filter(POSMachine.is_deleted == False)
    if search:
        sf = f"%{search}%"
        query = query.filter(or_(POSMachine.pos_sn.ilike(sf), POSMachine.branch_office.ilike(sf)))
    
    total = query.count()
    items = query.order_by(POSMachine.created_at.desc()).offset(skip).limit(limit).all()
    return {"total": total, "items": items}

# --- 2. 手动创建 POS (Finance/Admin) ---
@router.post("/create")
def create_pos(
    pos_in: POSCreate, 
    db: Session = Depends(get_db), 
    user: Any = Depends(get_finance_or_admin)
):
    sn = format_pos_sn(pos_in.pos_sn)
    if len(sn) != 16:
        raise HTTPException(400, "POS SN must be 16 digits (or 15 with leading zero)")

    existing = db.query(POSMachine).filter(POSMachine.pos_sn == sn).first()
    if existing:
        if existing.is_deleted:
            # 如果机器曾被删除，则复活它
            existing.is_deleted = False
            existing.status = pos_in.status or 0
            existing.branch_office = pos_in.branch_office
            record_log(db, sn, "CREATE_RECOVER", user, "Re-activated deleted device")
        else:
            raise HTTPException(400, "POS SN already exists in system")
    else:
        # 正常创建新机器
        new_pos = POSMachine(
            pos_sn=sn,
            branch_office=pos_in.branch_office,
            status=pos_in.status or 0,
            created_by=user.username
        )
        db.add(new_pos)
        record_log(db, sn, "CREATE", user, "Manually created device")

    db.commit()
    return {"status": "success", "pos_sn": sn}

# --- 3. 编辑 POS (PUT / {pos_sn}) ---
@router.put("/{pos_sn}")
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
        old_val = getattr(pos, field)
        if old_val != value:
            setattr(pos, field, value)
            changes.append(f"{field}: {old_val} -> {value}")

    if changes:
        record_log(db, pos_sn, "UPDATE", user, " | ".join(changes))
        db.commit()
        db.refresh(pos)

    return {"status": "success", "pos_sn": pos_sn}

# --- 4. 独立锁定 (Finance/Admin) ---
@router.post("/lock")
def lock_pos(req: POSLockRequest, db: Session = Depends(get_db), user: Any = Depends(get_finance_or_admin)):
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == req.pos_sn, POSMachine.is_deleted == False).first()
    if not pos: raise HTTPException(404, "Device not found")
    
    # 0, 1 -> Admin Lock (1); 2 -> Finance Lock (2)
    pos.lock_status = 1 if user.role in [0, 1] else 2
    record_log(db, pos.pos_sn, "LOCK", user, req.remark)
    db.commit()
    return {"status": "success", "lock_status": pos.lock_status}

# --- 5. 独立解锁 (Finance/Admin) ---
@router.post("/unlock")
def unlock_pos(req: POSLockRequest, db: Session = Depends(get_db), user: Any = Depends(get_finance_or_admin)):
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == req.pos_sn).first()
    if not pos: raise HTTPException(404, "Device not found")
    
    pos.lock_status = 0
    record_log(db, pos.pos_sn, "UNLOCK", user, req.remark)
    db.commit()
    return {"status": "success"}

# --- 6. 软删除 (Finance/Admin) ---
@router.delete("/{pos_sn}")
def delete_pos(pos_sn: str, db: Session = Depends(get_db), user: Any = Depends(get_finance_or_admin)):
    pos = db.query(POSMachine).filter(POSMachine.pos_sn == pos_sn).first()
    if not pos: raise HTTPException(404, "Device not found")
    
    pos.is_deleted = True
    record_log(db, pos_sn, "DELETE", user, "Soft deleted from system")
    db.commit()
    return {"status": "success", "message": "Device hidden, logs preserved"}

# --- 7. 获取操作记录 ---
@router.get("/{pos_sn}/logs", response_model=List[POSLogResponse])
def get_pos_logs(
    pos_sn: str, 
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_current_user)
):
    return db.query(POSActionLog).filter(POSActionLog.pos_sn == pos_sn).order_by(POSActionLog.timestamp.desc()).all()

# --- 8. 批量导入 ---
@router.post("/import")
async def import_pos(
    file: UploadFile = File(...), 
    db: Session = Depends(get_db), 
    user: Any = Depends(get_current_user)
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
    current_user: Any = Depends(get_current_user)
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