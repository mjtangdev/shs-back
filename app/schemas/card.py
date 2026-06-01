from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class CardBase(BaseModel):
    card_number: str | None = None # 暂时设为选填，方便老数据迁移
    card_uuid: str

class CardCreate(CardBase):
    pass

class CardUpdate(BaseModel):
    card_number: str | None = None

class CardResponse(CardBase):
    id: int
    card_number: str | None = None
    card_uuid: str
    status: int
    customer_id: Optional[int] = None # Added for frontend navigation
    customer_uuid: Optional[str] = None
    customer_name: Optional[str] = "-"
    city_name: Optional[str] = "-"
    town_name: Optional[str] = "-"
    created_at: Optional[datetime] = None
    bound_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class CardList(BaseModel):
    total: int
    items: List[CardResponse]