from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session, joinedload
from typing import List
from app.api import deps
from app.models.org import Region, BusinessEntity
from app.schemas.org import (
    RegionRead, RegionCreate, 
    EntityRead, EntityCreate, EntityUpdate
)

router = APIRouter()

# --- 区域管理 ---

@router.patch("/regions/province", response_model=RegionRead)
def update_province(name: str = Body(..., embed=True), db: Session = Depends(deps.get_db)):
    province = db.query(Region).filter(Region.level == 0).first()
    if not province:
        province = Region(id=1, name=name, level=0)
        db.add(province)
    else:
        province.name = name
    db.commit()
    db.refresh(province)
    return province

@router.post("/regions/", response_model=RegionRead)
def create_region(region_in: RegionCreate, db: Session = Depends(deps.get_db)):
    province = db.query(Region).filter(Region.level == 0).first()
    if not province:
        raise HTTPException(status_code=400, detail="Please initialize the province first")
    
    new_data = region_in.model_dump()
    if region_in.level == 1:
        new_data["parent_id"] = province.id
    
    new_reg = Region(**new_data)
    db.add(new_reg)
    db.commit()
    db.refresh(new_reg)
    return new_reg

@router.get("/regions/tree", response_model=RegionRead)
def get_tree(db: Session = Depends(deps.get_db)):
    return db.query(Region).filter(Region.level == 0).first()

# --- 业务主体管理 ---

@router.post("/entities/", response_model=EntityRead)
def create_entity(entity_in: EntityCreate, db: Session = Depends(deps.get_db)):
    # 1. 检查名称重复
    if db.query(BusinessEntity).filter(BusinessEntity.name == entity_in.name).first():
        raise HTTPException(status_code=400, detail="Entity name already exists")
    
    # 2. 检查区域占用
    if entity_in.region_id:
        if db.query(BusinessEntity).filter(BusinessEntity.region_id == entity_in.region_id).first():
            raise HTTPException(status_code=400, detail="This region is already occupied")
    
    new_ent = BusinessEntity(**entity_in.model_dump())
    db.add(new_ent)
    db.commit()
    # refresh 很重要，它会触发 lazy="joined" 去拉取关联数据
    db.refresh(new_ent) 
    return new_ent

@router.get("/entities/", response_model=List[EntityRead])
def list_entities(db: Session = Depends(deps.get_db)):
    # 显式使用 joinedload 确保 region 数据被查出
    return db.query(BusinessEntity).options(joinedload(BusinessEntity.region)).all()

@router.patch("/entities/{entity_id}", response_model=EntityRead)
def update_entity(entity_id: int, entity_in: EntityUpdate, db: Session = Depends(deps.get_db)):
    entity = db.query(BusinessEntity).filter(BusinessEntity.id == entity_id).first()
    if not entity:
        raise HTTPException(status_code=404, detail="Entity not found")
    
    update_data = entity_in.model_dump(exclude_unset=True)
    if "region_id" in update_data and update_data["region_id"]:
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

@router.delete("/entities/{entity_id}")
def delete_entity(entity_id: int, db: Session = Depends(deps.get_db)):
    entity = db.query(BusinessEntity).filter(BusinessEntity.id == entity_id).first()
    if entity:
        db.delete(entity)
        db.commit()
    return {"status": "success"}