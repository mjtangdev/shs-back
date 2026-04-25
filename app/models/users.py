from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey
from datetime import datetime, timezone
from app.db.base_class import Base # 假设你已定义 Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(Integer, default=2)  # 1: Admin, 2: Operator
    is_active = Column(Boolean, default=True)
    
    # 个人信息
    first_name = Column(String, nullable=False)
    middle_name = Column(String, nullable=True)
    last_name = Column(String, nullable=False)
    position = Column(String, nullable=True)
    
    # 联系方式
    mobile = Column(String, nullable=False)
    landline = Column(String, nullable=True)
    email = Column(String, unique=True, nullable=True)
    
    # 紧急联系
    ice_name = Column(String, nullable=True)
    ice_phone = Column(String, nullable=True)

   # 地理信息 (Geography) - 设为可选
    province = Column(String, default="Pangasinan")
    city_id = Column(Integer, nullable=True)  # 城市 ID
    town_id = Column(Integer, nullable=True)  # 镇/社区 ID
    address = Column(Text, nullable=True)      # 详细街道地址
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))