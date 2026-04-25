from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import List
from app.api import deps
from app.models.region_subsidiary import Region, Subsidiary
from app.schemas.region_subsidiary import (
    RegionRead, RegionCreate, 
    SubsidiaryRead, SubsidiaryCreate
)

router = APIRouter()

# ================= 区域管理 =================

@router.patch("/province", response_model=RegionRead, summary="设置或修改唯一的省份")
def update_province(
    name: str = Body(..., embed=True),
    db: Session = Depends(deps.get_db),
    current_admin=Depends(deps.get_current_admin_user)
):
    province = db.query(Region).filter(Region.level == 0).first()
    if not province:
        province = Region(name=name, level=0, parent_id=None)
        db.add(province)
    else:
        province.name = name
    db.commit()
    db.refresh(province)
    return province

@router.post("/", response_model=RegionRead, summary="添加市或镇")
def create_region(
    region_in: RegionCreate,
    db: Session = Depends(deps.get_db),
    current_admin=Depends(deps.get_current_admin_user)
):
    # 核心：寻找唯一的省
    province = db.query(Region).filter(Region.level == 0).first()
    if not province:
        raise HTTPException(status_code=400, detail="Please set the province name first")

    new_data = region_in.model_dump()

    if region_in.level == 1:
        # 自动挂载到省
        new_data["parent_id"] = province.id
    elif region_in.level == 2:
        if not region_in.parent_id:
            raise HTTPException(status_code=400, detail="Parent city ID must be specified when adding a town")
        # 验证所属市是否存在且层级正确
        parent = db.query(Region).filter(Region.id == region_in.parent_id, Region.level == 1).first()
        if not parent:
            raise HTTPException(status_code=400, detail="Invalid parent city ID")
    else:
        raise HTTPException(status_code=400, detail="Unsupported region level")

    new_region = Region(**new_data)
    db.add(new_region)
    db.commit()
    db.refresh(new_region)
    return new_region

@router.get("/tree", response_model=RegionRead, summary="获取行政区划树")
def get_region_tree(db: Session = Depends(deps.get_db)):
    province = db.query(Region).filter(Region.level == 0).first()
    if not province:
        raise HTTPException(status_code=404, detail="Data not initialized")
    return province

# ================= 子公司管理 =================

@router.post("/subsidiaries", response_model=SubsidiaryRead, summary="分配子公司")
def create_subsidiary(
    sub_in: SubsidiaryCreate,
    db: Session = Depends(deps.get_db),
    current_admin=Depends(deps.get_current_admin_user)
):
    region = db.query(Region).filter(Region.id == sub_in.region_id).first()
    if not region:
        raise HTTPException(status_code=404, detail="Region not found")
    
    # 1对1校验
    if db.query(Subsidiary).filter(Subsidiary.region_id == sub_in.region_id).first():
        raise HTTPException(status_code=400, detail=f"Region '{region.name}' already has a subsidiary assigned")

    new_sub = Subsidiary(**sub_in.model_dump())
    db.add(new_sub)
    db.commit()
    db.refresh(new_sub)
    return new_sub

@router.get("/subsidiaries", response_model=List[SubsidiaryRead])
def list_subsidiaries(db: Session = Depends(deps.get_db)):
    return db.query(Subsidiary).all()