import os
import json
import logging
from datetime import datetime, date
from decimal import Decimal
from app.db.session import SessionLocal
from app.models.pos import POSMachine, POSActionLog
from app.models.org import Region, BusinessEntity
from app.models.config import ProviderConfig
from app.models.users import User
from app.models.customer import Customer
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog

logger = logging.getLogger(__name__)

class DataEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime, date)):
            return obj.isoformat()
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DataEncoder, self).default(obj)

def perform_db_backup():
    """全量导出业务数据到带时间戳的 JSON 文件，并只保留最近 6 份"""
    logger.info("⏰ Starting automatic JSON data export...")
    db = SessionLocal()
    
    # 确保备份目录存在
    backup_dir = "backups"
    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)

    try:
        data = {
            "regions": [r.__dict__ for r in db.query(Region).all()],
            "business_entities": [b.__dict__ for b in db.query(BusinessEntity).all()],
            "configs": [c.__dict__ for c in db.query(ProviderConfig).all()],
            "users": [u.__dict__ for u in db.query(User).all()],
            "customers": [c.__dict__ for c in db.query(Customer).all()],
            "cards": [c.__dict__ for c in db.query(Card).all()],
            "solar_units": [s.__dict__ for s in db.query(SolarUnit).all()],
            "pos_machines": [p.__dict__ for p in db.query(POSMachine).all()],
            "pos_action_logs": [l.__dict__ for l in db.query(POSActionLog).all()],
            "transactions": [t.__dict__ for t in db.query(TransactionLog).all()]
        }

        # 清理 SQLAlchemy 内部状态
        for key in data:
            for item in data[key]:
                item.pop('_sa_instance_state', None)

        # 生成带时间戳的文件名 (精确到分钟，去除秒)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M")
        file_name = f"production_data_{timestamp}.json"
        file_path = os.path.join(backup_dir, file_name)

        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, cls=DataEncoder, indent=2, ensure_ascii=False)

        # 始终同步一份最新副本到根目录，方便现有脚本读取
        with open("production_data.json", "w", encoding="utf-8") as f:
            json.dump(data, f, cls=DataEncoder, indent=2, ensure_ascii=False)

        logger.info(f"✅ Auto-export completed. File saved: {file_path}")

        # --- [ 自动清理逻辑：仅保留最近 6 份 ] ---
        all_backups = sorted(
            [os.path.join(backup_dir, f) for f in os.listdir(backup_dir) if f.startswith("production_data_") and f.endswith(".json")],
            key=os.path.getmtime,
            reverse=True
        )

        if len(all_backups) > 6:
            for old_file in all_backups[6:]:
                os.remove(old_file)
                logger.info(f"🗑️ Deleted old backup: {old_file}")

    except Exception as e:
        logger.error(f"❌ Auto-export failed: {e}")
    finally:
        db.close()
