import os
import sys
from logging.config import fileConfig

from sqlalchemy import engine_from_config, pool
from alembic import context

# --- 1. 路径修复：确保项目根目录在 PYTHONPATH 中 ---
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, BASE_DIR)

# --- 2. 导入配置与 Base ---
from app.core.config import settings
from app.db.base_class import Base 

# --- 3. 核心：导入所有模型 (基于你最新的核对) ---
try:
    from app.models.users import User
    # 区域与子公司
    from app.models.region_subsidiary import Region, Subsidiary 
    # 客户模型 (已改为单数 customer)
    from app.models.customer import Customer
    # IC卡模型
    from app.models.card import Card
    # POS 机器与日志
    from app.models.pos import POSMachine, POSActionLog
    # 费率模型 (已改为 config)
    from app.models.config import GlobalRate
    
    print("✅ 所有模型导入成功")
except ImportError as e:
    print(f"❌ 模型导入失败，请检查 app/models/ 下的文件名是否拼写正确: {e}")

# --- 4. Alembic 基础配置 ---
config = context.config
config.set_main_option("sqlalchemy.url", str(settings.SQLALCHEMY_DATABASE_URI))

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_online() -> None:
    """在线模式：真正同步到数据库"""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, 
            target_metadata=target_metadata,
            compare_type=True  # 能够检测字段类型变化（如长度增加）
        )

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    url = config.get_main_option("sqlalchemy.url")
    context.configure(url=url, target_metadata=target_metadata, literal_binds=True)
    with context.begin_transaction():
        context.run_migrations()
else:
    run_migrations_online()