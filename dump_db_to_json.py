import json
from datetime import datetime, date
from decimal import Decimal
from sqlalchemy.orm import Session
from app.db.session import SessionLocal

# 必须导入所有模型以确保 SQLAlchemy 关系映射正常初始化
from app.models.org import Region, BusinessEntity
from app.models.config import ProviderConfig
from app.models.users import User
from app.models.customer import Customer
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog
from app.models.pos import POSMachine, POSActionLog
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer

# 处理日期和 Decimal 的 JSON 序列化器
class DataEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime, date)):
            return obj.isoformat()
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DataEncoder, self).default(obj)

def dump():
    db = SessionLocal()
    print("📤 正在从本地数据库导出【全量资产】到 JSON...")

    try:
        data = {
            "regions": [r.__dict__ for r in db.query(Region).all()],
            "configs": [c.__dict__ for c in db.query(ProviderConfig).all()],
            "users": [u.__dict__ for u in db.query(User).all()],
            "customers": [c.__dict__ for c in db.query(Customer).all()],
            "cards": [c.__dict__ for c in db.query(Card).all()],
            "solar_units": [s.__dict__ for s in db.query(SolarUnit).all()],
            "pos_machines": [p.__dict__ for p in db.query(POSMachine).all()],
            "transactions": [t.__dict__ for t in db.query(TransactionLog).all()]
        }

        # 清理 SQLAlchemy 内部生成的 _sa_instance_state
        for key in data:
            for item in data[key]:
                item.pop('_sa_instance_state', None)

        with open("production_data.json", "w", encoding="utf-8") as f:
            json.dump(data, f, cls=DataEncoder, indent=2, ensure_ascii=False)

        print(f"\n🎉 导出成功！文件已保存为: production_data.json")
        print(f"==========================================")
        print(f"📊 资产清单核对：")
        print(f"   - 客户总数: {len(data['customers'])} 名")
        print(f"   - 财务流水: {len(data['transactions'])} 条")
        print(f"   - IC 卡库 : {len(data['cards'])} 张")
        print(f"   - 设备套件: {len(data['solar_units'])} 套")
        print(f"   - POS 终端: {len(data['pos_machines'])} 台")
        print(f"   - 组织架构: {len(data['regions'])} 个区域")
        print(f"==========================================")

    except Exception as e:
        print(f"❌ 导出失败: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    dump()
