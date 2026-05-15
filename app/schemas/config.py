from pydantic import BaseModel
from typing import Optional

class ProviderConfigBase(BaseModel):
    name: str  # 与 Model 对齐
    tin: str   # 初始创建建议设为必填
    logo_url: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None  # 与 Model 对齐
    address: Optional[str] = None # 增加 address 字段支持

class ProviderConfigCreate(ProviderConfigBase):
    pass

class ProviderConfigUpdate(BaseModel):
    name: Optional[str] = None
    tin: Optional[str] = None
    logo_url: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None

class ProviderConfigRead(ProviderConfigBase):
    id: int

    class Config:
        from_attributes = True