from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import date, datetime

class CustomerBase(BaseModel):
    first_name: str
    last_name: str
    # 修改点：改为小写匹配，以兼容后端自动转换逻辑
    gender: str = Field(..., pattern="^(male|female)$") 
    mobile: str
    email: Optional[EmailStr] = None
    birthday: Optional[date] = None
    address: Optional[str] = None # 详细地址字段

class CustomerCreate(CustomerBase):
    """手动创建客户时使用的模型"""
    region_id: int # 手动输入时需要明确指定所属区域 ID

class CustomerUpdate(BaseModel):
    """用于 PUT 编辑的校验模型，所有字段均为可选"""
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    gender: Optional[str] = Field(None, pattern="^(male|female)$")
    mobile: Optional[str] = None
    email: Optional[EmailStr] = None
    birthday: Optional[date] = None
    address: Optional[str] = None
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
    created_at: datetime

    class Config:
        from_attributes = True

# 分页返回格式
class CustomerPagination(BaseModel):
    total: int
    items: List[CustomerOut]