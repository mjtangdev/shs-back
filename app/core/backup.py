import os
import json
import logging
from datetime import datetime, date
from decimal import Decimal
from app.db.session import SessionLocal
from app.models.org import Region
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
    """全量导出业务数据到 production_data.json (自动刷新)"""
    logger.info("⏰ Starting automatic JSON data export...")
    db = SessionLocal()
    try:
        data = {
            "regions": [r.__dict__ for r in db.query(Region).all()],
            "configs": [c.__dict__ for c in db.query(ProviderConfig).all()],
            "users": [u.__dict__ for u in db.query(User).all()],
            "customers": [c.__dict__ for c in db.query(Customer).all()],
            "cards": [c.__dict__ for c in db.query(Card).all()],
            "solar_units": [s.__dict__ for s in db.query(SolarUnit).all()],
            "transactions": [t.__dict__ for t in db.query(TransactionLog).all()]
        }

        # 清理 SQLAlchemy 内部状态
        for key in data:
            for item in data[key]:
                item.pop('_sa_instance_state', None)

        # 确保保存到项目根目录
        file_path = "production_data.json"
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, cls=DataEncoder, indent=2, ensure_ascii=False)

        logger.info(f"✅ Auto-export completed. File refreshed: {file_path}")
    except Exception as e:
        logger.error(f"❌ Auto-export failed: {e}")
    finally:
        db.close()
