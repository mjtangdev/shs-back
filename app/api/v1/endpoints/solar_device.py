import io
import pandas as pd
from datetime import datetime
from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, text

from app.api.deps import get_db, get_current_user, get_finance_or_admin
from app.models.solar_device import SolarUnit
from app.models.customer import Customer
from app.models.org import Region
# 注意：即便不链接关系，我们可能仍需搜索 Customer 表，但暂时为了启动，我们只查 SolarUnit 本身
from app.schemas.solar_device import SolarUnitCreate, SolarUnitResponse, SolarUnitList, SolarUnitPVBind

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
    current_user: Any = Depends(get_current_user)
):
    # 检查主机 ID 是否已存在
    existing = db.query(SolarUnit).filter(SolarUnit.shs_machine_id == unit_in.shs_machine_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Machine ID already exists")
    
    # PV 序列号拆分：允许为空；若手动传入则使用该值，不再自动拼接后缀 1
    s_id = unit_in.solar_equipment_id.strip() if unit_in.solar_equipment_id and unit_in.solar_equipment_id.strip() else None
    r_id = unit_in.radio_id or f"{unit_in.shs_machine_id}2"
    f_id = unit_in.flashlight_id or f"{unit_in.shs_machine_id}3"
    l_id = unit_in.led_light_id or f"{unit_in.shs_machine_id}4"

    # 检查非空子 ID 的唯一性
    check_ids = [cid for cid in [s_id, r_id, f_id, l_id] if cid]
    for cid in check_ids:
        conflict = db.query(SolarUnit).filter(or_(
            SolarUnit.shs_machine_id == cid,
            SolarUnit.solar_equipment_id == cid,
            SolarUnit.radio_id == cid,
            SolarUnit.flashlight_id == cid,
            SolarUnit.led_light_id == cid
        )).first()
        if conflict:
            raise HTTPException(status_code=400, detail=f"Generated ID {cid} already exists in system")

    new_unit = SolarUnit(
        shs_machine_id=unit_in.shs_machine_id,
        solar_equipment_id=s_id,
        radio_id=r_id,
        flashlight_id=f_id,
        led_light_id=l_id,
        production_date=unit_in.production_date,
        city=unit_in.city,
        town=unit_in.town,
        shs_status=0, 
        created_at=datetime.now()
    )
    db.add(new_unit)
    db.commit()
    return {"status": "success", "id": new_unit.id}

@router.get("/import-template")
def get_solar_import_template(current_user: Any = Depends(get_current_user)):
    """获取设备导入 Excel 模板 (主机与可选 PV)"""
    df = pd.DataFrame(columns=[
        "shs_machine_id", "solar_panels", "production_date"
    ])
    # 示例数据
    df.loc[0] = ["HT2026072000001", "PV2026091300001", "2024-01-01"]
    
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
    current_user: Any = Depends(get_current_user)
):
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="Invalid Excel file")
    
    contents = await file.read()
    df = pd.read_excel(io.BytesIO(contents), dtype=str)
    df.columns = [str(c).strip().lower().replace(" ", "_") for c in df.columns]
    
    batch, skipped = [], []
    # 预加载现有 ID 以便查重
    all_exist_ids = set()
    rows = db.execute(text("SELECT shs_machine_id, solar_equipment_id, radio_id, flashlight_id, led_light_id FROM solar_units")).all()
    for r in rows:
        for val in r:
            if val: all_exist_ids.add(val)
    
    for idx, row in df.iterrows():
        shs_id = str(row.get('shs_machine_id', '')).strip()
        if not shs_id:
            skipped.append(f"Row {idx+2}: Missing machine ID")
            continue
            
        # PV 板拆分：如果 Excel 传入了 PV 序列号（如 solar_panels）且非空则使用，否则保持 None
        raw_pv = str(
            row.get('solar_panels') or 
            row.get('solar_panel') or 
            row.get('solar_equipment_id') or 
            ''
        ).strip()
        s_id = raw_pv if raw_pv else None
        
        r_id = f"{shs_id}2"
        f_id = f"{shs_id}3"
        l_id = f"{shs_id}4"
        
        target_ids = [cid for cid in [shs_id, s_id, r_id, f_id, l_id] if cid]
        
        # 检查是否重复
        is_duplicate = False
        for tid in target_ids:
            if tid in all_exist_ids:
                skipped.append(f"Row {idx+2}: ID {tid} already exists")
                is_duplicate = True
                break
        
        if is_duplicate:
            continue
        
        batch.append(SolarUnit(
            shs_machine_id=shs_id, 
            solar_equipment_id=s_id,
            radio_id=r_id,
            flashlight_id=f_id,
            led_light_id=l_id,
            production_date=pd.to_datetime(row.get('production_date', datetime.now()), errors='coerce') or datetime.now(),
            shs_status=0, 
            created_at=datetime.now()
        ))
        # 加入内存集合防止文件内重复
        for tid in target_ids:
            all_exist_ids.add(tid)

    if batch:
        db.add_all(batch)
        db.commit()
    
    return {"status": "success", "imported": len(batch), "skipped": skipped}

