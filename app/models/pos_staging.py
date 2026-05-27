from sqlalchemy import Column, Integer, String, DateTime, Numeric, Text, Boolean, ForeignKey
from datetime import datetime
from app.db.base_class import Base

class POSStagingTransaction(Base):
    """
    POS 离线交易流水暂存表
    用于快速接收 POS 上传的交易数据，后续由后台任务异步处理。
    """
    __tablename__ = "pos_staging_transactions"

    id = Column(Integer, primary_key=True, index=True)
    # 幂等键：POS 端生成的唯一交易 ID，用于后台处理时的幂等性校验
    transaction_id = Column(String(100), unique=True, index=True, nullable=False)
    
    customer_uuid = Column(String(100), index=True, nullable=False)
    card_uuid = Column(String(100), index=True, nullable=False)
    shs_machine_id = Column(String(100), nullable=True, comment="离线操作关联的主机ID")
    days = Column(Numeric(10, 2), nullable=False, default=0)
    amount = Column(Numeric(10, 2), nullable=False)
    transaction_time = Column(DateTime, nullable=False)
    action_type = Column(String(50)) # RECHARGE, COLLECT, etc.
    
    pos_sn = Column(String(16), index=True)
    operator_username = Column(String(50), index=True)
    
    upload_time = Column(DateTime, default=datetime.now) # 数据上传到后台的时间
    
    # 数据库层面强制金额大于0
    __table_args__ = ({"check_constraint": "amount > 0"}),
    processed_status = Column(Integer, default=0) # 0: Pending, 1: Processed, 2: Failed
    processing_error = Column(Text, nullable=True) # 记录处理失败的错误信息

class POSStagingCustomer(Base):
    """
    POS 离线新建客户暂存表
    用于快速接收 POS 上传的新客户数据，后续由后台任务异步处理。
    """
    __tablename__ = "pos_staging_customers"

    id = Column(Integer, primary_key=True, index=True)
    # 幂等键：POS 端生成的客户 UUID，用于后台处理时的幂等性校验
    customer_uuid = Column(String(100), unique=True, index=True, nullable=False)
    
    # 客户基本信息 (镜像 Customer 模型，但这里只存原始上传数据)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    
    # 离线开户时同时绑定的资产 ID
    card_uuid = Column(String(100), nullable=True)
    shs_machine_id = Column(String(100), nullable=True)

    gender = Column(String(10))
    mobile = Column(String(20), index=True, nullable=False)
    email = Column(String(100), nullable=True)
    birthday = Column(DateTime, nullable=True) # 注意：这里用 DateTime 兼容 Pydantic 的 datetime
    address = Column(String(255), nullable=True)
    region_id = Column(Integer, ForeignKey("regions.id"), index=True, nullable=False)
    status = Column(Integer, default=1) # 客户状态，默认为活跃

    beneficiary_count = Column(Integer, default=0)
    representative_name = Column(String(100), nullable=True)
    rep_relationship = Column(String(50), default="-")

    pos_sn = Column(String(16), index=True)
    operator_username = Column(String(50), index=True)

    upload_time = Column(DateTime, default=datetime.now)
    processed_status = Column(Integer, default=0) # 0: Pending, 1: Processed, 2: Failed
    processing_error = Column(Text, nullable=True)