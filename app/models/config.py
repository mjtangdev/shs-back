from sqlalchemy import Column, Integer, Numeric, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base_class import Base

class GlobalRate(Base):
    """
    全局费率配置表
    存储费率的修改历史，每次修改都会新增一条记录。
    """
    __tablename__ = "global_rates"

    # 主键 ID
    id = Column(Integer, primary_key=True, index=True)
    
    # 每日费率，使用 Numeric 保证金额精度，10位有效数字，2位小数
    daily_rate = Column(Numeric(10, 2), nullable=False)
    
    # 修改时间，自动记录创建时间
    updated_at = Column(DateTime(timezone=True), server_default=func.now())

    # 外键：关联到 users 表的 id 字段
    last_modified_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # --- 核心关联逻辑 ---
    # 建立与 User 模型的映射关系
    # 这样在代码中可以通过 rate.modifier 直接获取 User 对象（包含 username 和 role）
    modifier = relationship("app.models.users.User", backref="rate_modifications")

    def __repr__(self):
        return f"<GlobalRate(id={self.id}, rate={self.daily_rate}, modifier_id={self.last_modified_by_id})>"