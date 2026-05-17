import uuid
from sqlalchemy import Column, Integer, String, Date, DateTime, func, ForeignKey, Numeric
from sqlalchemy.orm import relationship
from app.db.base_class import Base 
from sqlalchemy import BigInteger

class Customer(Base):
    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(String(100), unique=True, index=True, nullable=False)
    offline_origin_uuid = Column(String(100), index=True, nullable=True, comment="POS离线开户时的原始字母UUID，用于映射匹配流水")
    
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    gender = Column(String(10))
    mobile = Column(String(20), unique=False, index=True, nullable=False)
    email = Column(String(100), nullable=True)
    birthday = Column(Date, nullable=True)
    address = Column(String(255), nullable=True)
    
    # 明确外键约束
    region_id = Column(Integer, ForeignKey("regions.id"), index=True, nullable=False)
    status = Column(Integer, default=1)
    expiry_date = Column(DateTime, nullable=True, comment="服务到期时间")
    total_recharged_days = Column(Numeric(10, 2), default=0, comment="累计充值天数")
    total_recharged_amount = Column(Numeric(10, 2), default=0, comment="累计充值金额")
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # 关键：建立与 Region 的 ORM 桥梁
    region = relationship("Region", back_populates="customers")

    # 逻辑关联：卡片 (Card)
    cards = relationship(
        "Card",
        primaryjoin="Customer.uuid == Card.customer_uuid",
        foreign_keys="[Card.customer_uuid]",
        viewonly=True
    )

    # 逻辑关联：设备 (SolarUnit)
    solar_units = relationship(
        "SolarUnit",
        primaryjoin="Customer.uuid == SolarUnit.customer_uuid",
        foreign_keys="[SolarUnit.customer_uuid]",
        viewonly=True
    )