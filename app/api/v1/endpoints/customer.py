from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_
from sqlalchemy.exc import IntegrityError
import pandas as pd
import io
from datetime import datetime
from snowflake import SnowflakeGenerator

# 这里的 1 是机器 ID (Worker ID)
gen = SnowflakeGenerator(1)

def get_snowflake_id():
    # 强制转为字符串返回，防止前端 JS 处理 BigInt 丢失精度
    return str(next(gen))

from app.api.deps import get_db, get_current_user, get_finance_or_admin, get_current_admin_user
from app.models.customer import Customer
from app.schemas.customer import CustomerCreate, CustomerExcelImport, CustomerUpdate
from app.models.org import Region

router = APIRouter()

# --- 1. 获取列表 (含地区拼接逻辑) ---
@router.get("/")
def get_customers(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 50,
    region_id: Optional[int] = Query(None),
    search: Optional[str] = Query(None),
    current_user: Any = Depends(get_current_user)
) -> Any:
    """获取客户列表，自动拼接地区层级名字"""
    query = db.query(Customer).options(
        joinedload(Customer.region).joinedload(Region.parent)
    )

    # 确定过滤的基础 region_id (业务员强制使用自身地区，管理员/财务使用参数)
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
            "created_at": c.created_at.strftime("%Y-%m-%d %H:%M:%S") if c.created_at else None
        })

    return {"total": total, "items": result}


# --- 2. 手动创建 (应用 Snowflake & 强制小写转换) ---
@router.post("/create")
def create_customer(
    *,
    db: Session = Depends(get_db),
    customer_in: CustomerCreate,
    current_user: Any = Depends(get_finance_or_admin)
) -> Any:
    """手动录入，自动生成雪花 ID，并统一性别为小写"""
    existing = db.query(Customer).filter(Customer.mobile == customer_in.mobile).first()
    if existing:
        raise HTTPException(status_code=400, detail="Mobile already exists")

    update_data = customer_in.dict()
    if "gender" in update_data and isinstance(update_data["gender"], str):
        update_data["gender"] = update_data["gender"].strip().lower()

    try:
        new_obj = Customer(
            **update_data,
            uuid=get_snowflake_id(), 
            created_at=datetime.now()
        )
        db.add(new_obj)
        db.commit()
        db.refresh(new_obj)
        return {"status": "success", "id": new_obj.id, "uuid": new_obj.uuid}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# --- 3. 编辑客户 (使用 PUT) ---
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


# --- 4. 批量导入 ---
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
                new_cust = Customer(
                    **valid_data.dict(),
                    region_id=region_id,
                    uuid=get_snowflake_id() 
                )
                batch_customers.append(new_cust)
                existing_mobiles.add(mobile) 
            except Exception as row_err:
                skip_details.append(f"行 {index + 2} 校验失败: {str(row_err)}")

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


# --- 5. 导出 Excel ---
@router.get("/export")
def export_customers(
    db: Session = Depends(get_db),
    region_id: Optional[int] = Query(None),
    current_user: Any = Depends(get_finance_or_admin)
):
    query = db.query(Customer).options(
        joinedload(Customer.region).joinedload(Region.parent)
    )
    if region_id:
        query = query.filter(Customer.region_id == region_id)
    
    customers = query.all()
    export_data = []

    for c in customers:
        barangay, purok = "-", "-"
        if c.region:
            if c.region.level == 2 and c.region.parent:
                # Level 2 is Purok, its parent is Barangay
                barangay, purok = c.region.parent.name, c.region.name
            elif c.region.level == 1:
                # Level 1 is Barangay
                barangay = c.region.name
            else:
                # Level 0 is Municipality
                barangay = c.region.name

        export_data.append({
            "Customer ID": c.uuid,
            "First Name": c.first_name,
            "Last Name": c.last_name,
            "Gender": c.gender,
            "Mobile": c.mobile,
            "Barangay": barangay,
            "Purok": purok,
            "Card UUID": "-",
            "SHS Machine": "-",
            "Solar Equipment": "-",
            "Radio": "-",
            "Flashlight": "-",
            "LED Light": "-",
            "Total Recharge": "-"
        })

    df = pd.DataFrame(export_data)
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False)
    
    output.seek(0)
    filename = f"SHS_Export_{datetime.now().strftime('%Y%m%d')}.xlsx"
    return StreamingResponse(output, media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", headers={"Content-Disposition": f"attachment; filename={filename}"})


# --- 6. 删除客户 ---
@router.delete("/{customer_id}")
def delete_customer(
    *,
    db: Session = Depends(get_db),
    customer_id: int,
    current_user: Any = Depends(get_current_admin_user)
) -> Any:
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    try:
        db.delete(customer)
        db.commit()
        return {"status": "success", "msg": f"Customer {customer_id} deleted"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))