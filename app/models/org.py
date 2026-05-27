from sqlalchemy import Column, Integer, String, ForeignKey, SmallInteger, Numeric, DateTime, Boolean
from sqlalchemy.orm import relationship, backref
from app.db.base_class import Base
from datetime import datetime

class Region(Base):
    __tablename__ = "regions"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, nullable=False)
    level = Column(Integer, default=1)  # 0:省, 1:市, 2:镇
    parent_id = Column(Integer, ForeignKey("regions.id"), nullable=True)

    # 费率配置融合 / Rate Configuration Fusion
    daily_rate = Column(Numeric(10, 2), nullable=True, default=7.0, comment="区域专属费率，若为Null则继承上级")
    last_rate_updated_at = Column(DateTime, nullable=True)
    last_rate_modified_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # 自关联：用于获取父级（城）
    parent = relationship(
        "Region", 
        remote_side=[id], 
        backref=backref("children", cascade="all, delete-orphan", order_by="Region.id")
    )
    
    # 关联业务主体
    entity = relationship("BusinessEntity", back_populates="region", uselist=False)
    
    # 关联客户：使用字符串指向 Customer 类，避免循环导入
    customers = relationship("Customer", back_populates="region")

    @property
    def full_name(self):
        """如果是镇(level=2)，自动拼接父级名字"""
        if self.level == 2 and self.parent:
            return f"{self.parent.name} - {self.name}"
        return self.name

class BusinessEntity(Base):
    __tablename__ = "business_entities"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, unique=True, nullable=False)
    address = Column(String, nullable=True)
    entity_type = Column(SmallInteger, nullable=False, default=1) # 1:子公司, 2:代理人
    region_id = Column(Integer, ForeignKey("regions.id"), unique=True, nullable=True)
    is_deleted = Column(Boolean, default=False, index=True)

    region = relationship("Region", back_populates="entity")