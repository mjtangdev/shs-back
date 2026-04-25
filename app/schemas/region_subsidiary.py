from pydantic import BaseModel, ConfigDict
from typing import Optional, List

class RegionBase(BaseModel):
    name: str
    level: int
    parent_id: Optional[int] = None

class RegionCreate(BaseModel):
    name: str
    level: int  # 1 为市，2 为镇
    parent_id: Optional[int] = None  # Level 1 时可选，Level 2 时必填

class RegionRead(RegionBase):
    id: int
    children: List["RegionRead"] = []
    is_occupied: bool = False

    model_config = ConfigDict(from_attributes=True)

    @classmethod
    def model_validate(cls, obj, **kwargs):
        instance = super().model_validate(obj, **kwargs)
        instance.is_occupied = obj.subsidiary is not None
        return instance

class SubsidiaryCreate(BaseModel):
    name: str
    address: Optional[str] = None
    region_id: int

class SubsidiaryRead(BaseModel):
    id: int
    name: str
    address: Optional[str] = None
    region_id: int
    region_name: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

    @classmethod
    def model_validate(cls, obj, **kwargs):
        instance = super().model_validate(obj, **kwargs)
        if obj.region:
            instance.region_name = obj.region.name
        return instance