# --- 新增：单个设备手动绑定/更新 PV 序列号 ---
@router.put("/{unit_id}/pv")
def update_unit_pv_id(
    unit_id: int,
    pv_in: SolarUnitPVBind,
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
):
    """单独绑定/修改/更新设备的 PV 太阳能光伏板序列号"""
    unit = db.query(SolarUnit).filter(SolarUnit.id == unit_id).first()
    if not unit:
        raise HTTPException(status_code=404, detail="Unit not found")

    new_pv = pv_in.solar_equipment_id.strip()
    if new_pv and new_pv != unit.solar_equipment_id:
        # 唯一性校验
        conflict = db.query(SolarUnit).filter(
            SolarUnit.solar_equipment_id == new_pv,
            SolarUnit.id != unit_id
        ).first()
        if conflict:
            raise HTTPException(
                status_code=400, 
                detail=f"PV Serial Number '{new_pv}' is already bound to another unit ({conflict.shs_machine_id})"
            )

    unit.solar_equipment_id = new_pv if new_pv else None
    unit.updated_at = datetime.now()
    db.commit()
    db.refresh(unit)
    return {"status": "success", "id": unit.id, "solar_equipment_id": unit.solar_equipment_id}

# --- 新增：独立 PV 序列号 Excel 绑定模板 ---
@router.get("/import-pv-template")
def get_solar_pv_import_template(current_user: Any = Depends(get_current_user)):
    """获取独立 PV 光伏板序列号批量导入模板 (单列 solar_panels)"""
    df = pd.DataFrame(columns=[
        "solar_panels"
    ])
    df.loc[0] = ["CP26N-2-000001"]

    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Sheet1')

    output.seek(0)
    return StreamingResponse(
        output,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": "attachment; filename=solar_pv_import_template.xlsx"}
    )

# --- 新增：独立 PV 序列号 Excel 批量绑定导入 ---
@router.post("/import-pv")
async def import_solar_pv_ids(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
):
    """通过 Excel 批量导入/更新 PV 太阳能板序列号"""
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="Invalid Excel file")

    contents = await file.read()
    df = pd.read_excel(io.BytesIO(contents), dtype=str)
    df = df.where(pd.notnull(df), None)
    df.columns = [str(c).strip().lower().replace(" ", "_") for c in df.columns]

    updated_count, skipped = 0, []
    # 预加载所有已存在的 PV 序列号以防重复
    existing_pv_set = set()
    for row in db.execute(text("SELECT solar_equipment_id FROM solar_units WHERE solar_equipment_id IS NOT NULL")).all():
        if row[0]:
            existing_pv_set.add(str(row[0]).strip())

    # 查询所有处于在库且尚未绑定 PV 板的主机设备按 ID 顺序排序
    unbound_units = db.query(SolarUnit).filter(
        or_(SolarUnit.solar_equipment_id == None, SolarUnit.solar_equipment_id == '')
    ).order_by(SolarUnit.id.asc()).all()
    unbound_index = 0

    for idx, row in df.iterrows():
        # 支持多种别名表头：solar_panels / solar_panel / solar_equipment_id / pv_sn
        pv_id = str(
            row.get('solar_panels') or 
            row.get('solar_panel') or 
            row.get('solar_equipment_id') or 
            row.get('pv_sn') or 
            ''
        ).strip()

        shs_id = str(row.get('shs_machine_id', '')).strip() if row.get('shs_machine_id') else ''

        if not pv_id:
            skipped.append(f"Row {idx+2}: Missing PV Serial Number (solar_panels)")
            continue

        # 查重
        if pv_id in existing_pv_set:
            skipped.append(f"Row {idx+2}: PV ID '{pv_id}' already exists in system")
            continue

        unit = None
        # 情况 1：如果 Excel 显式指定了主机 ID shs_machine_id
        if shs_id:
            unit = db.query(SolarUnit).filter(SolarUnit.shs_machine_id == shs_id).first()
            if not unit:
                skipped.append(f"Row {idx+2}: Machine ID '{shs_id}' not found in database")
                continue
        else:
            # 情况 2：单列纯 PV 列表，自动顺延匹配在库未绑定 PV 的设备
            if unbound_index < len(unbound_units):
                unit = unbound_units[unbound_index]
                unbound_index += 1
            else:
                skipped.append(f"Row {idx+2}: No available in-stock machine to bind PV '{pv_id}'")
                continue

        unit.solar_equipment_id = pv_id
        unit.updated_at = datetime.now()
        existing_pv_set.add(pv_id)
        updated_count += 1

    if updated_count > 0:
        db.commit()

    return {"status": "success", "updated_count": updated_count, "skipped": skipped}

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
        # 👈 核心修复：优先从关联的 Customer 对象获取姓名
        owner_name = u.customer_name or "-"
        if u.customer:
            owner_name = f"{u.customer.first_name} {u.customer.last_name}"
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
            "Owner": owner_name, # 👈 使用修复后的变量
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