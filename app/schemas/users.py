from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50, pattern="^[a-zA-Z0-9_-]+$")
    first_name: str = Field(..., min_length=1, max_length=50)
    last_name: str = Field(..., min_length=1, max_length=50)
    mobile: str # 移除了手机号的正则限制，现在可以输入任意字符
    email: Optional[EmailStr] = None
    
    # --- 核心业务字段 ---
    role: int = 2  # 1: Admin, 2: Operator, 3: Finance
    
    # --- 地理信息 ---
    province: Optional[str] = "Pangasinan"
    region_id: Optional[int] = None  # 所属区域 ID
    address: Optional[str] = None

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

    model_config = ConfigDict(from_attributes=True)

class UserUpdate(BaseModel):
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