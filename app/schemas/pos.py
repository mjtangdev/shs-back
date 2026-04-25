from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime

class POSBase(BaseModel):
    pos_sn: str

class POSCreate(POSBase):
    # 与数据库模型对齐，如果 region_id 在模型中是 Integer，这里建议后续改为 int
    region_id: Optional[str] = None 
    branch_office: Optional[str] = None
    status: Optional[int] = 0

class POSUpdate(BaseModel):
    """用于 PUT 编辑的校验模型"""
    region_id: Optional[str] = None
    branch_office: Optional[str] = None
    status: Optional[int] = None
    # 通常 pos_sn 是主键/唯一标识，不建议在 Update 中修改

class POSLockRequest(BaseModel):
    pos_sn: str
    remark: Optional[str] = None

class POSResponse(POSBase):
    status: int
    lock_status: int
    region_id: Optional[str] = None
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