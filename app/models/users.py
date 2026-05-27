from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.db.base_class import Base # 假设你已定义 Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(Integer, default=2)  # 0:SuperAdmin, 1:Admin, 2:Operator, 3:Finance, 4:Management
    is_active = Column(Boolean, default=True)
    is_deleted = Column(Boolean, default=False, index=True)
    
    # 个人信息
    first_name = Column(String, nullable=False)
    middle_name = Column(String, nullable=True)
    last_name = Column(String, nullable=False)
    
    # 联系方式
    mobile = Column(String, nullable=False)
    landline = Column(String, nullable=True)
    email = Column(String, unique=True, nullable=True)
    
    # 紧急联系
    ice_name = Column(String, nullable=True)
    ice_phone = Column(String, nullable=True)

   # 地理信息 (Geography) - 设为可选
    province = Column(String, default="Pangasinan")
    region_id = Column(Integer, nullable=True, index=True)  # 所属区域 ID
    address = Column(Text, nullable=True)      # 详细街道地址
    
    created_at = Column(DateTime, default=datetime.now)

    # 关联 POS 机 (一对一)
    pos_machine = relationship("POSMachine", back_populates="assigned_user", uselist=False)
