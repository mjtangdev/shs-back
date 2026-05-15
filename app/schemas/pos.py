from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Any
from datetime import datetime
from app.schemas.config import ProviderConfigRead # 导入 ProviderConfigRead

class POSBase(BaseModel):
    pos_sn: str

class POSCreate(POSBase):
    # 与数据库模型对齐，如果 region_id 在模型中是 Integer，这里建议后续改为 int
    region_id: Optional[int] = None 
    branch_office: Optional[str] = None
    status: Optional[int] = 0

class POSUpdate(BaseModel):
    """用于 PUT 编辑的校验模型"""
    region_id: Optional[int] = None
    branch_office: Optional[str] = None
    status: Optional[int] = None
    # 通常 pos_sn 是主键/唯一标识，不建议在 Update 中修改

class POSLockRequest(BaseModel):
    pos_sn: str
    remark: Optional[str] = None

class POSResponse(POSBase):
    status: int
    lock_status: int
    region_id: Optional[int] = None
    branch_office: Optional[str] = None
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
    uuid: str
    full_name: str
    card_uuid: Optional[str] = None
    shs_machine_id: Optional[str] = None
    status: int  # 1: 活跃, 0: 停用
    expiry_date: Optional[datetime] = None # 👈 增加到期时间

    model_config = ConfigDict(from_attributes=True)

class POSSyncCardItem(BaseModel):
    card_number: str
    card_uuid: str
    model_config = ConfigDict(from_attributes=True)

class POSSyncSolarUnitItem(BaseModel):
    shs_machine_id: str
    solar_equipment_id: str
    radio_id: str
    flashlight_id: str
    led_light_id: str
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

class POSSyncUploadRequest(BaseModel):
    pos_sn: Optional[str] = None
    # 增量上传的变动数据
    new_customers: List[POSOfflineCustomerCreate] = [] # 结构化后的客户列表
    transactions: List[POSOfflineTransaction] = [] # 离线交易流水

    model_config = ConfigDict(from_attributes=True)