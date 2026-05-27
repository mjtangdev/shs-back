import io
import pandas as pd
from typing import Any, Optional
from datetime import date, timedelta, datetime
from fastapi import APIRouter, Depends, Query, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from sqlalchemy import func, or_

from app.api.deps import get_db, get_current_user
from app.models.transaction import TransactionLog
from app.models.customer import Customer
from app.models.org import Region
from app.models.users import User
from app.schemas.finance import TransactionList, FinanceSummaryResponse

router = APIRouter()

def _build_finance_query(db: Session, start_date: date = None, end_date: date = None, 
                         pos_sn: str = None, operator: str = None, region_id: int = None,
                         exact_operator: bool = False, customer_uuid: str = None,
                         search: str = None):
    """内部辅助函数：构建通用的过滤查询"""
    # 联表查询，关联客户表以获取客户姓名和所属区域
    query = db.query(TransactionLog, Customer, Region).outerjoin(
        Customer, TransactionLog.customer_uuid == Customer.uuid
    ).outerjoin(
        Region, Customer.region_id == Region.id
    )

    if customer_uuid:
        query = query.filter(TransactionLog.customer_uuid == customer_uuid)
    if start_date:
        query = query.filter(TransactionLog.transaction_time >= datetime.combine(start_date, datetime.min.time()))
    if end_date:
        # 包含结束日期当天
        query = query.filter(TransactionLog.transaction_time < datetime.combine(end_date + timedelta(days=1), datetime.min.time()))
    
    if pos_sn:
        query = query.filter(TransactionLog.pos_sn.ilike(f"%{pos_sn}%"))
        
    if operator:
        if exact_operator:
            query = query.filter(TransactionLog.operator_username == operator)
        else:
            query = query.filter(TransactionLog.operator_username.ilike(f"%{operator}%"))

    if search:
        search_filter = f"%{search}%"
        query = query.filter(
            or_(
                TransactionLog.transaction_id.ilike(search_filter),
                TransactionLog.operator_username.ilike(search_filter),
                TransactionLog.customer_uuid.ilike(search_filter),
                TransactionLog.pos_sn.ilike(search_filter),
                Customer.first_name.ilike(search_filter),
                Customer.last_name.ilike(search_filter)
            )
        )

    if region_id:
        # 仅匹配该地区及子地区
        allowed_ids = [region_id]
        children = db.query(Region.id).filter(Region.parent_id == region_id).all()
        if children:
            child_ids = [c[0] for c in children]
            allowed_ids.extend(child_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(child_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
            
        query = query.filter(Customer.region_id.in_(allowed_ids))
        
    return query

# --- 1. 获取交易流水明细 (带分页) ---
@router.get("/transactions", response_model=TransactionList)
def get_transactions(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 50,
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    pos_sn: Optional[str] = Query(None),
    operator: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    region_id: Optional[int] = Query(None),
    customer_uuid: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user)
):
    exact_operator = False
    if current_user.role == 2: # 业务员：强制只能看自己的
        operator = current_user.username
        exact_operator = True
        region_id = None
    elif current_user.role not in [0, 1, 3]:
        raise HTTPException(status_code=403, detail="Permission denied")

    query = _build_finance_query(db, start_date, end_date, pos_sn, operator, region_id, exact_operator, customer_uuid, search)
    total = query.count()
    results = query.order_by(TransactionLog.transaction_time.desc()).offset(skip).limit(limit).all()

    items = []
    for tx, customer, region in results:
        items.append({
            "id": tx.id,
            "transaction_id": tx.transaction_id,
            "customer_uuid": tx.customer_uuid,
            "customer_name": f"{customer.first_name} {customer.last_name}" if customer else "-",
            "card_uuid": tx.card_uuid,
            "days": tx.days,
            "amount": tx.amount,
            "transaction_time": tx.transaction_time,
            "action_type": tx.action_type,
            "pos_sn": tx.pos_sn,
            "operator_username": tx.operator_username,
            "region_name": region.name if region else "-"
        })

    return {"total": total, "items": items}

# --- 2. 财务核心汇总数据 (看板使用) ---
@router.get("/summary", response_model=FinanceSummaryResponse)
def get_finance_summary(
    db: Session = Depends(get_db),
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    pos_sn: Optional[str] = Query(None),
    operator: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    region_id: Optional[int] = Query(None),
    current_user: User = Depends(get_current_user)
):
    exact_operator = False
    if current_user.role == 2:
        operator = current_user.username
        exact_operator = True
        region_id = None
    elif current_user.role not in [0, 1, 3]:
        raise HTTPException(status_code=403, detail="Permission denied")

    # 复用过滤逻辑，但是我们只需要查询聚合数据
    base_query = _build_finance_query(db, start_date, end_date, pos_sn, operator, region_id, exact_operator, search=search)
    
    # 提取聚合列：总金额、总天数、记录条数
    summary = base_query.with_entities(
        func.sum(TransactionLog.amount).label("total_amount"),
        func.sum(TransactionLog.days).label("total_days"),
        func.count(TransactionLog.id).label("transaction_count")
    ).first()

    return {
        "total_amount": summary.total_amount or 0,
        "total_days": summary.total_days or 0,
        "transaction_count": summary.transaction_count or 0
    }

# --- 3. 财务明细 Excel 导出 ---
@router.get("/export")
def export_finance_records(
    db: Session = Depends(get_db),
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    pos_sn: Optional[str] = Query(None),
    operator: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    region_id: Optional[int] = Query(None),
    current_user: User = Depends(get_current_user)
):
    exact_operator = False
    if current_user.role == 2:
        operator = current_user.username
        exact_operator = True
        region_id = None
    elif current_user.role not in [0, 1, 3]:
        raise HTTPException(status_code=403, detail="Permission denied")

    query = _build_finance_query(db, start_date, end_date, pos_sn, operator, region_id, exact_operator, search=search)
    results = query.order_by(TransactionLog.transaction_time.desc()).all()

    data = []
    for tx, customer, region in results:
        data.append({
            "Transaction ID": tx.transaction_id,
            "Time": tx.transaction_time.strftime("%Y-%m-%d %H:%M:%S"),
            "Customer": f"{customer.first_name} {customer.last_name}" if customer else "-",
            "Customer UUID": tx.customer_uuid,
            "Region": region.name if region else "-",
            "Action": tx.action_type,
            "Amount (PHP)": float(tx.amount),
            "Days": float(tx.days),
            "POS SN": tx.pos_sn,
            "Operator": tx.operator_username,
            "Customer Current Expiry": customer.expiry_time.strftime("%Y-%m-%d %H:%M:%S") if customer and customer.expiry_time else "Never/Expired"
        })

    df = pd.DataFrame(data)
    output = io.StringIO()
    df.to_csv(output, index=False, encoding='utf-8-sig') # 使用 utf-8-sig 解决 Excel 乱码
    csv_bytes = output.getvalue().encode('utf-8-sig')
    
    filename = f"shs-transactions_{datetime.now().strftime('%Y%m%d')}.csv"
    return StreamingResponse(
        io.BytesIO(csv_bytes), 
        media_type="text/csv", 
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )
