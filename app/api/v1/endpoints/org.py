from fastapi import APIRouter, Depends, HTTPException, Body, Query, status
from sqlalchemy.orm import Session, joinedload
from typing import List
from decimal import Decimal
from datetime import datetime, timezone

from app.api import deps
from app.models.org import Region, BusinessEntity
from app.models.users import User
from app.schemas.org import (
    RegionRead, RegionCreate, RegionUpdate,
    EntityRead, EntityCreate, EntityUpdate
)


router = APIRouter()

# --- 区域管理 ---

@router.patch("/regions/update-rate", tags=["区域费率"])
def update_region_rate(
    region_id: int = Body(..., embed=True, description="Target Region ID to update"),
    new_rate: float = Body(..., embed=True, gt=0, description="New daily rate value"),
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_finance_or_admin)
):
    """
    修改特定地区的费率 - 仅限财务或管理员。
    通过 Body 传递 region_id，前端无需拼接 URL。
    """
    region = db.query(Region).filter(Region.id == region_id).first()
    if not region:
        raise HTTPException(status_code=404, detail="Region not found")

    try:
        # 强制控制在小数点后两位并转为 Decimal
        region.daily_rate = Decimal(str(round(new_rate, 2)))
        region.last_rate_updated_at = datetime.now()
        region.last_rate_modified_by_id = current_user.id
        
        db.commit()
        return {
            "status": "success", 
            "region_name": region.name, 
            "new_rate": float(region.daily_rate)
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@router.patch("/regions/sync-all-rates", tags=["区域费率"])
def sync_all_region_rates(
    new_rate: float = Body(..., embed=True, gt=0, description="新的全局统一费率值"),
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_finance_or_admin)
):
    """
    一键同步所有地区的费率 - 仅限财务或管理员。
    此接口用于自动化统一整体费率，特别是系统初始化地区但未设置费率时。
    """
    try:
        now = datetime.now()
        # 强制控制在小数点后两位并转为高精度 Decimal
        rate_dec = Decimal(str(round(new_rate, 2)))

        # 使用 SQLAlchemy 的批量更新，效率最高
        updated_count = db.query(Region).update({
            Region.daily_rate: rate_dec,
            Region.last_rate_updated_at: now,
            Region.last_rate_modified_by_id: current_user.id
        }, synchronize_session=False)

        db.commit()
        
        return {
            "status": "success",
            "updated_regions": updated_count,
            "global_rate": float(rate_dec)
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Global sync failed: {str(e)}")

@router.patch("/regions/update-name", response_model=RegionRead)
def update_region(
    region_id: int = Body(..., embed=True),
    name: str = Body(..., embed=True),
    db: Session = Depends(deps.get_db),
    current_user: deps.User = Depends(deps.get_current_admin_user)
):
    """修改地区名称 - 仅限管理员"""
    region = db.query(Region).options(joinedload(Region.entity)).filter(Region.id == region_id).first()
    if not region:
        raise HTTPException(status_code=404, detail="Region not found")

    if name:
        region.name = name

    db.commit()
    db.refresh(region)
    return region

@router.post("/regions/", response_model=RegionRead)
def create_region(
    region_in: RegionCreate, 
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_admin_user)
):
    """创建新地区 - 仅限管理员，自动根据父级确定层级"""
    # 1. 寻找父级区域
    if region_in.parent_id == 0:
        # 传递 0 视为在根省份下创建（结果将是 City 级别）
        parent = db.query(Region).filter(Region.level == 0).first()
    else:
        parent = db.query(Region).filter(Region.id == region_in.parent_id).first()

    if not parent:
        raise HTTPException(status_code=404, detail="Parent region not found")

    # 2. 自动计算层级：新区域层级 = 父级层级 + 1
    new_level = parent.level + 1
    if new_level > 2:
        raise HTTPException(status_code=400, detail="Maximum region depth reached (Town level)")

    # 3. 创建实例
    new_reg = Region(
        name=region_in.name,
        level=new_level,
        parent_id=parent.id
    )
    db.add(new_reg)
    db.commit()
    db.refresh(new_reg)
    return new_reg

@router.get("/regions/tree", response_model=RegionRead)
def get_tree(
    db: Session = Depends(deps.get_db), 
    current_user=Depends(deps.get_current_user)
):
    # 如果用户的 region_id 有效（不为 None 也不为 0），则严格只返回他管辖的区域子树
    if current_user.region_id and current_user.region_id != 0:
        region = db.query(Region).options(joinedload(Region.entity)).filter(Region.id == current_user.region_id).first()
        if not region:
            raise HTTPException(status_code=404, detail="Assigned region not found")
        return region

    # 如果是超级管理员(0)，或尚未分配地区(region_id=0/None)的管理员(1)/财务(3)，返回全省完整树
    if current_user.role in [0, 1, 3]:
        root_region = db.query(Region).options(joinedload(Region.entity)).filter(Region.level == 0).first()
        if not root_region:
            raise HTTPException(status_code=404, detail="Root province not found")
        return root_region
        
    raise HTTPException(status_code=403, detail="Operator has no assigned region")

