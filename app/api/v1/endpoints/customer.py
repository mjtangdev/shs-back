from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session, joinedload, selectinload
from sqlalchemy import or_, func
import pandas as pd
import io
import logging
from datetime import datetime
from snowflake import SnowflakeGenerator

from app.api import deps
from app.models.customer import Customer
from app.schemas.customer import CustomerCreate, CustomerUpdate
from app.models.org import Region
from app.models.config import ProviderConfig
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog

logger = logging.getLogger(__name__)
router = APIRouter()
gen = SnowflakeGenerator(1)

def get_snowflake_id():
    return str(next(gen))

def generate_customer_uuid(db: Session, region_id: int):
    """
    基于地区生成的 8 位客户 ID：RegionPrefix (2位) + 序列 (6位)
    例如：Region 3 -> 03000001
    """
    prefix = f"{region_id:02d}"
    # 查找该地区当前最大的业务编号
    max_id = db.query(func.max(Customer.uuid)).filter(Customer.uuid.like(f'{prefix}%')).scalar()
    
    if not max_id:
        return f"{prefix}000001"
    
    try:
        # 截取前缀后的数字部分并自增
        current_num_str = max_id[len(prefix):]
        next_num = int(current_num_str) + 1
        return f"{prefix}{next_num:06d}"
    except Exception as e:
        # 异常兜底：使用时间戳后缀保证唯一性
        logger.warning(f"ID generation fallback for region {region_id}: {e}")
        return f"{prefix}{datetime.now().strftime('%H%M%S')}"

# --- 1. 获取列表 ---
@router.get("/")
def get_customers(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 50,
    region_id: Optional[int] = Query(None),
    search: Optional[str] = Query(None),
    expired_only: bool = Query(False),
    is_bound: Optional[bool] = Query(None),
    current_user: Any = Depends(deps.get_current_user)
):
    query = db.query(Customer).options(
        joinedload(Customer.region).joinedload(Region.parent),
        selectinload(Customer.solar_units),
        selectinload(Customer.cards)
    )

    if expired_only:
        query = query.filter(Customer.expiry_time != None, Customer.expiry_time < datetime.now())

    if is_bound is not None:
        if is_bound: query = query.filter(Customer.solar_units.any())
        else: query = query.filter(~Customer.solar_units.any())

    # 权限过滤逻辑
    filter_region_id = current_user.region_id if current_user.role == 2 else region_id
    if filter_region_id is not None:
        allowed_ids = [filter_region_id]
        children = db.query(Region.id).filter(Region.parent_id == filter_region_id).all()
        if children:
            c_ids = [c[0] for c in children]; allowed_ids.extend(c_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(c_ids)).all()
            allowed_ids.extend([s[0] for s in sub_children])
        query = query.filter(Customer.region_id.in_(allowed_ids))

    if search:
        sf = f"%{search}%"
        query = query.filter(or_(Customer.first_name.ilike(sf), Customer.last_name.ilike(sf), Customer.mobile.ilike(sf), Customer.uuid.ilike(sf)))

    total = query.count()
    customers = query.order_by(Customer.id.desc()).offset(skip).limit(limit).all()

    result = []
    for c in customers:
        display_region = c.region.name if c.region else "Unknown"
        if c.region and c.region.level == 2 and c.region.parent:
            display_region = f"{c.region.parent.name} - {c.region.name}"

        c_shs = c.solar_units[0].shs_machine_id if c.solar_units else "-"
        c_pv = c.solar_units[0].solar_equipment_id if c.solar_units else "-"
        c_card = c.cards[0].card_uuid if c.cards else "-"

        result.append({
            "id": c.id, "uuid": c.uuid, "first_name": c.first_name, "last_name": c.last_name,
            "gender": c.gender, "mobile": c.mobile, "email": c.email, "address": c.address,
            "region_id": c.region_id, "region_name": display_region, "is_bound": len(c.solar_units) > 0,
            "shs_machine_id": c_shs or "-",
            "pv_sn": c_pv or "-",
            "solar_equipment_id": c_pv or "-",
            "card_uuid": c_card or "-",
            "expiry_time": c.expiry_time, "created_at": c.created_at
        })
    return {"total": total, "items": result}

