from sqlalchemy import Column, String, Integer, DateTime, Boolean, Text
from datetime import datetime
from app.db.base_class import Base

class POSMachine(Base):
    """
    POS 终端主表
    """
    __tablename__ = "pos_machines"

    # 主键使用 16 位 SN 码
    pos_sn = Column(String(16), primary_key=True, index=True)
    
    # 状态字段
    status = Column(Integer, default=0)         # 0: In Stock (在库), 1: Assigned (已分配), 2: Damaged (损坏)
    lock_status = Column(Integer, default=0)    # 0: Normal (正常), 1: Admin Locked (管理员锁), 2: Finance Locked (财务锁)
    is_deleted = Column(Boolean, default=False) # 软删除标记：True 表示用户已删除，但在日志中保留

    # 归属信息
    region_id = Column(String(50), nullable=True)     # 所属区域 ID
    branch_office = Column(String(100), nullable=True) # 所属分公司/网点名称
    
    # 审计信息
    created_at = Column(DateTime, default=datetime.utcnow)
    created_by = Column(String(50), nullable=True)

class POSActionLog(Base):
    """
    POS 操作审计日志表
    记录所有锁定、解锁、入库、删除等关键操作，用于后续追溯。
    """
    __tablename__ = "pos_action_logs"

    id = Column(Integer, primary_key=True, index=True)
    # 与 POSMachine.pos_sn 逻辑关联，即便机器被软删除，这里依然保留记录
    pos_sn = Column(String(16), index=True)      
    
    action_type = Column(String(50))             # 操作类型: LOCK, UNLOCK, IMPORT, DELETE, RE-IMPORT
    operator = Column(String(50))                # 执行操作的 username
    role = Column(String(20), nullable=True)     # 操作时的用户角色 (Admin/Finance/User)
    remark = Column(Text, nullable=True)         # 操作备注（如：因逾期 30 天锁定）
    timestamp = Column(DateTime, default=datetime.utcnow)