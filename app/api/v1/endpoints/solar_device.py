import io
import pandas as pd
from datetime import datetime
from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_

from app.api.deps import get_db, get_current_user, get_finance_or_admin
from app.models.solar_device import SolarUnit
from app.models.customer import Customer
from app.models.org import Region
# 注意：即便不链接关系，我们可能仍需搜索 Customer 表，但暂时为了启动，我们只查 SolarUnit 本身
from app.schemas.solar_device import SolarUnitCreate, SolarUnitResponse, SolarUnitList

router = APIRouter()

@router.get("/", response_model=SolarUnitList)
def get_solar_units(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 50,
    region_id: Optional[int] = Query(None),
    search: Optional[str] = Query(None),
    status: Optional[int] = Query(None),
    current_user: Any = Depends(get_current_user)
):
    # 联表查询：SolarUnit -> Customer -> Region
    query = db.query(SolarUnit).outerjoin(
        Customer, SolarUnit.customer_uuid == Customer.uuid
    ).options(
        joinedload(SolarUnit.customer).joinedload(Customer.region).joinedload(Region.parent)
    )

    # 逻辑增强：根据角色进行数据隔离 (与 IC 卡逻辑对齐)
    if current_user.role == 2:
        # 业务员只能看：1. 库存设备 (Status 0) OR 2. 自己辖区内已绑定的设备
        user_region_id = current_user.region_id
        allowed_ids = [user_region_id]
        children = db.query(Region.id).filter(Region.parent_id == user_region_id).all()
        if children:
            c_ids = [c[0] for c in children]
            allowed_ids.extend(c_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(c_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
        
        query = query.filter(or_(SolarUnit.shs_status == 0, Customer.region_id.in_(allowed_ids)))
    
    elif region_id is not None:
        # 管理员/财务按需过滤区域
        allowed_ids = [region_id]
        children = db.query(Region.id).filter(Region.parent_id == region_id).all()
        if children:
            c_ids = [c[0] for c in children]
            allowed_ids.extend(c_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(c_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
        query = query.filter(Customer.region_id.in_(allowed_ids))

    if status is not None:
        query = query.filter(SolarUnit.shs_status == status)

    if search:
        sf = f"%{search}%"
        query = query.filter(or_(
            SolarUnit.shs_machine_id.ilike(sf),
            SolarUnit.solar_equipment_id.ilike(sf),
            SolarUnit.radio_id.ilike(sf),
            SolarUnit.flashlight_id.ilike(sf),
            SolarUnit.led_light_id.ilike(sf),
            SolarUnit.customer_name.ilike(sf)
        ))

    total = query.count()
    units = query.order_by(SolarUnit.updated_at.desc()).offset(skip).limit(limit).all()

    items = []
    for u in units:
        # 动态解析地区名称：优先从绑定的 Customer 实时档案中获取
        city_name, town_name = "-", "-"
        cust_id = None
        
        if u.customer:
            cust_id = u.customer.id
            if u.customer.region:
                reg = u.customer.region
                if reg.level == 2: # Purok
                    town_name = reg.name
                    city_name = reg.parent.name if reg.parent else "-"
                else:
                    city_name = reg.name
        elif u.city or u.town:
            city_name = u.city or "-"
            town_name = u.town or "-"

        items.append({
            "id": u.id, 
            "shs_machine_id": u.shs_machine_id,
            "solar_equipment_id": u.solar_equipment_id, 
            "radio_id": u.radio_id,
            "flashlight_id": u.flashlight_id, 
            "led_light_id": u.led_light_id,
            "status": u.shs_status, 
            "customer_id": cust_id,
            "customer_uuid": str(u.customer_uuid) if u.customer_uuid else "-",
            "customer_name": u.customer_name or "-", 
            "city_name": city_name, 
            "town_name": town_name,
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

@router.get("/import-template")
def get_solar_import_template(current_user: Any = Depends(get_finance_or_admin)):
    """获取设备导入 Excel 模板"""
    df = pd.DataFrame(columns=[
        "shs_machine_id", "solar_equipment_id", "radio_id", 
        "flashlight_id", "led_light_id", "production_date"
    ])
    # 示例数据
    df.loc[0] = ["M1001", "S1001", "R1001", "F1001", "L1001", "2024-01-01"]
    
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Sheet1')
    
    output.seek(0)
    return StreamingResponse(
        output,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": "attachment; filename=solar_unit_import_template.xlsx"}
    )

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
    # 预加载已存在的全部 5 种配件 ID，防止违反唯一约束报错
    exist_shs = {u[0] for u in db.query(SolarUnit.shs_machine_id).all() if u[0]}
    exist_solar = {u[0] for u in db.query(SolarUnit.solar_equipment_id).all() if u[0]}
    exist_radio = {u[0] for u in db.query(SolarUnit.radio_id).all() if u[0]}
    exist_flash = {u[0] for u in db.query(SolarUnit.flashlight_id).all() if u[0]}
    exist_led = {u[0] for u in db.query(SolarUnit.led_light_id).all() if u[0]}
    
    for idx, row in df.iterrows():
        shs_id = str(row.get('shs_machine_id', '')).strip()
        solar_id = str(row.get('solar_equipment_id', '')).strip()
        radio_id = str(row.get('radio_id', '')).strip()
        flash_id = str(row.get('flashlight_id', '')).strip()
        led_id = str(row.get('led_light_id', '')).strip()
        
        # 检查是否缺失必填的唯一标识
        if not all([shs_id, solar_id, radio_id, flash_id, led_id]):
            skipped.append(f"Row {idx+2}: Missing one or more required equipment IDs")
            continue
            
        # 检查是否和数据库内数据（或当前 Excel 之前的行）重复
        if (shs_id in exist_shs or solar_id in exist_solar or 
            radio_id in exist_radio or flash_id in exist_flash or led_id in exist_led):
            skipped.append(f"Row {idx+2}: One or more IDs already exist in the system (Duplicate)")
            continue
        
        # 将行数据转为模型
        batch.append(SolarUnit(
            shs_machine_id=shs_id, 
            solar_equipment_id=solar_id,
            radio_id=radio_id,
            flashlight_id=flash_id,
            led_light_id=led_id,
            # 日期转换，如果失败则用当前时间
            production_date=pd.to_datetime(row.get('production_date', datetime.now()), errors='coerce') or datetime.now(),
            shs_status=0, 
            created_at=datetime.now()
        ))
        # 加入缓存，防止同一次导入文件内的相互重复
        exist_shs.add(shs_id)
        exist_solar.add(solar_id)
        exist_radio.add(radio_id)
        exist_flash.add(flash_id)
        exist_led.add(led_id)

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

@router.get("/export")
def export_solar_units(
    db: Session = Depends(get_db),
    region_id: Optional[int] = Query(None),
    status: Optional[int] = Query(None),
    current_user: Any = Depends(get_finance_or_admin)
):
    """导出设备全维度报表"""
    query = db.query(SolarUnit).outerjoin(
        Customer, SolarUnit.customer_uuid == Customer.uuid
    ).options(
        joinedload(SolarUnit.customer).joinedload(Customer.region).joinedload(Region.parent)
    )

    if status is not None:
        query = query.filter(SolarUnit.shs_status == status)

    if region_id:
        allowed_ids = [region_id]
        children = db.query(Region.id).filter(Region.parent_id == region_id).all()
        if children:
            c_ids = [c[0] for c in children]
            allowed_ids.extend(c_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(c_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
        query = query.filter(Customer.region_id.in_(allowed_ids))

    units = query.all()
    export_data = []
    
    status_map = {0: "In Stock", 1: "Active", 2: "Damaged"}

    for u in units:
        city_name, town_name = "-", "-"
        if u.customer:
            if u.customer.region:
                reg = u.customer.region
                if reg.level == 2:
                    town_name = reg.name
                    city_name = reg.parent.name if reg.parent else "-"
                else:
                    city_name = reg.name
        elif u.city or u.town:
            city_name = u.city or "-"
            town_name = u.town or "-"

        export_data.append({
            "Machine ID": u.shs_machine_id,
            "Solar Panel ID": u.solar_equipment_id,
            "Radio ID": u.radio_id,
            "Flashlight ID": u.flashlight_id,
            "LED ID": u.led_light_id,
            "Status": status_map.get(u.shs_status, "Unknown"),
            "Owner": u.customer_name or "-",
            "Municipality": city_name,
            "Barangay": town_name,
            "Production Date": u.production_date.strftime("%Y-%m-%d") if u.production_date else "-",
            "Bound Date": u.bound_at.strftime("%Y-%m-%d") if u.bound_at else "-"
        })

    df = pd.DataFrame(export_data)
    
    # 直接导出为 Excel (.xlsx) 格式
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Inventory')
    
    output.seek(0)
    filename = f"SHS_Inventory_{datetime.now().strftime('%Y%m%d')}.xlsx"
    return StreamingResponse(
        output,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

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