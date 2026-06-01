from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session, joinedload, selectinload
from sqlalchemy import or_, func
from sqlalchemy.exc import IntegrityError
import pandas as pd
import io
import logging
from datetime import datetime
from snowflake import SnowflakeGenerator

logger = logging.getLogger(__name__)

# 这里的 1 是机器 ID (Worker ID)
gen = SnowflakeGenerator(1)

def get_snowflake_id():
    # 强制转为字符串返回，防止前端 JS 处理 BigInt 丢失精度
    return str(next(gen))

from app.api.deps import get_db, get_current_user, get_finance_or_admin, get_current_admin_user
from app.models.customer import Customer
from app.schemas.customer import CustomerCreate, CustomerExcelImport, CustomerUpdate
from app.models.org import Region
from app.models.config import ProviderConfig
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog

router = APIRouter()

# --- 1. 获取列表 (含地区拼接逻辑) ---
@router.get("/")
def get_customers(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 50,
    region_id: Optional[int] = Query(None),
    search: Optional[str] = Query(None),
    expired_only: bool = Query(False, description="Filter only expired customers"),
    is_bound: Optional[bool] = Query(None, description="Filter by device binding status"),
    current_user: Any = Depends(get_current_user)
) -> Any:
    """获取客户列表，自动拼接地区层级名字"""
    query = db.query(Customer).options(
        joinedload(Customer.region).joinedload(Region.parent),
        selectinload(Customer.solar_units) # 预加载设备信息以判断绑定状态
    )

    if expired_only:
        now = datetime.now()
        query = query.filter(Customer.expiry_time != None, Customer.expiry_time < now)

    if is_bound is not None:
        if is_bound:
            # 筛选已绑定设备的客户
            query = query.filter(Customer.solar_units.any())
        else:
            # 筛选未绑定设备的客户
            query = query.filter(~Customer.solar_units.any())

    # 确定过滤的基础 region_id
    filter_region_id = current_user.region_id if current_user.role == 2 else region_id

    if filter_region_id is not None:
        # 向下递归：包含本级及所有子级的 ID
        allowed_ids = [filter_region_id]
        
        # 查找下一级子区域
        children = db.query(Region.id).filter(Region.parent_id == filter_region_id).all()
        if children:
            child_ids = [c[0] for c in children]
            allowed_ids.extend(child_ids)
            # 继续查找下下级（如市下面的镇）
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(child_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
            
        query = query.filter(Customer.region_id.in_(allowed_ids))

    if search:
        sf = f"%{search}%"
        query = query.filter(or_(
            Customer.first_name.ilike(sf),
            Customer.last_name.ilike(sf),
            Customer.mobile.ilike(sf),
            Customer.uuid.ilike(sf) # 支持使用统一的纯数字编号搜索
        ))

    total = query.count()
    customers = query.order_by(Customer.id.desc()).offset(skip).limit(limit).all()

    result = []
    for c in customers:
        display_region_name = "Unknown"
        if c.region:
            if c.region.level == 2 and c.region.parent:
                display_region_name = f"{c.region.parent.name} - {c.region.name}"
            else:
                display_region_name = c.region.name

        result.append({
            "id": c.id,
            "uuid": c.uuid, 
            "first_name": c.first_name,
            "last_name": c.last_name,
            "gender": c.gender,
            "mobile": c.mobile,
            "email": c.email,
            "birthday": c.birthday.strftime("%Y-%m-%d") if c.birthday else None,
            "address": c.address,
            "region_id": c.region_id,
            "region_name": display_region_name,
            "electric_company": c.electric_company,
            "beneficiary_count": c.beneficiary_count,
            "representative_name": c.representative_name,
            "rep_relationship": c.rep_relationship,
            "expiry_time": c.expiry_time.strftime("%Y-%m-%d %H:%M:%S") if c.expiry_time else None,
            "total_recharged_days": float(c.total_recharged_days or 0),
            "total_recharged_amount": float(c.total_recharged_amount or 0),
            "is_bound": len(c.solar_units) > 0,
            "created_at": c.created_at.strftime("%Y-%m-%d %H:%M:%S") if c.created_at else None
        })

    return {"total": total, "items": result}


# --- 2. 导出 Excel ---
@router.get("/export")
def export_customers(
    db: Session = Depends(get_db),
    region_id: Optional[int] = Query(None),
    expired_only: bool = Query(False, description="Export only expired customers"),
    current_user: Any = Depends(get_finance_or_admin)
):
    """优化后的导出接口：批量预加载 + 减少数据库往返"""
    # 核心优化：使用 selectinload 批量获取一对多关系，使用 joinedload 获取多对一关系
    query = db.query(Customer).options(
        joinedload(Customer.region).joinedload(Region.parent).joinedload(Region.parent),
        selectinload(Customer.solar_units),
        selectinload(Customer.cards)
    )

    if expired_only:
        now = datetime.now()
        query = query.filter(Customer.expiry_time != None, Customer.expiry_time < now)

    if region_id:
        # 向下递归：包含本级及所有子级的 ID
        allowed_ids = [region_id]
        children = db.query(Region.id).filter(Region.parent_id == region_id).all()
        if children:
            child_ids = [c[0] for c in children]
            allowed_ids.extend(child_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(child_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
        query = query.filter(Customer.region_id.in_(allowed_ids))
    
    customers = query.all()
    export_data = []

    for c in customers:
        municipality, barangay, purok = "-", "-", "-"
        # 快速解析层级 (无需再次查询)
        reg = c.region
        if reg:
            if reg.level == 2:
                purok = reg.name
                if reg.parent:
                    barangay = reg.parent.name
                    if reg.parent.parent: municipality = reg.parent.parent.name
            elif reg.level == 1:
                barangay = reg.name
                if reg.parent: municipality = reg.parent.name
            else:
                municipality = reg.name

        # 获取预加载的资产信息
        shs_id, solar_id, radio_id, flash_id, led_id, card_uuid = "-", "-", "-", "-", "-", "-"
        date_installed = "-"
        
        # 提取第一个绑定的卡片
        if c.cards:
            card_uuid = c.cards[0].card_uuid

        # 提取第一个绑定的设备
        if c.solar_units:
            u = c.solar_units[0]
            shs_id, solar_id, radio_id, flash_id, led_id = u.shs_machine_id, u.solar_equipment_id, u.radio_id, u.flashlight_id, u.led_light_id
            if u.bound_at:
                date_installed = u.bound_at.strftime("%Y-%m-%d")

        export_data.append({
            "Customer ID": c.uuid,
            "Full Name": f"{c.first_name} {c.last_name}",
            "Gender": c.gender,
            "Mobile": c.mobile,
            "Municipality": municipality,
            "Barangay": barangay,
            "Purok": purok,
            "Card UUID": card_uuid,
            "SHS Machine": shs_id,
            "Solar Equipment": solar_id,
            "Radio": radio_id,
            "Flashlight": flash_id,
            "LED Light": led_id,
            "Total Recharge": float(c.total_recharged_amount or 0),
            "LATITUDE": "-",
            "LONGITUDE": "-",
            "IAS": "-",
            "DATE INSTALLED": date_installed,
            "IR REPORT NO.": "-",
            "REMARKS": "-",
            "Electric Company": c.electric_company or "-",
            "Beneficiary Count": c.beneficiary_count or 0,
            "Representative Name": c.representative_name or "-",
            "Relationship": c.rep_relationship or "-",
            "CREATED DATE": c.created_at.strftime("%Y-%m-%d %H:%M") if c.created_at else "-",
            "LAST UPDATED": c.updated_at.strftime("%Y-%m-%d %H:%M") if c.updated_at else "-"
        })

    df = pd.DataFrame(export_data)
    
    # 直接导出为 Excel (.xlsx) 格式，彻底解决乱码问题
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Customers')
    
    output.seek(0)
    filename = f"SHS_Export_{datetime.now().strftime('%Y%m%d')}.xlsx"
    return StreamingResponse(
        output,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={
            "Content-Disposition": f"attachment; filename={filename}",
            "Cache-Control": "no-cache"
        }
    )


def generate_customer_uuid(db: Session):
    """
    生成 8 位纯数字客户 ID
    规则：01 (Web前缀) + 6位流水
    """
    # 查找当前最大的 Web 客户 ID (以 01 开头的)
    max_id = db.query(func.max(Customer.uuid)).filter(Customer.uuid.like('01%')).scalar()
    if not max_id:
        return "01000001"
    
    next_num = int(max_id[2:]) + 1
    return f"01{next_num:06d}"

# --- 3. 手动创建 ---
@router.post("/create")
def create_customer(
    *,
    db: Session = Depends(get_db),
    customer_in: CustomerCreate,
    current_user: Any = Depends(get_finance_or_admin)
) -> Any:
    """手动录入，生成 8 位 Web 专属 ID"""
    existing = db.query(Customer).filter(Customer.mobile == customer_in.mobile).first()
    if existing:
        raise HTTPException(status_code=400, detail="Mobile already exists")

    update_data = customer_in.dict()
    # ... 处理性别和公司名称逻辑 ...
    if "gender" in update_data and isinstance(update_data["gender"], str):
        update_data["gender"] = update_data["gender"].strip().lower()
    
    provider = db.query(ProviderConfig).first()
    electric_company_name = provider.name if provider else "-"

    try:
        # 使用新的 8 位生成逻辑
        new_uuid = generate_customer_uuid(db)
        
        full_name = f"{customer_in.first_name} {customer_in.last_name}"
        update_data["representative_name"] = customer_in.representative_name if customer_in.representative_name and customer_in.representative_name.strip() else full_name
        
        new_obj = Customer(
            **update_data,
            uuid=new_uuid,
            electric_company=electric_company_name,
            created_at=datetime.now()
        )
        db.add(new_obj)
        db.commit()
        db.refresh(new_obj)
        return {"status": "success", "id": new_obj.id, "uuid": new_obj.uuid}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# --- 4. 批量导入 ---
@router.get("/import-template")
def get_customer_import_template(current_user: Any = Depends(get_finance_or_admin)):
    """获取客户导入 Excel 模板"""
    df = pd.DataFrame(columns=[
        "first_name", "last_name", "gender", "mobile", "birthday", 
        "address", "email", "beneficiary_count", "representative_name", "rep_relationship"
    ])
    # 添加一行示例
    df.loc[0] = ["James", "Smith", "male", "09123456789", "1990-01-01", "Pangasinan", "james@example.com", 3, "James Smith", "-"]
    
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Sheet1')
    
    output.seek(0)
    return StreamingResponse(
        output,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": "attachment; filename=customer_import_template.xlsx"}
    )

@router.post("/import")
async def import_customers(
    region_id: int = Query(..., description="Target Region ID"),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
):
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="Please upload a valid Excel file.")

    try:
        contents = await file.read()
        df = pd.read_excel(io.BytesIO(contents), dtype=str)
        df = df.where(pd.notnull(df), None)
        df.columns = [str(c).strip().lower() for c in df.columns]

        existing_mobiles = {m[0] for m in db.query(Customer.mobile).all()}
        provider = db.query(ProviderConfig).first()
        electric_company_name = provider.name if provider else "-"
        
        batch_customers = []
        skip_details = []
        
        for index, row in df.iterrows():
            row_dict = row.to_dict()
            row_dict = {k: (v.strip() if isinstance(v, str) else v) for k, v in row_dict.items() if v is not None}
            
            if 'gender' in row_dict and isinstance(row_dict['gender'], str):
                row_dict['gender'] = row_dict['gender'].strip().lower()
            
            mobile = row_dict.get('mobile')
            if not mobile or mobile in existing_mobiles:
                reason = "重复/缺失手机号"
                skip_details.append(f"行 {index + 2}: {reason}")
                continue

            try:
                valid_data = CustomerExcelImport(**row_dict)
                # 处理代表姓名默认逻辑
                fname = valid_data.first_name
                lname = valid_data.last_name
                input_rep = valid_data.representative_name
                
                cust_dict = valid_data.dict()
                cust_dict["representative_name"] = input_rep if input_rep and input_rep.strip() else f"{fname} {lname}"
                cust_dict["rep_relationship"] = valid_data.rep_relationship or "-"
                
                new_cust = Customer(
                    **cust_dict,
                    region_id=region_id,
                    uuid=get_snowflake_id(),
                    electric_company=electric_company_name,
                    created_at=datetime.now()
                )
                batch_customers.append(new_cust)
                existing_mobiles.add(mobile) 
            except Exception as row_err:
                err_msg = f"行 {index + 2} 校验失败: {str(row_err)}"
                skip_details.append(err_msg)
                logger.warning(f"Excel Import Row Error: {err_msg}")

        if batch_customers:
            db.add_all(batch_customers)
            db.commit()
            return {"status": "SUCCESS", "imported": len(batch_customers), "skipped": skip_details}
        
        return {"status": "EMPTY", "message": "无有效数据"}

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        await file.close()


# --- 5. 获取单个客户详情 ---
@router.get("/{customer_id}")
def get_customer_detail(
    customer_id: int,
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_current_user)
) -> Any:
    """获取单个客户的详细信息（含资产与近期流水）"""
    customer = db.query(Customer).options(
        joinedload(Customer.region).joinedload(Region.parent)
    ).filter(Customer.id == customer_id).first()

    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    # 获取关联资产
    cards = db.query(Card).filter(Card.customer_uuid == customer.uuid).all()
    solar_units = db.query(SolarUnit).filter(SolarUnit.customer_uuid == customer.uuid).all()
    
    # 获取最近10条流水
    recent_transactions = db.query(TransactionLog).filter(
        TransactionLog.customer_uuid == customer.uuid
    ).order_by(TransactionLog.transaction_time.desc()).limit(10).all()

    display_region_name = "Unknown"
    if customer.region:
        if customer.region.level == 2 and customer.region.parent:
            display_region_name = f"{customer.region.parent.name} - {customer.region.name}"
        else:
            display_region_name = customer.region.name

    return {
        "id": customer.id,
        "uuid": customer.uuid, 
        "first_name": customer.first_name,
        "last_name": customer.last_name,
        "gender": customer.gender,
        "mobile": customer.mobile,
        "email": customer.email,
        "birthday": customer.birthday.strftime("%Y-%m-%d") if customer.birthday else None,
        "address": customer.address,
        "region_id": customer.region_id,
        "region_name": display_region_name,
        "electric_company": customer.electric_company,
        "beneficiary_count": customer.beneficiary_count,
        "representative_name": customer.representative_name,
        "rep_relationship": customer.rep_relationship,
        "expiry_time": customer.expiry_time.strftime("%Y-%m-%d %H:%M:%S") if customer.expiry_time else None,
        "total_recharged_days": float(customer.total_recharged_days or 0),
        "total_recharged_amount": float(customer.total_recharged_amount or 0),
        "created_at": customer.created_at.strftime("%Y-%m-%d %H:%M:%S") if customer.created_at else None,
        "updated_at": customer.updated_at.strftime("%Y-%m-%d %H:%M:%S") if customer.updated_at else None,
        
        # 资产信息
        "cards": [{
            "card_number": card.card_number,
            "card_uuid": card.card_uuid,
            "status": card.status,
            "bound_at": card.bound_at.strftime("%Y-%m-%d %H:%M") if card.bound_at else None
        } for card in cards],
        
        "solar_units": [{
            "shs_machine_id": unit.shs_machine_id,
            "solar_equipment_id": unit.solar_equipment_id,
            "radio_id": unit.radio_id,
            "flashlight_id": unit.flashlight_id,
            "led_light_id": unit.led_light_id,
            "shs_status": unit.shs_status,
            "bound_at": unit.bound_at.strftime("%Y-%m-%d %H:%M") if unit.bound_at else None
        } for unit in solar_units],
        
        # 财务简报
        "recent_transactions": [{
            "transaction_id": tx.transaction_id,
            "amount": float(tx.amount),
            "days": float(tx.days),
            "transaction_time": tx.transaction_time.strftime("%Y-%m-%d %H:%M"),
            "action_type": tx.action_type,
            "pos_sn": tx.pos_sn,
            "operator_username": tx.operator_username
        } for tx in recent_transactions]
    }


# --- 6. 编辑客户 (使用 PUT) ---
@router.put("/{customer_id}")
def update_customer(
    *,
    db: Session = Depends(get_db),
    customer_id: int,
    customer_in: CustomerUpdate,
    current_user: Any = Depends(get_finance_or_admin)
) -> Any:
    """编辑客户信息，同样强制性别小写转换"""
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    update_data = customer_in.dict(exclude_unset=True)
    
    # 强制性别小写转换
    if "gender" in update_data and isinstance(update_data["gender"], str):
        update_data["gender"] = update_data["gender"].strip().lower()

    # 检查手机号冲突（如果修改了手机号）
    if "mobile" in update_data and update_data["mobile"] != customer.mobile:
        existing = db.query(Customer).filter(Customer.mobile == update_data["mobile"]).first()
        if existing:
            raise HTTPException(status_code=400, detail="Mobile already exists")

    try:
        for field in update_data:
            setattr(customer, field, update_data[field])
        
        db.add(customer)
        db.commit()
        db.refresh(customer)
        return {"status": "success", "id": customer.id}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# --- 7. 删除客户 ---
@router.delete("/{customer_id}")
def delete_customer(
    *,
    db: Session = Depends(get_db),
    customer_id: int,
    current_user: Any = Depends(get_finance_or_admin)
) -> Any:
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    # 保护逻辑：已绑定设备或卡片的客户不允许删除
    if customer.solar_units or customer.cards:
        raise HTTPException(
            status_code=400, 
            detail="Cannot delete customer with active assets (Devices/Cards). Please unbind assets first."
        )

    try:
        db.delete(customer)
        db.commit()
        return {"status": "success", "msg": f"Customer {customer_id} deleted"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
