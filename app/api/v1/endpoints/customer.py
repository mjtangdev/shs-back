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
        selectinload(Customer.solar_units)
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
            
        result.append({
            "id": c.id, "uuid": c.uuid, "first_name": c.first_name, "last_name": c.last_name,
            "gender": c.gender, "mobile": c.mobile, "email": c.email, "address": c.address,
            "region_id": c.region_id, "region_name": display_region, "is_bound": len(c.solar_units) > 0,
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

# --- 4. 导出 Excel ---
@router.get("/export")
def export_customers(
    db: Session = Depends(deps.get_db),
    region_id: Optional[int] = Query(None),
    current_user: Any = Depends(deps.get_finance_or_admin)
):
    # 此处依赖 get_finance_or_admin，确保已从 deps 导入
    query = db.query(Customer).options(selectinload(Customer.solar_units), selectinload(Customer.cards))
    customers = query.all()
    df = pd.DataFrame([{"ID": c.uuid, "Name": f"{c.first_name} {c.last_name}", "Mobile": c.mobile} for c in customers])
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer: df.to_excel(writer, index=False)
    output.seek(0)
    return StreamingResponse(output, media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
