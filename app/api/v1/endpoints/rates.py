from typing import Any
from fastapi import APIRouter, Depends, HTTPException, Query, Body
from sqlalchemy.orm import Session
from decimal import Decimal
from datetime import datetime, timezone

from app.api.deps import (
    get_db, 
    get_current_user, 
    get_finance_or_admin,
)

from app.models.org import Region

router = APIRouter()

# 1. 获取当前最新费率 (管理员和财务均可访问)
@router.get("/daily/{region_id}")
def get_region_rate(
    region_id: int,
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_current_user)
) -> Any:
    """获取指定地区的费率（已取消继承逻辑，仅返回本级费率）"""
    region = db.query(Region).filter(Region.id == region_id).first()
    if not region:
        raise HTTPException(status_code=404, detail="Region not found")

    rate_val = region.daily_rate
    return {
        "region_id": region_id,
        "region_name": region.name,
        "daily_rate": float(rate_val) if rate_val else 0,
        "updated_at": region.last_rate_updated_at
    }

# 修改为更符合 RESTful 的路径，并使用 Body 传参
@router.patch("/daily/{region_id}")
def update_daily_rate(
    region_id: int,
    new_rate: float = Body(..., embed=True, gt=0, description="新的费率值"),
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
) -> Any:
    """更新指定地区的费率 - 仅限财务或管理员"""
    region = db.query(Region).filter(Region.id == region_id).first()
    if not region:
        raise HTTPException(status_code=404, detail="Region not found")

    try:
        region.daily_rate = Decimal(str(round(new_rate, 2)))
        region.last_rate_updated_at = datetime.now(timezone.utc)
        region.last_rate_modified_by_id = current_user.id
        
        db.commit()
        
        return {
            "status": "success", 
            "region": region.name,
            "new_rate": float(region.daily_rate),
            "operator": current_user.username
        }
    except Exception as e:
        db.rollback()
        # 抛出具体的 500 错误方便排查
        raise HTTPException(status_code=500, detail=f"Database write error: {str(e)}")

@router.patch("/global-sync")
def sync_all_rates(
    new_rate: float = Body(..., embed=True, gt=0, description="新的全局统一费率值"),
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
) -> Any:
    """
    一键同步全局费率：
    批量将所有地区的费率更新为统一的数值。
    """
    try:
        now = datetime.now(timezone.utc)
        rate_dec = Decimal(str(round(new_rate, 2)))

        # 批量更新所有地区的费率
        updated_count = db.query(Region).update({
            Region.daily_rate: rate_dec,
            Region.last_rate_updated_at: now,
            Region.last_rate_modified_by_id: current_user.id
        }, synchronize_session=False)

        db.commit()
        return {
            "status": "success",
            "message": f"Successfully updated {updated_count} regions to the new global rate",
            "global_rate": float(rate_dec)
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Sync failed: {str(e)}")