# --- 2. 手动创建 ---
@router.post("/create")
def create_customer(
    customer_in: CustomerCreate,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_user)
):
    existing = db.query(Customer).filter(Customer.mobile == customer_in.mobile).first()
    if existing: raise HTTPException(status_code=400, detail="Mobile already exists")

    user_data = customer_in.dict()
    # 确定归属地区：业务员强制用本人的，管理员用表单里的
    target_region_id = current_user.region_id if current_user.role == 2 else customer_in.region_id
    if not target_region_id:
        raise HTTPException(status_code=400, detail="Region ID is required")
        
    user_data["region_id"] = target_region_id
    if user_data.get("gender"): user_data["gender"] = user_data["gender"].lower()
    
    provider = db.query(ProviderConfig).first()
    new_obj = Customer(
        **user_data,
        uuid=generate_customer_uuid(db, target_region_id), # 👈 传入 region_id 生成业务 ID
        electric_company=provider.name if provider else "SHS",
        created_at=datetime.now()
    )
    db.add(new_obj); db.commit(); db.refresh(new_obj)
    return {"status": "success", "id": new_obj.id, "uuid": new_obj.uuid}

# --- 3. 编辑客户 ---
@router.put("/{customer_id}")
def update_customer(
    customer_id: int,
    customer_in: CustomerUpdate,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_user)
):
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer: raise HTTPException(status_code=404, detail="Customer not found")

    if current_user.role == 2 and customer.region_id != current_user.region_id:
         raise HTTPException(status_code=403, detail="Permission denied: Cannot edit customers outside your region")

    update_data = customer_in.dict(exclude_unset=True)
    if "mobile" in update_data and update_data["mobile"] != customer.mobile:
        if db.query(Customer).filter(Customer.mobile == update_data["mobile"]).first():
            raise HTTPException(status_code=400, detail="Mobile already exists")

    for field, value in update_data.items():
        setattr(customer, field, value)
    
    db.commit()
    return {"status": "success"}

# --- 3.1 安全删除空客户 ---
@router.delete("/{customer_id}")
def delete_empty_customer(
    customer_id: int,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_finance_or_admin)
):
    """
    物理删除没有关联资产和财务流水的空客户。
    """
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    # 1. 检查是否有绑定卡片
    has_cards = db.query(Card).filter(Card.customer_uuid == customer.uuid).first()
    if has_cards:
        raise HTTPException(status_code=400, detail="Cannot delete: Customer has an active IC card bound.")

    # 2. 检查是否有绑定设备
    has_units = db.query(SolarUnit).filter(SolarUnit.customer_uuid == customer.uuid).first()
    if has_units:
        raise HTTPException(status_code=400, detail="Cannot delete: Customer has an active SHS device bound.")

    # 3. 检查是否有财务流水记录
    has_transactions = db.query(TransactionLog).filter(TransactionLog.customer_uuid == customer.uuid).first()
    if has_transactions:
        raise HTTPException(status_code=400, detail="Cannot delete: Customer has history financial transactions.")

    # 如果通过以上所有检查，执行物理删除
    db.delete(customer)
    db.commit()
    
    return {"status": "success", "message": f"Empty customer {customer.uuid} has been deleted."}

@router.post("/import")
async def import_customers(
    file: UploadFile = File(...),
    region_id: Optional[int] = Query(None), # 允许从 UI 传参
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_finance_or_admin)
):
    """
    客户批量导入接口
    1. 支持 region_id 从参数传，也支持从 Excel 读
    2. 手机号不再作为强制查重的唯一键 (因为现在可能为空)
    """
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="Invalid file type")

    contents = await file.read()
    df = pd.read_excel(io.BytesIO(contents), dtype=str)
    df = df.where(pd.notnull(df), None)
    df.columns = [str(c).strip().lower().replace(" ", "_") for c in df.columns]

    batch, skipped = [], []
    provider = db.query(ProviderConfig).first()
    
    for idx, row in df.iterrows():
        # 确定区域 ID
        target_region = row.get('region_id') or region_id
        if not target_region:
            skipped.append(f"Row {idx+2}: Missing Region ID")
            continue
        
        # 确定手机号
        m = str(row.get('mobile', '')).strip() if row.get('mobile') else None
        
        # 业务 UUID 生成逻辑
        new_uuid = generate_customer_uuid(db, int(target_region))
        
        new_cust = Customer(
            uuid=new_uuid,
            first_name=str(row.get('first_name', '')).strip(),
            last_name=str(row.get('last_name', '')).strip(),
            gender=str(row.get('gender', 'male')).lower(),
            mobile=m or f"TEMP-{new_uuid}", # 没手机号就用 UUID 占位
            address=row.get('address'),
            email=row.get('email'),
            region_id=int(target_region),
            electric_company=provider.name if provider else "SHS",
            created_at=datetime.now()
        )
        batch.append(new_cust)
        # 为了让 generate_customer_uuid 能连续生成，需要逐条刷新或手动累加
        # 这里采用逐条 add 以保证 UUID 连续不重复
        db.add(new_cust)
        db.flush() 

    db.commit()
    return {"status": "success", "imported": len(batch), "skipped": skipped}

