from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base_class import Base

class SolarUnit(Base):
    __tablename__ = "solar_units"

    id = Column(Integer, primary_key=True, index=True)

    # 5个核心ID (物理标识)
    shs_machine_id = Column(String(100), unique=True, index=True, nullable=False)
    solar_equipment_id = Column(String(100), unique=True, index=True, nullable=False)
    radio_id = Column(String(100), unique=True, index=True, nullable=False)
    flashlight_id = Column(String(100), unique=True, index=True, nullable=False)
    led_light_id = Column(String(100), unique=True, index=True, nullable=False)

    # 状态机 (0: In Stock, 1: Active)
    shs_status = Column(Integer, default=0, index=True)
    equipment_status = Column(Integer, default=0, index=True)
    radio_status = Column(Integer, default=0, index=True)
    flashlight_status = Column(Integer, default=0, index=True)
    led_status = Column(Integer, default=0, index=True)

    # 业务字段
    customer_uuid = Column(String(100), index=True, nullable=True)
    customer_name = Column(String(100), nullable=True)

    # 逻辑关联 Customer
    customer = relationship(
        "Customer", 
        primaryjoin="SolarUnit.customer_uuid == Customer.uuid", 
        foreign_keys=[customer_uuid],
        viewonly=True
    )

    # 地区信息 (静态备份)
    city = Column(String(100), index=True, nullable=True)
    town = Column(String(100), index=True, nullable=True)

    # 时间线
    production_date = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.now)
    bound_at = Column(DateTime, nullable=True)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)