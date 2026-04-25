from typing import Any
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from decimal import Decimal
from datetime import datetime  # 导入 datetime 用于手动生成时间

from app.api.deps import get_db, get_current_user, get_current_admin_user, get_finance_or_admin, get_current_admin_user

from app.models.config import GlobalRate

router = APIRouter()

# 1. 获取当前最新费率 (管理员和财务均可访问)
@router.get("/daily/current")
def get_current_rate(
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_current_user)
) -> Any:
    """获取当前生效的最新费率"""
    rate = db.query(GlobalRate).order_by(GlobalRate.id.desc()).first()
    
    if not rate:
        return {"daily_rate": 0, "msg": "尚未设置初始费率", "updated_at": None}
    
    return {
        "id": rate.id,
        "daily_rate": float(rate.daily_rate),
        # 确保输出格式统一
        "updated_at": rate.updated_at.strftime("%Y-%m-%d %H:%M:%S") if rate.updated_at else None,
        "modifier_name": rate.modifier.username if rate.modifier else "系统",
        "modifier_role": rate.modifier.role if rate.modifier else None
    }

# 2. 获取费率修改历史记录 (管理员和财务均可访问)
@router.get("/daily")
def get_rate_history(
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
) -> Any:
    """获取所有费率修改的历史列表"""
    rates = (
        db.query(GlobalRate)
        .options(joinedload(GlobalRate.modifier))
        .order_by(GlobalRate.id.desc())
        .all()
    )
    
    result = []
    for r in rates:
        result.append({
            "id": r.id,
            "daily_rate": float(r.daily_rate),
            "updated_at": r.updated_at.strftime("%Y-%m-%d %H:%M:%S") if r.updated_at else None,
            "modifier_name": r.modifier.username if r.modifier else "Admin",
            "modifier_role": r.modifier.role if r.modifier else 1
        })
    return result

# 3. 修改费率 (仅限管理员访问)
@router.post("/daily/update")
def update_daily_rate(
    *,
    db: Session = Depends(get_db),
    new_rate: float = Query(..., gt=0, description="新的费率值"),
    current_user: Any = Depends(get_current_admin_user)
) -> Any:
    """新增费率记录，手动注入当前时间确保不会为 null"""
    try:
        # ✅ 核心改动：在 Python 层获取当前时间，精确到秒
        now = datetime.now()
        
        # 格式化费率数值
        decimal_rate = Decimal(str(round(new_rate, 2)))
        
        # 创建新记录并手动指定 updated_at
        new_record = GlobalRate(
            daily_rate=decimal_rate,
            last_modified_by_id=current_user.id,
            updated_at=now  # 👈 这里直接赋值，不依赖数据库默认值
        )
        
        db.add(new_record)
        db.commit()
        db.refresh(new_record)
        
        return {
            "status": "success", 
            "new_rate": float(new_record.daily_rate),
            # 立即返回格式化后的时间
            "updated_at": new_record.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
            "operator": current_user.username
        }
    except Exception as e:
        db.rollback()
        # 抛出具体的 500 错误方便排查
        raise HTTPException(status_code=500, detail=f"Database write error: {str(e)}")
    