# --- 4. 辅助工具 (Excel 导出与模板) ---
@router.get("/export")
def export_customers(
    db: Session = Depends(deps.get_db),
    region_id: Optional[int] = Query(None),
    current_user: Any = Depends(deps.get_finance_or_admin)
):
    """
    全量客户报表导出 (含资产绑定信息)
    """
    query = db.query(Customer).options(
        joinedload(Customer.region).joinedload(Region.parent),
        selectinload(Customer.solar_units),
        selectinload(Customer.cards)
    )

    # 支持按区域筛选导出
    if region_id:
        allowed_ids = [region_id]
        children = db.query(Region.id).filter(Region.parent_id == region_id).all()
        if children:
            c_ids = [c[0] for c in children]; allowed_ids.extend(c_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(c_ids)).all()
            allowed_ids.extend([s[0] for s in sub_children])
        query = query.filter(Customer.region_id.in_(allowed_ids))

    customers = query.all()
    
    rows = []
    for c in customers:
        # 解析详细地址层级
        municipality, barangay, purok = "-", "-", "-"
        if c.region:
            if c.region.level == 2:
                purok = c.region.name
                if c.region.parent:
                    barangay = c.region.parent.name
                    if c.region.parent.parent:
                        municipality = c.region.parent.parent.name
            elif c.region.level == 1:
                barangay = c.region.name
                if c.region.parent:
                    municipality = c.region.parent.name
            else:
                municipality = c.region.name

        rows.append({
            "Account ID": c.uuid,
            "First Name": c.first_name,
            "Last Name": c.last_name,
            "Gender": c.gender.capitalize() if c.gender else "-",
            "Mobile": c.mobile,
            "Municipality": municipality,
            "Barangay": barangay,
            "Purok": purok,
            "Card UID": c.cards[0].card_uuid if c.cards else "Not Bound",
            "SHS Machine ID": c.solar_units[0].shs_machine_id if c.solar_units else "Not Bound",
            "Date Installed": c.installed_at.strftime("%Y-%m-%d") if c.installed_at else "-",
            "Expiry Date": c.expiry_time.strftime("%Y-%m-%d") if c.expiry_time else "Never Recharged",
            "Total Days": float(c.total_recharged_days or 0),
            "Total Amount": float(c.total_recharged_amount or 0),
            "Address Note": c.address or "-",
            "Created Date": c.created_at.strftime("%Y-%m-%d %H:%M")
        })

    df = pd.DataFrame(rows)
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Customer-Records')
    
    output.seek(0)
    filename = f"Customer_List_{datetime.now().strftime('%Y%m%d')}.xlsx"
    return StreamingResponse(
        output, 
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

@router.get("/import-template")
def get_customer_import_template(
    current_user: Any = Depends(deps.get_current_user)
):
    """获取客户导入 Excel 模板"""
    df = pd.DataFrame(columns=[
        "first_name", "last_name", "gender", "mobile",
        "email", "address"
    ])
    # 示例数据
    df.loc[0] = ["John", "Doe", "male", "123456789", "john@example.com", "Main St 123"]

    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Template')

    output.seek(0)
    return StreamingResponse(
        output,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": "attachment; filename=customer_import_template.xlsx"}
    )

# --- 5. 获取详情 ---
@router.get("/{customer_id}")
def get_customer_detail(
    customer_id: int,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_user)
):
    customer = db.query(Customer).options(
        joinedload(Customer.region).joinedload(Region.parent)
    ).filter(Customer.id == customer_id).first()

    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    # 获取关联资产
    cards = db.query(Card).filter(Card.customer_uuid == customer.uuid).all()
    solar_units = db.query(SolarUnit).filter(SolarUnit.customer_uuid == customer.uuid).all()
    recent_transactions = db.query(TransactionLog).filter(
        TransactionLog.customer_uuid == customer.uuid
    ).order_by(TransactionLog.transaction_time.desc()).limit(10).all()

    display_region = customer.region.name if customer.region else "Unknown"
    if customer.region and customer.region.level == 2 and customer.region.parent:
        display_region = f"{customer.region.parent.name} - {customer.region.name}"

    return {
        "id": customer.id, "uuid": customer.uuid, "first_name": customer.first_name,
        "last_name": customer.last_name, "gender": customer.gender, "mobile": customer.mobile,
        "email": customer.email, "address": customer.address, "birthday": customer.birthday,
        "region_id": customer.region_id, "region_name": display_region, 
        "beneficiary_count": customer.beneficiary_count,
        "representative_name": customer.representative_name,
        "rep_relationship": customer.rep_relationship,
        "expiry_time": customer.expiry_time,
        "total_recharged_days": float(customer.total_recharged_days or 0),
        "total_recharged_amount": float(customer.total_recharged_amount or 0),
        "created_at": customer.created_at,
        "cards": cards, "solar_units": solar_units, "recent_transactions": recent_transactions
    }

