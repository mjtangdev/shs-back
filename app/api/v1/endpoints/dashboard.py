from typing import Any
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta

from app.api.deps import get_db, get_current_user
# 必须导入所有模型以防止 SQLAlchemy Mapper 报错
from app.models.customer import Customer
from app.models.transaction import TransactionLog
from app.models.solar_device import SolarUnit
from app.models.org import Region
from app.models.card import Card
from app.models.users import User
from app.models.pos import POSMachine, POSActionLog

router = APIRouter()

@router.get("/stats")
def get_dashboard_stats(
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_current_user)
) -> Any:
    """获取首页仪表盘统计数据"""
    
    # 1. 基础数据总计 (全局)
    all_time_revenue = db.query(func.sum(TransactionLog.amount)).scalar() or 0
    active_devices_count = db.query(SolarUnit).filter(SolarUnit.shs_status == 1).count()
    total_customers_count = db.query(Customer).count()

    # 自然日统计 (Today)
    today_start = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    today_revenue = db.query(func.sum(TransactionLog.amount)).filter(
        TransactionLog.transaction_time >= today_start
    ).scalar() or 0

    # 设备库存与损坏统计
    in_stock_devices = db.query(SolarUnit).filter(SolarUnit.shs_status == 0).count()
    damaged_devices = db.query(SolarUnit).filter(SolarUnit.shs_status == 3).count()

    # 2. 计算环比增长率 (本月 vs 上月)
    now = datetime.now()
    first_day_this_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    last_month_end = first_day_this_month - timedelta(seconds=1)
    first_day_last_month = last_month_end.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    # 收入环比
    rev_this_month = db.query(func.sum(TransactionLog.amount)).filter(
        TransactionLog.transaction_time >= first_day_this_month
    ).scalar() or 0
    rev_last_month = db.query(func.sum(TransactionLog.amount)).filter(
        TransactionLog.transaction_time >= first_day_last_month,
        TransactionLog.transaction_time <= last_month_end
    ).scalar() or 0
    rev_growth = round(((float(rev_this_month) - float(rev_last_month)) / float(rev_last_month) * 100), 1) if rev_last_month > 0 else (100.0 if rev_this_month > 0 else 0)

    # 客户增长环比
    cust_this_month = db.query(Customer).filter(Customer.created_at >= first_day_this_month).count()
    cust_last_month = db.query(Customer).filter(Customer.created_at >= first_day_last_month, Customer.created_at <= last_month_end).count()
    cust_growth = round(((cust_this_month - cust_last_month) / cust_last_month * 100), 1) if cust_last_month > 0 else (100.0 if cust_this_month > 0 else 0)

    # 充值次数环比 (Loads)
    loads_this_month = db.query(TransactionLog).filter(
        TransactionLog.transaction_time >= first_day_this_month,
        TransactionLog.action_type == 'RECHARGE'
    ).count()
    loads_last_month = db.query(TransactionLog).filter(
        TransactionLog.transaction_time >= first_day_last_month,
        TransactionLog.transaction_time <= last_month_end,
        TransactionLog.action_type == 'RECHARGE'
    ).count()
    loads_growth = round(((loads_this_month - loads_last_month) / loads_last_month * 100), 1) if loads_last_month > 0 else (100.0 if loads_this_month > 0 else 0)
    today_load_count = db.query(TransactionLog).filter(
        TransactionLog.transaction_time >= today_start,
        TransactionLog.action_type == 'RECHARGE'
    ).count()

    # 3. 每日趋势 (最近 7 天)
    daily_stats = []
    for i in range(6, -1, -1):
        day = now - timedelta(days=i)
        d_start = day.replace(hour=0, minute=0, second=0, microsecond=0)
        d_end = day.replace(hour=23, minute=59, second=59, microsecond=999999)
        d_rev = db.query(func.sum(TransactionLog.amount)).filter(TransactionLog.transaction_time >= d_start, TransactionLog.transaction_time <= d_end).scalar() or 0
        daily_stats.append({"date": day.strftime("%m-%d"), "amount": float(d_rev)})

    # 4. 区域排名 (Top 5)
    region_ranking = []
    try:
        region_stats = db.query(
            Region.name,
            func.sum(TransactionLog.amount).label("revenue"),
            func.count(func.distinct(Customer.id)).label("customers")
        ).join(Customer, Customer.region_id == Region.id) \
         .join(TransactionLog, TransactionLog.customer_uuid == Customer.uuid) \
         .group_by(Region.name) \
         .order_by(func.sum(TransactionLog.amount).desc()) \
         .limit(5).all()
        region_ranking = [{"name": r[0], "revenue": float(r[1]), "customers": r[2]} for r in region_stats]
    except:
        pass

    return {
        "financial": {
            "total": float(all_time_revenue), # 这里保留累计总额
            "today": float(today_revenue),    # 新增今日总额
            "growth": rev_growth,
            "currency": "₱",
            "trend": daily_stats,
            "region_ranking": region_ranking
        },
        "loads": {
            "total": today_load_count,
            "growth": loads_growth,
            "distribution": [
                {"name": "Active", "value": active_devices_count},
                {"name": "In Stock", "value": in_stock_devices},
                {"name": "Damaged", "value": damaged_devices}
            ]
        },
        "users": {
            "total": total_customers_count,
            "growth": cust_growth
        }
    }
