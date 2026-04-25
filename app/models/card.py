from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base_class import Base

class Card(Base):
    __tablename__ = "cards"

    id = Column(Integer, primary_key=True, index=True)
    # 物理唯一识别码
    card_number = Column(String(100), unique=True, index=True, nullable=False)
    card_uuid = Column(String(100), unique=True, index=True, nullable=False)
    
    # 核心状态机：
    # 0: In Stock (入库/在库)
    # 1: Activated (已绑定/出库)
    # 2: Blocked (锁定/挂失)
    # 3: Damaged (损坏/报废)
    status = Column(Integer, default=0, index=True)
    
    # 业务关联
    customer_uuid = Column(String(50), index=True, nullable=True)

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