import uuid
from sqlalchemy import Column, Integer, String, Date, DateTime, func, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base_class import Base 
from sqlalchemy import BigInteger

class Customer(Base):
    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(String(100), unique=True, index=True, nullable=False)
    
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
    created_at = Column(DateTime, server_default=func.now())

    # 关键：建立与 Region 的 ORM 桥梁
    region = relationship("Region", back_populates="customers")