from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import date, datetime

class CustomerBase(BaseModel):
    first_name: str = Field(..., max_length=50)
    last_name: str = Field(..., max_length=50)
    # 性别校验：支持大小写，在后端统一处理
    gender: str = Field(..., pattern="^(male|female|MALE|FEMALE|Male|Female)$")
    mobile: str = Field(..., max_length=20)
    email: Optional[EmailStr] = Field(None, max_length=100)
    birthday: Optional[date] = None # 生日现在是选填的
    address: Optional[str] = Field(None, max_length=255) # 详细地址现在是选填的
    
    # 新增字段
    beneficiary_count: Optional[int] = 0
    representative_name: Optional[str] = Field(None, max_length=100)
    rep_relationship: Optional[str] = Field("-", max_length=50)

class CustomerCreate(CustomerBase):
    """手动创建客户时使用的模型"""
    region_id: int # 手动输入时需要明确指定所属区域 ID

class CustomerUpdate(BaseModel):
    """用于 PUT 编辑的校验模型，所有字段均为可选"""
    first_name: Optional[str] = Field(None, max_length=50)
    last_name: Optional[str] = Field(None, max_length=50)
    gender: Optional[str] = Field(None, pattern="^(male|female|MALE|FEMALE|Male|Female)$")
    mobile: Optional[str] = Field(None, max_length=20)
    email: Optional[EmailStr] = Field(None, max_length=100)
    birthday: Optional[date] = None
    address: Optional[str] = Field(None, max_length=255)
    region_id: Optional[int] = None

class CustomerExcelImport(CustomerBase):
    """专门用于 Excel 批量导入的校验模型"""
    pass

class CustomerOut(BaseModel):
    """用于 API 返回的标准化输出模型"""
    id: int
    uuid: str
    first_name: str
    last_name: str
    gender: str
    mobile: str
    email: Optional[str] = None
    birthday: Optional[date] = None
    address: Optional[str] = None
    region_id: int
    status: int
    
    # 新增字段
    electric_company: Optional[str] = None
    beneficiary_count: Optional[int] = 0
    representative_name: Optional[str] = None
    rep_relationship: Optional[str] = "-"
    expiry_time: Optional[datetime] = None

    created_at: datetime

    class Config:
        from_attributes = True

# 分页返回格式
class CustomerPagination(BaseModel):
    total: int
    items: List[CustomerOut]