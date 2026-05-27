import random
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.db.session import SessionLocal, engine
from app.models.customer import Customer
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.org import Region
from app.models.config import ProviderConfig
from app.models.pos import POSMachine, POSActionLog
from app.models.users import User
from snowflake import SnowflakeGenerator

snowflake_gen = SnowflakeGenerator(1)
used_hw_ids = set()

def get_unique_hw_id(digits=4):
    while True:
        lower = 10 ** (digits - 1)
        upper = (10 ** digits) - 1
        if len(used_hw_ids) >= 8500:
             digits = 5; lower = 10000; upper = 99999
        new_id = str(random.randint(lower, upper))
        if new_id not in used_hw_ids:
            used_hw_ids.add(new_id); return new_id

def seed_final_data():
    db: Session = SessionLocal()
    print("🚀 Seeding Precise Dashboard Data (Unbound Mode)...")
    
    try:
        # 预扫描
        for row in db.query(Card.card_uuid).all(): used_hw_ids.add(row[0])
        for row in db.query(Card.card_number).all(): used_hw_ids.add(row[0])
        for row in db.query(SolarUnit.shs_machine_id).all(): used_hw_ids.add(row[0])
        
        puroks = db.query(Region).filter(Region.level == 2).all()
        provider = db.query(ProviderConfig).first()
        provider_name = provider.name if provider else "SHS Philippines Branch"
        
        first_names = ["James", "Robert", "John", "Michael", "David", "William", "Richard", "Joseph", "Thomas", "Christopher", "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth"]
        last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Dela Cruz", "Santos", "Reyes"]

        # 1. 生成 1240 名客户 (匹配 dashboard 需求)
        print("👥 Creating 1,240 Customers...")
        for i in range(1240):
            f_name, l_name = random.choice(first_names), random.choice(last_names)
            db.add(Customer(
                uuid=str(next(snowflake_gen)),
                first_name=f_name, last_name=l_name,
                gender=random.choice(["male", "female"]),
                mobile=f"09{random.randint(100000000, 999999999)}",
                region_id=random.choice(puroks).id,
                status=1,
                electric_company=provider_name,
                beneficiary_count=random.randint(1, 6),
                representative_name=f"{f_name} {l_name}",
                created_at=datetime.now() - timedelta(days=random.randint(0, 60))
            ))
            if i % 300 == 0: db.flush()

        # 2. 生成 1000 个库存资源
        print("📦 Creating 1,000 In-Stock Cards & SHS Units...")
        for i in range(1000):
            db.add(Card(card_number=get_unique_hw_id(8), card_uuid=get_unique_hw_id(6).upper(), status=0))
            db.add(SolarUnit(
                shs_machine_id=get_unique_hw_id(6), solar_equipment_id=get_unique_hw_id(6),
                radio_id=get_unique_hw_id(6), flashlight_id=get_unique_hw_id(6),
                led_light_id=get_unique_hw_id(6), production_date=datetime.now(),
                shs_status=0
            ))
            if i % 300 == 0: db.flush()

        db.commit()
        print(f"\n🎉 Successfully seeded 1240 Customers & 1000 Inventory Sets!")

    except Exception as e:
        print(f"❌ Error: {e}"); db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_final_data()
