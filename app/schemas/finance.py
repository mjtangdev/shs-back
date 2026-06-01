from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime
from decimal import Decimal

class TransactionResponse(BaseModel):
    id: int
    transaction_id: str
    customer_uuid: str
    customer_name: Optional[str] = "-"
    card_uuid: Optional[str] = "-"
    days: Decimal
    amount: Decimal
    transaction_time: datetime
    action_type: str
    pos_sn: str
    operator_username: str
    region_name: Optional[str] = "-"

    model_config = ConfigDict(from_attributes=True)

class TransactionList(BaseModel):
    total: int
    items: List[TransactionResponse]

class FinanceSummaryResponse(BaseModel):
    total_amount: Decimal
    total_days: Decimal
    transaction_count: int

    model_config = ConfigDict(from_attributes=True)