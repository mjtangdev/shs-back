from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Any
from datetime import datetime
from app.schemas.config import ProviderConfigRead # 导入 ProviderConfigRead

class POSBase(BaseModel):
    pos_sn: str

class POSCreate(POSBase):
    region_id: Optional[int] = None 
    branch_office: Optional[str] = None
    status: Optional[int] = 0
    assigned_user_id: Optional[int] = None

class POSUpdate(BaseModel):
    """用于 PATCH 编辑的校验模型"""
    region_id: Optional[int] = None
    branch_office: Optional[str] = None
    status: Optional[int] = None
    assigned_user_id: Optional[int] = None
    lock_status: Optional[int] = None

class POSLockRequest(BaseModel):
    pos_sn: str
    password: str
    remark: Optional[str] = None

class POSResponse(POSBase):
    status: int
    lock_status: int
    region_id: Optional[int] = None
    branch_office: Optional[str] = None
    assigned_user_id: Optional[int] = None
    assigned_user_name: Optional[str] = None
    last_lock_reason: Optional[str] = None
    last_action_by: Optional[str] = None
    last_login_at: Optional[datetime] = None
    last_ip: Optional[str] = None
    mac_address: Optional[str] = None
    latitude: Optional[str] = None
    longitude: Optional[str] = None
    app_version: Optional[str] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class POSLogResponse(BaseModel):
    action_type: str
    operator: str
    role: Optional[str] = None
    remark: Optional[str] = None
    timestamp: datetime
    model_config = ConfigDict(from_attributes=True)

class POSList(BaseModel):
    total: int
    items: List[POSResponse]
    model_config = ConfigDict(from_attributes=True)

# --- POS 同步专用模型 ---

class POSSyncCustomerItem(BaseModel):
    id: int # 数据库物理ID，用于 since_id 翻页
    uuid: str
    first_name: str
    last_name: str
    card_uuid: Optional[str] = None
    shs_machine_id: Optional[str] = None
    status: int  # 1: 活跃, 0: 停用
    expiry_date: Optional[datetime] = None 
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class POSSyncCardItem(BaseModel):
    id: int
    card_number: str
    card_uuid: str
    customer_uuid: Optional[str] = None
    status: int
    updated_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class POSSyncSolarUnitItem(BaseModel):
    id: int
    shs_machine_id: str
    solar_equipment_id: Optional[str] = None
    radio_id: Optional[str] = None
    flashlight_id: Optional[str] = None
    led_light_id: Optional[str] = None
    customer_uuid: Optional[str] = None
    shs_status: int
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class POSSyncResponse(BaseModel):
    server_time: datetime
    # 1. 基础配置
    provider: ProviderConfigRead
    # 2. 费率信息
    daily_rate: float
    region_name: str
    # 3. 客户白名单 (仅限本区域)
    customers: List[POSSyncCustomerItem]
    # 4. 锁定状态 (防止 POS 被盗后继续离线扣费)
    is_locked: bool
    # 5. 在库未绑定资产列表 (用于离线绑定挑选)
    cards: List[POSSyncCardItem] = []
    solar_units: List[POSSyncSolarUnitItem] = []

    model_config = ConfigDict(from_attributes=True)

# --- POS 离线数据上传模型 ---

class POSOfflineTransaction(BaseModel):
    transaction_id: str          # POS 端生成的唯一交易 ID
    customer_uuid: str
    card_uuid: str
    days: float = Field(..., gt=0, description="充值天数")
    shs_machine_id: Optional[str] = None
    amount: float = Field(..., gt=0, description="充值金额，必须大于0") # 强制金额大于0
    transaction_time: datetime
    action_type: str            # RECHARGE (充值), COLLECT (收款) 等
    operator_username: str      # 强制必填：离线操作的实际业务员用户名
    latitude: Optional[str] = None  # 离线记录的纬度
    longitude: Optional[str] = None # 离线记录的经度

class POSOfflineCustomerCreate(BaseModel):
    uuid: str
    first_name: str
    last_name: str
    gender: str
    mobile: str
    email: Optional[str] = None
    birthday: Optional[datetime] = None
    address: Optional[str] = None
    region_id: int
    card_uuid: Optional[str] = None      # 离线绑定的卡片
    shs_machine_id: Optional[str] = None # 离线绑定的设备
    created_at: datetime                 # POS 端的实际操作时间
    operator_username: str               # 强制必填：离线操作的实际业务员用户名

class POSLoginRequest(BaseModel):
    username: str
    password: str
    pos_sn: str
    latitude: Optional[str] = None
    longitude: Optional[str] = None
    app_version: Optional[str] = None
    version_type: Optional[str] = None
    mac_address: Optional[str] = None

class POSSyncUploadRequest(BaseModel):
    pos_sn: Optional[str] = None
    # 增量上传的变动数据
    new_customers: List[POSOfflineCustomerCreate] = [] # 结构化后的客户列表
    transactions: List[POSOfflineTransaction] = [] # 离线交易流水

    model_config = ConfigDict(from_attributes=True)