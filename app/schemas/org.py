from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import Optional, List
from decimal import Decimal
from enum import IntEnum

class EntityType(IntEnum):
    SUBSIDIARY = 1  # 子公司
    AGENT = 2       # 代理人

# --- 区域 Schema ---
class RegionCreate(BaseModel):
    name: str
    parent_id: Optional[int] = None  # None 或 0 表示根节点（省份/总部）
    daily_rate: Optional[Decimal] = None
    # level 建议由后端根据 parent_id 自动计算，无需前端传入，以防层级错乱

class RegionUpdate(BaseModel):
    name: Optional[str] = None

class RegionBulkRateUpdate(BaseModel):
    """用于前端第一次设置时，统一初始化所有地区的费率"""
    daily_rate: Decimal = Field(..., gt=0, description="统一设置的费率值")

class RegionRead(BaseModel):
    id: int
    name: str
    level: int
    parent_id: Optional[int] = None
    daily_rate: Optional[Decimal] = None
    entity: Optional["EntityRead"] = None   # 任何层级均可关联主体
    children: List["RegionRead"] = []       # 递归支持任意深度（1-N层）
    is_occupied: bool = False               # 标识当前节点是否已被占用

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
    entity_type: EntityType = Field(default=EntityType.SUBSIDIARY)
    address: Optional[str] = None
    region_id: Optional[int] = None

class EntityUpdate(BaseModel):
    name: Optional[str] = None
    entity_type: Optional[EntityType] = None
    address: Optional[str] = None
    region_id: Optional[int] = None

class EntityRead(BaseModel):
    id: int
    name: str
    entity_type: EntityType
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