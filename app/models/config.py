from sqlalchemy import Column, Integer, String, Text, Numeric, DateTime, Boolean
from sqlalchemy.orm import relationship
from app.db.base_class import Base  # 假设 Base 在此路径 / Assuming Base is at this path
from datetime import datetime

# 导入 User 模型，用于关联 / Import User model for relationship
from app.models.users import User  # 假设 User 模型在此路径 / Assuming User model is at this path

class ProviderConfig(Base):
    """总公司/供应商配置模型 / Provider/Company Configuration Model"""
    __tablename__ = "provider_configs"

    id = Column(Integer, primary_key=True, index=True)
    
    # 新增字段 / New Fields
    name = Column(String(255), nullable=False, index=True, comment="Provider/Company Name") # 必填 / Required
    tin = Column(String(50), nullable=False, unique=True, index=True, comment="Tax Identification Number (TIN)") # 必填 / Required
    logo_url = Column(String(255), nullable=True, comment="Storage path or URL of company logo (PNG)")
    phone = Column(String(50), nullable=True, comment="Company contact phone number")
    email = Column(String(100), nullable=True, comment="Company email address")
    address = Column(Text, nullable=True, comment="Company physical address")

    # 标记该配置是否已被用户手动更新过
    is_initialized = Column(Boolean, default=False, comment="Whether the config has been updated by user")

    # 记录创建和更新时间 / Creation and update timestamps
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)