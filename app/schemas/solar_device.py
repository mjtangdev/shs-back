from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List

# --- 1. 创建请求校验 ---
class SolarUnitCreate(BaseModel):
    shs_machine_id: str = Field(..., min_length=1, description="主机序列号")
    solar_equipment_id: Optional[str] = Field(None, description="太阳能板/设备ID (可选，默认根据主机ID生成)")
    radio_id: Optional[str] = Field(None, description="收音机ID (可选，默认根据主机ID生成)")
    flashlight_id: Optional[str] = Field(None, description="手电筒ID (可选，默认根据主机ID生成)")
    led_light_id: Optional[str] = Field(None, description="LED灯ID (可选，默认根据主机ID生成)")
    
    production_date: datetime
    city: Optional[str] = None
    town: Optional[str] = None

# --- 2. 响应基础模型 (用于列表中的每一项) ---
class SolarUnitItem(BaseModel):
    id: int
    shs_machine_id: str
    solar_equipment_id: str
    radio_id: str
    flashlight_id: str
    led_light_id: str
    status: int
    customer_id: Optional[int] = None # 新增：客户内部ID，用于跳转
    customer_uuid: Optional[str] = "-"
    customer_name: Optional[str] = "-"
    city_name: Optional[str] = "-"
    town_name: Optional[str] = "-"
    production_date: Optional[datetime] = None
    created_at: Optional[datetime] = None
    bound_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- 3. 统一列表响应模型 (解决你的 ImportError) ---
class SolarUnitList(BaseModel):
    total: int
    items: List[SolarUnitItem]

# --- 4. 单个对象详细响应 (可选) ---
class SolarUnitResponse(SolarUnitItem):
    pass