from sqlalchemy.orm import Session
from app.db.session import SessionLocal
# 核心修复：导入所有模型以注册映射关系
from app.models.users import User
from app.models.pos import POSMachine
from app.models.customer import Customer
from app.models.card import Card
from app.models.org import Region
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog
from app.core.auth_utils import hash_password
from datetime import datetime

def seed():
    db = SessionLocal()
    print("🧪 正在生成 MJ 测试专用数据集...")

    try:
        # 1. 寻找目标地区 (第一个 B 的第一个 P)
        # Level 1 是 Municipality, Level 2 是 Barangay/Purok
        target_region = db.query(Region).filter(Region.level == 2).order_by(Region.id.asc()).first()
        if not target_region:
            print("❌ 错误：未找到任何 Level 2 区域，请先运行迁移脚本。")
            return
        
        rid = target_region.id
        print(f"📍 目标地区已锁定: {target_region.name} (ID: {rid})")

        # 2. 清理旧测试数据 (防止冲突)
        db.query(User).filter(User.username == "opera").delete()
        db.query(Customer).filter(Customer.first_name == "mj", Customer.last_name == "tang").delete()
        db.query(Card).filter(Card.card_uuid == "033A63AE").delete()
        db.commit()

        # 3. 创建操作员 opera
        opera = User(
            username="opera",
            password_hash=hash_password("test123"),
            role=2,
            first_name="Test",
            last_name="Operator",
            mobile="09990000001",
            region_id=rid,
            is_active=True
        )
        db.add(opera)
        print("👤 操作员 'opera' (pwd: test123) 创建成功。")

        # 4. 创建客户 mj tang
        # 按照新逻辑生成 ID: 地区ID(2位) + 000099 (测试专用后缀)
        test_uuid = f"{rid:02d}000099"
        mj = Customer(
            uuid=test_uuid,
            first_name="mj",
            last_name="tang",
            gender="male",
            mobile="09887776665",
            region_id=rid,
            status=1,
            created_at=datetime.now()
        )
        db.add(mj)
        print(f"🤝 客户 'mj tang' (ID: {test_uuid}) 创建成功。")

        # 5. 创建 IC 卡 (在库状态，不绑定)
        card = Card(
            card_uuid="033A63AE",
            card_number="008222224",
            status=0, # 👈 修改为：In Stock
            customer_uuid=None, # 👈 修改为：不绑定
            bound_at=None
        )
        db.add(card)
        print(f"💳 测试卡 '033A63AE' (008222224) 已存入库存。")

        db.commit()
        print("\n✅ MJ 测试数据准备就绪！您现在可以用 opera 账号登录 POS 进行测试了。")

    except Exception as e:
        db.rollback()
        print(f"❌ 生成失败: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed()
