from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship, backref
from app.db.base_class import Base

class Region(Base):
    __tablename__ = "regions"

    # 使用 autoincrement=True 确保 ID 自动生成
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, nullable=False)
    level = Column(Integer, default=1)  # 0: 省, 1: 市, 2: 镇
    parent_id = Column(Integer, ForeignKey("regions.id"), nullable=True)

    # 自关联
    children = relationship("Region", backref=backref("parent", remote_side=[id]))
    # 一对一关联子公司
    subsidiary = relationship("Subsidiary", back_populates="region", uselist=False)

class Subsidiary(Base):
    __tablename__ = "subsidiaries"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, unique=True, nullable=False)
    address = Column(String, nullable=True)
    # 唯一约束，保证一区一司
    region_id = Column(Integer, ForeignKey("regions.id"), unique=True, nullable=False)

    region = relationship("Region", back_populates="subsidiary")