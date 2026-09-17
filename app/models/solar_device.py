from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base_class import Base

class SolarUnit(Base):
    __tablename__ = "solar_units"

    id = Column(Integer, primary_key=True, index=True)

    # 5个核心ID (主机的物理标识)
    shs_machine_id = Column(String(100), unique=True, index=True, nullable=False)
    solar_equipment_id = Column(String(100), unique=True, index=True, nullable=True)  # 关联绑定的 PV 板 SN
    radio_id = Column(String(100), unique=True, index=True, nullable=True)
    flashlight_id = Column(String(100), unique=True, index=True, nullable=True)
    led_light_id = Column(String(100), unique=True, index=True, nullable=True)

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


class SolarPVPanel(Base):
    """
    独立 PV 太阳能光伏板资产表 (与主机物理解耦)
    支持独立入库、损坏报废、替换更换，以及与 System Box 主机/客户动态关联。
    """
    __tablename__ = "solar_pv_panels"

    id = Column(Integer, primary_key=True, index=True)
    pv_sn = Column(String(100), unique=True, index=True, nullable=False) # PV 序列号

    # 状态机 (0: In Stock 在库待绑定, 1: Active 已绑定使用, 2: Blocked 冻结, 3: Damaged 损坏/报废)
    status = Column(Integer, default=0, index=True)

    # 绑定关联关系
    shs_machine_id = Column(String(100), index=True, nullable=True) # 绑定的主机 SN
    customer_uuid = Column(String(100), index=True, nullable=True)  # 绑定的客户 UUID
    customer_name = Column(String(100), nullable=True)             # 静态备份客户姓名

    # 地区信息 (静态备份)
    city = Column(String(100), index=True, nullable=True)
    town = Column(String(100), index=True, nullable=True)

    # 时间线
    production_date = Column(DateTime, nullable=True) # 生产/出厂日期
    created_at = Column(DateTime, default=datetime.now)
    bound_at = Column(DateTime, nullable=True)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)

    # 逻辑关联 Customer
    customer = relationship(
        "Customer", 
        primaryjoin="SolarPVPanel.customer_uuid == Customer.uuid", 
        foreign_keys=[customer_uuid],
        viewonly=True
    )