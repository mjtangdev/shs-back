from sqlalchemy import Column, Integer, String, DateTime, event
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base_class import Base

class Card(Base):
    __tablename__ = "cards"

    id = Column(Integer, primary_key=True, index=True)
    # 物理唯一识别码 (为了数据迁移，暂时允许为空)
    card_number = Column(String(100), unique=True, index=True, nullable=True)
    card_uuid = Column(String(100), unique=True, index=True, nullable=False)
    
    # 核心状态机：
    # 0: In Stock (入库/在库)
    # 1: Activated (已绑定/出库)
    # 2: Blocked (锁定/挂失)
    # 3: Damaged (损坏/报废)
    status = Column(Integer, default=0, index=True)
    
    # 业务关联
    customer_uuid = Column(String(100), index=True, nullable=True)

    # 时间线
    created_at = Column(DateTime, default=datetime.now) # 入库时间
    bound_at = Column(DateTime, nullable=True)          # 绑定客户时间
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)

    # 逻辑关联 Customer
    customer = relationship(
        "Customer", 
        primaryjoin="Card.customer_uuid == Customer.uuid", 
        foreign_keys=[customer_uuid],
        viewonly=True
    )

# --- 强制强制大写逻辑 (Model Level Enforcement) ---
@event.listens_for(Card, 'before_insert')
@event.listens_for(Card, 'before_update')
def force_upper_uuid(mapper, connection, target):
    if target.card_uuid:
        target.card_uuid = target.card_uuid.strip().upper()
