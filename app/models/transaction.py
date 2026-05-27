from sqlalchemy import Column, Integer, String, DateTime, Numeric, ForeignKey
from datetime import datetime
from app.db.base_class import Base

class TransactionLog(Base):
    """
    财务交易流水表
    用于记录 POS 上传的充值和扣费流水，实现幂等性校验。
    """
    __tablename__ = "transaction_logs"

    id = Column(Integer, primary_key=True, index=True)
    # 幂等键：POS 端生成的唯一交易 ID
    transaction_id = Column(String(100), unique=True, index=True, nullable=False)
    
    customer_uuid = Column(String(100), index=True, nullable=False)
    card_uuid = Column(String(100), index=True, nullable=False)
    shs_machine_id = Column(String(100), nullable=True, comment="交易关联的设备ID")
    days = Column(Numeric(10, 2), nullable=False, default=0)
    amount = Column(Numeric(10, 2), nullable=False)
    transaction_time = Column(DateTime, nullable=False)
    action_type = Column(String(50)) # RECHARGE, COLLECT, etc.
    
    pos_sn = Column(String(16), index=True)
    operator_username = Column(String(50), index=True)
    created_at = Column(DateTime, default=datetime.now)