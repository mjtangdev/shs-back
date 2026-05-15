from sqlalchemy import Column, Integer, String, DateTime
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

    # 业务字段 (纯数据存储，不写 relationship)
    # 修改为 String(100) 以匹配 Customer 模型，防止 JS 精度丢失
    customer_uuid = Column(String(100), index=True, nullable=True)
    customer_name = Column(String(100), nullable=True)

    # 地区信息
    city = Column(String(100), index=True, nullable=True)
    town = Column(String(100), index=True, nullable=True)

    # 时间线
    production_date = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.now)
    bound_at = Column(DateTime, nullable=True)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)