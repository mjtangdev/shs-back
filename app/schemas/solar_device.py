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
    shs_machine_id: Optional[str] = "-"
    solar_equipment_id: Optional[str] = "-"
    radio_id: Optional[str] = "-"
    flashlight_id: Optional[str] = "-"
    led_light_id: Optional[str] = "-"
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

# --- 5. 单独绑定/更新 PV 序列号 ---
class SolarUnitPVBind(BaseModel):
    solar_equipment_id: str = Field(..., min_length=1, description="单独绑定的 PV 光伏板序列号")

# --- 6. 独立 PV 太阳能光伏板解耦模型 ---
class SolarPVPanelCreate(BaseModel):
    pv_sn: str = Field(..., min_length=1, description="PV 光伏板序列号")
    production_date: Optional[datetime] = None
    city: Optional[str] = None
    town: Optional[str] = None

class SolarPVPanelItem(BaseModel):
    id: int
    pv_sn: str
    status: int
    shs_machine_id: Optional[str] = "-"
    customer_uuid: Optional[str] = "-"
    customer_name: Optional[str] = "-"
    city_name: Optional[str] = "-"
    town_name: Optional[str] = "-"
    production_date: Optional[datetime] = None
    created_at: Optional[datetime] = None
    bound_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class SolarPVPanelList(BaseModel):
    total: int
    items: List[SolarPVPanelItem]

class SolarPVPanelUpdate(BaseModel):
    pv_sn: Optional[str] = None
    status: Optional[int] = None # 0: 在库, 1: 已绑定, 2: 冻结, 3: 损坏报废
    shs_machine_id: Optional[str] = None
    customer_uuid: Optional[str] = None