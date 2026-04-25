from pydantic import BaseModel, ConfigDict, EmailStr
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    username: str
    first_name: str
    last_name: str
    mobile: str
    email: Optional[EmailStr] = None
    
    # --- 核心业务字段 ---
    role: int = 2  # 1: Admin, 2: Operator, 3: Finance
    position: Optional[str] = None
    
    # --- 地理信息 ---
    province: Optional[str] = "Pangasinan"
    city_id: Optional[int] = None
    town_id: Optional[int] = None
    address: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserRead(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    mobile: Optional[str] = None
    email: Optional[EmailStr] = None
    city_id: Optional[int] = None
    town_id: Optional[int] = None
    address: Optional[str] = None
    province: Optional[str] = None
    role: Optional[int] = None
    position: Optional[str] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None

    model_config = ConfigDict(from_attributes=True)