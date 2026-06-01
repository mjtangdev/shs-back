from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator
from typing import Optional, Any
from datetime import datetime

class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50, pattern="^[a-zA-Z0-9_-]+$")
    first_name: str = Field(..., min_length=1, max_length=50)
    last_name: str = Field(..., min_length=1, max_length=50)
    mobile: str = Field(..., min_length=5, max_length=20) # 强制手机号必填且限制长度
    email: Optional[EmailStr] = None # 改为可选
    
    # --- 核心业务字段 ---
    role: int = 2  # 0:SuperAdmin, 1:Admin, 2:Operator, 3:Finance, 4:Management
    
    # --- 地理信息 ---
    province: Optional[str] = "Pangasinan"
    region_id: Optional[int] = None  # 设为可选，我们将通过 validator 智能填充
    address: Optional[str] = None

    @field_validator('region_id', mode='before')
    @classmethod
    def set_default_region(cls, v, info: Any):
        # 获取当前请求中的 role 值
        role = info.data.get('role', 2) # 默认为 2
        # 如果是 Admin(1) 或 Finance(3)，且 region_id 为空，默认设为 1 (总部)
        if role in [0, 1, 3] and v is None:
            return 1
        # 如果是业务员且没传 region_id，抛出错误
        if role == 2 and v is None:
            raise ValueError("Region ID is required for Operator roles.")
        return v

class UserCreate(UserBase):
    password: str = Field(..., max_length=100) # 移除了密码最短 8 位的限制

    @field_validator('password')
    def password_not_weak(cls, v):
        if v == "admin123":
            raise ValueError("Password is too weak. Please do not use 'admin123'.")
        return v

class UserRead(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    
    # 增强显示字段：由后端解析后带入
    city_name: Optional[str] = None
    town_name: Optional[str] = None
    entity_name: Optional[str] = None  # 👈 这里带入子公司/主体名称
    pos_sn: Optional[str] = None # 👈 这里带入绑定的 POS SN

    model_config = ConfigDict(from_attributes=True)

class UserUpdate(BaseModel):
    user_id: int # 👈 重新放回 ID，支持平铺 JSON 解析
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    mobile: Optional[str] = None
    email: Optional[EmailStr] = None
    region_id: Optional[int] = None
    address: Optional[str] = None
    province: Optional[str] = None
    role: Optional[int] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None

    model_config = ConfigDict(from_attributes=True)