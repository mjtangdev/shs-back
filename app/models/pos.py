from sqlalchemy import Column, String, Integer, DateTime, Boolean, Text, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base_class import Base

class POSMachine(Base):
    """
    POS 终端主表
    """
    __tablename__ = "pos_machines"

    # 新增自增 ID 作为主键
    id = Column(Integer, primary_key=True, index=True)
    # SN 码降级为唯一索引，但不作为主键
    pos_sn = Column(String(16), unique=True, index=True, nullable=False)
    
    # 状态字段
    status = Column(Integer, default=0)         # 0: In Stock (在库), 1: Assigned (已分配), 2: Damaged (损坏)
    lock_status = Column(Integer, default=0)    # 0: Normal (正常), 1: Admin Locked (管理员锁), 2: Finance Locked (财务锁)
    is_deleted = Column(Boolean, default=False) # 软删除标记：True 表示用户已删除，但在日志中保留

    # 归属信息
    region_id = Column(Integer, nullable=True)     # 所属区域 ID
    branch_office = Column(String(100), nullable=True) # 所属分公司/网点名称
    
    # 对账管控 (Reconciliation Control)
    reconciliation_deadline = Column(DateTime, nullable=True) # 对账截止时间
    last_reconciliation_at = Column(DateTime, nullable=True)  # 上次对账成功时间
    
    # 锁定审计快照 (用于列表页直观显示)
    last_lock_reason = Column(String(255), nullable=True)
    last_action_by = Column(String(50), nullable=True)

    # 强绑定用户信息 (Strong Binding)
    assigned_user_id = Column(Integer, ForeignKey("users.id"), nullable=True) # 绑定的用户 ID
    assigned_user = relationship("User", foreign_keys=[assigned_user_id], back_populates="pos_machine")

    # POS 运行状态监控
    last_login_at = Column(DateTime, nullable=True)
    last_ip = Column(String(50), nullable=True)
    app_version = Column(String(20), nullable=True)
    version_type = Column(String(20), nullable=True) # 新增：Standard 或 Premium
    mac_address = Column(String(30), nullable=True) # 新增 MAC 地址字段
    latitude = Column(String(20), nullable=True)    # 纬度
    longitude = Column(String(20), nullable=True)   # 经度

    # 审计信息
    created_at = Column(DateTime, default=datetime.now)
    created_by = Column(String(50), nullable=True)

class POSActionLog(Base):
    """
    POS 操作审计日志表
    """
    __tablename__ = "pos_action_logs"

    id = Column(Integer, primary_key=True, index=True)
    pos_sn = Column(String(16), index=True)      
    
    action_type = Column(String(50))             # 操作类型: LOCK, UNLOCK, IMPORT, DELETE, RE-IMPORT
    operator = Column(String(50))                # 执行操作的 username
    role = Column(String(20), nullable=True)     # 操作时的用户角色 (Admin/Finance/User)
    remark = Column(Text, nullable=True)         # 操作备注
    timestamp = Column(DateTime, default=datetime.now)
