from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import Optional, List

# --- 区域 Schema ---
class RegionCreate(BaseModel):
    name: str
    level: int 
    parent_id: Optional[int] = None

class RegionRead(BaseModel):
    id: int
    name: str
    level: int
    parent_id: Optional[int] = None
    children: List["RegionRead"] = []
    is_occupied: bool = False

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="before")
    @classmethod
    def check_entity(cls, data):
        if hasattr(data, "entity") and data.entity:
            setattr(data, "is_occupied", True)
        return data

# --- 业务主体 Schema ---
class EntityCreate(BaseModel):
    name: str
    entity_type: int = Field(1, ge=1, le=2)
    address: Optional[str] = None
    region_id: Optional[int] = None

class EntityUpdate(BaseModel):
    name: Optional[str] = None
    entity_type: Optional[int] = None
    address: Optional[str] = None
    region_id: Optional[int] = None

class EntityRead(BaseModel):
    id: int
    name: str
    entity_type: int
    address: Optional[str] = None
    region_id: Optional[int] = None
    region_name: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="before")
    @classmethod
    def get_region_name(cls, data):
        # 强制从关联的 region 对象中提取 name 并赋值给 region_name
        if hasattr(data, "region") and data.region:
            setattr(data, "region_name", data.region.name)
        return data