@router.get("/regions/{region_id}/rate")
def get_region_rate(
    region_id: int,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_user)
):
    """获取指定地区的费率（已取消继承逻辑，仅返回本级费率）"""
    region = db.query(Region).filter(Region.id == region_id).first()
    if not region:
        raise HTTPException(status_code=404, detail="Region not found")

    rate_val = region.daily_rate
    return {
        "region_id": region_id,
        "daily_rate": float(rate_val) if rate_val is not None else 0.0, # 确保返回浮点数，且None时为0.0
        "region_name": region.name, # 增加返回区域名称
        "updated_at": region.last_rate_updated_at.isoformat() if region.last_rate_updated_at else None, # 使用 ISO 格式或 None
    }

# --- 业务主体管理 ---

@router.post("/entities/", response_model=EntityRead)
def create_entity(
    entity_in: EntityCreate, 
    db: Session = Depends(deps.get_db), # 依赖项放在后面
    current_user=Depends(deps.get_current_admin_user)
):
    # 1. 检查名称重复
    if db.query(BusinessEntity).filter(BusinessEntity.name == entity_in.name).first():
        raise HTTPException(status_code=400, detail="Entity name already exists")
    
    # 2. 检查区域占用和层级限制
    if entity_in.region_id:
        target_region = db.query(Region).filter(Region.id == entity_in.region_id).first()
        if not target_region:
            raise HTTPException(status_code=404, detail="Target region not found")
        
        if target_region.level == 0:
            raise HTTPException(status_code=400, detail="Head office level (Level 0) cannot be assigned a subsidiary or agent")

        if db.query(BusinessEntity).filter(BusinessEntity.region_id == entity_in.region_id).first():
            raise HTTPException(status_code=400, detail="This region is already occupied")
    
    new_ent = BusinessEntity(**entity_in.model_dump())
    db.add(new_ent)
    db.commit()
    # refresh 很重要，它会触发 lazy="joined" 去拉取关联数据
    db.refresh(new_ent) 
    return new_ent

@router.get("/entities/", response_model=List[EntityRead])
def list_entities(db: Session = Depends(deps.get_db), current_user=Depends(deps.get_current_user)):
    query = db.query(BusinessEntity).filter(BusinessEntity.is_deleted == False).options(joinedload(BusinessEntity.region))
    
    # 业务员(2)过滤：仅显示所属地区的业务主体
    if current_user.role == 2:
        target_id = current_user.region_id
        if target_id is not None:
            query = query.filter(BusinessEntity.region_id == target_id)
            
    return query.order_by(BusinessEntity.id.asc()).all()

@router.get("/entities/{entity_id}", response_model=EntityRead)
def get_entity_by_id(
    entity_id: int,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_user)
):
    """
    获取单个业务主体信息 - ID 通过 URL 路径传递。
    管理员和财务可查看所有，业务员仅可查看其所属区域的主体。
    """
    query = db.query(BusinessEntity).filter(
        BusinessEntity.id == entity_id,
        BusinessEntity.is_deleted == False
    ).options(joinedload(BusinessEntity.region))

    # 业务员(2)过滤：仅显示所属地区的业务主体
    if current_user.role == 2:
        target_id = current_user.region_id
        if target_id is None:
            raise HTTPException(status_code=403, detail="Operator has no assigned region")
        query = query.filter(BusinessEntity.region_id == target_id)

    entity = query.first()
    if not entity:
        raise HTTPException(status_code=404, detail="Entity not found or not accessible")
    
    return entity

@router.patch("/entities/update", response_model=EntityRead)
def update_entity(
    entity_id: int = Body(..., embed=True), 
    entity_in: EntityUpdate = Body(...), 
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_admin_user)
):
    """更新子公司/代理商信息 - ID 通过 Body 传递"""
    # 增加 is_deleted=False 过滤，确保不会更新已删除的主体
    entity = db.query(BusinessEntity).filter(
        BusinessEntity.id == entity_id, 
        BusinessEntity.is_deleted == False
    ).first()
    if not entity:
        raise HTTPException(status_code=404, detail="Entity not found")
    
    update_data = entity_in.model_dump(exclude_unset=True)

    # 检查新分配的区域（如果 region_id 为 None 则跳过检查，表示解除绑定）
    if update_data.get("region_id") is not None:
        target_region = db.query(Region).filter(Region.id == update_data["region_id"]).first()
        if not target_region:
            raise HTTPException(status_code=404, detail="Target region not found")
        
        if target_region.level == 0:
            raise HTTPException(status_code=400, detail="Head office level (Level 0) cannot be assigned a subsidiary or agent")

        occupied = db.query(BusinessEntity).filter(
            BusinessEntity.region_id == update_data["region_id"], 
            BusinessEntity.id != entity_id
        ).first()
        if occupied:
            raise HTTPException(status_code=400, detail="Region is already occupied")

    for key, value in update_data.items():
        setattr(entity, key, value)
    
    db.commit()
    db.refresh(entity)
    return entity

@router.delete("/entities/delete")
def delete_entity(
    entity_id: int = Body(..., embed=True), 
    db: Session = Depends(deps.get_db), # 依赖项放在后面
    current_user=Depends(deps.get_current_admin_user)
):
    """逻辑删除业务主体 - ID 通过 Body 传递"""
    entity = db.query(BusinessEntity).filter(BusinessEntity.id == entity_id, BusinessEntity.is_deleted == False).first()
    if entity:
        # 执行逻辑删除
        entity.is_deleted = True
        # 解除地区绑定，释放该地区位置
        entity.region_id = None
        db.commit()

    return {"status": "success"}