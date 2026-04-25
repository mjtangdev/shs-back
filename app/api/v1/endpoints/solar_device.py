import io
import pandas as pd
from datetime import datetime
from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.api.deps import get_db, get_current_user, get_finance_or_admin
from app.models.solar_device import SolarUnit
# 注意：即便不链接关系，我们可能仍需搜索 Customer 表，但暂时为了启动，我们只查 SolarUnit 本身
from app.schemas.solar_device import SolarUnitCreate, SolarUnitResponse, SolarUnitList

router = APIRouter()

@router.get("/", response_model=SolarUnitList)
def get_solar_units(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 50,
    search: Optional[str] = Query(None),
    status: Optional[int] = Query(None),
    current_user: Any = Depends(get_current_user)
):
    # 彻底去掉关联查询（outerjoin / joinedload），只查 SolarUnit
    query = db.query(SolarUnit)

    if status is not None:
        query = query.filter(SolarUnit.shs_status == status)

    if search:
        sf = f"%{search}%"
        # 扩展搜索范围到 5 个硬件 ID
        query = query.filter(or_(
            SolarUnit.shs_machine_id.ilike(sf),
            SolarUnit.solar_equipment_id.ilike(sf),
            SolarUnit.radio_id.ilike(sf),
            SolarUnit.flashlight_id.ilike(sf),
            SolarUnit.led_light_id.ilike(sf),
            SolarUnit.customer_name.ilike(sf) # 支持搜索已录入的客户名
        ))

    total = query.count()
    units = query.order_by(SolarUnit.updated_at.desc()).offset(skip).limit(limit).all()

    items = []
    for u in units:
        # 直接从 SolarUnit 自身的字段读取数据，不再通过 u.customer 链接
        items.append({
            "id": u.id, 
            "shs_machine_id": u.shs_machine_id,
            "solar_equipment_id": u.solar_equipment_id, 
            "radio_id": u.radio_id,
            "flashlight_id": u.flashlight_id, 
            "led_light_id": u.led_light_id,
            "status": u.shs_status, 
            "customer_uuid": str(u.customer_uuid) if u.customer_uuid else "-",
            "customer_name": u.customer_name or "-", 
            "city_name": u.city or "-", 
            "town_name": u.town or "-",
            "production_date": u.production_date, 
            "created_at": u.created_at, 
            "bound_at": u.bound_at
        })
    return {"total": total, "items": items}

@router.post("/create")
def create_solar_unit(
    db: Session = Depends(get_db), 
    unit_in: SolarUnitCreate = None, 
    current_user: Any = Depends(get_finance_or_admin)
):
    # 检查主机 ID 是否已存在
    existing = db.query(SolarUnit).filter(SolarUnit.shs_machine_id == unit_in.shs_machine_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Machine ID already exists")
    
    new_unit = SolarUnit(
        **unit_in.model_dump(), 
        shs_status=0, 
        created_at=datetime.now()
    )
    db.add(new_unit)
    db.commit()
    return {"status": "success", "id": new_unit.id}

@router.post("/import")
async def import_solar_units(
    file: UploadFile = File(...), 
    db: Session = Depends(get_db), 
    current_user: Any = Depends(get_finance_or_admin)
):
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="Invalid Excel file")
    
    contents = await file.read()
    df = pd.read_excel(io.BytesIO(contents), dtype=str)
    # 清理表头：转小写，去空格，换下划线
    df.columns = [str(c).strip().lower().replace(" ", "_") for c in df.columns]
    
    batch, skipped = [], []
    # 预加载已存在的所有主机 ID 防止重复
    exist_ids = {u[0] for u in db.query(SolarUnit.shs_machine_id).all()}
    
    for idx, row in df.iterrows():
        shs_id = str(row.get('shs_machine_id', '')).strip()
        if not shs_id or shs_id in exist_ids:
            skipped.append(f"Row {idx+2}: Duplicate/Empty SHS ID")
            continue
        
        # 将行数据转为模型
        batch.append(SolarUnit(
            shs_machine_id=shs_id, 
            solar_equipment_id=str(row.get('solar_equipment_id', '')),
            radio_id=str(row.get('radio_id', '')),
            flashlight_id=str(row.get('flashlight_id', '')),
            led_light_id=str(row.get('led_light_id', '')),
            # 日期转换，如果失败则用当前时间
            production_date=pd.to_datetime(row.get('production_date', datetime.now()), errors='coerce') or datetime.now(),
            shs_status=0, 
            created_at=datetime.now()
        ))
        exist_ids.add(shs_id)

    if batch:
        db.add_all(batch)
        db.commit()
    
    return {"status": "success", "imported": len(batch), "skipped": skipped}

@router.post("/{unit_id}/reset")
def reset_unit(
    unit_id: int, 
    db: Session = Depends(get_db), 
    current_user: Any = Depends(get_finance_or_admin)
):
    unit = db.query(SolarUnit).filter(SolarUnit.id == unit_id).first()
    if not unit: 
        raise HTTPException(status_code=404, detail="Unit not found")
    
    unit.shs_status = 0
    unit.customer_uuid = None
    unit.customer_name = None
    unit.bound_at = None
    unit.updated_at = datetime.now()
    
    db.commit()
    return {"status": "success"}

@router.delete("/{unit_id}")
def delete_unit(
    unit_id: int, 
    db: Session = Depends(get_db), 
    current_user: Any = Depends(get_finance_or_admin)
):
    unit = db.query(SolarUnit).filter(SolarUnit.id == unit_id).first()
    # 保护逻辑：已激活（status=1）的设备不允许直接删除
    if not unit:
        raise HTTPException(status_code=404, detail="Unit not found")
    if unit.shs_status == 1:
        raise HTTPException(status_code=400, detail="Cannot delete active unit")
        
    db.delete(unit)
    db.commit()
    return {"status": "success"}