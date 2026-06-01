import random
import string
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.db.session import SessionLocal, engine
from sqlalchemy import text
from app.db.base_class import Base
from app.models.org import Region
from app.models.users import User
from app.models.customer import Customer
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog
from app.models.config import ProviderConfig
from app.models.pos import POSMachine
from app.core.auth_utils import hash_password

# 真实的菲律宾/英语姓名库
MALE_NAMES = ["Juan", "Jose", "Robert", "Michael", "David", "Richard", "Antonio", "Manuel", "Christopher", "Ricardo", "Mark", "Paul", "Joseph", "Peter", "Andrew", "Reynaldo", "Eduardo", "Rolando", "Fernando", "Leonardo"]
FEMALE_NAMES = ["Maria", "Elena", "Elizabeth", "Jennifer", "Mary", "Linda", "Susan", "Margaret", "Dorothy", "Patricia", "Anna", "Sarah", "Karen", "Lisa", "Nancy", "Imelda", "Luzviminda", "Corazon", "Teresa", "Gloria"]
LAST_NAMES = ["Garcia", "Reyes", "Cruz", "Ramos", "Mendoza", "Santos", "Hernandez", "Castillo", "Diaz", "Gonzales", "Bautista", "Villanueva", "Valenzuela", "Aquino", "Mercado", "Espiritu", "Dela Cruz", "Pascua", "Santiago", "Soriano"]

def get_random_name(gender=None):
    if not gender:
        gender = random.choice(["male", "female"])
    first = random.choice(MALE_NAMES) if gender == "male" else random.choice(FEMALE_NAMES)
    last = random.choice(LAST_NAMES)
    return first, last

def random_hex_uuid(length=8):
    return ''.join(random.choices(string.digits + "ABCDEF", k=length))

def seed():
    db = SessionLocal()
    print("🚀 Starting Fine-Grained Demo Data Seeding...")

    try:
        # 0. 重置所有数据
        print("Step 0: Cleaning and Recreating Database Tables...")
        Base.metadata.drop_all(bind=engine)
        Base.metadata.create_all(bind=engine)

        try:
            db.execute(text('DROP INDEX IF EXISTS "ix_cards_card_number" CASCADE;'))
            db.execute(text('ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_card_number_key CASCADE;'))
            db.execute(text("CREATE UNIQUE INDEX ix_cards_card_number ON cards (card_number) WHERE card_number != '';"))
        except Exception:
            db.rollback()
        db.commit()

        # 1. 初始化总公司 QUEZELCO-1
        print("Step 1: Setting up QUEZELCO-1 Headquarters...")
        root_reg = Region(name="QUEZELCO-1", level=0)
        db.add(root_reg)
        db.flush()
        
        db.add(User(
            username="admin",
            password_hash=hash_password("admin123"),
            first_name="System", last_name="Admin",
            role=1, mobile="09111111111", region_id=root_reg.id
        ))
        db.add(ProviderConfig(
            name="QUEZELCO-1 SHS", 
            tin=f"SHS{random.randint(10000000, 99999999)}",
            is_initialized=True
        ))
        db.commit()

        # 2. 建立精细化地区树并分配特定 POS SN
        print("Step 2: Creating Regions, Staff and Binding POS SNs...")
        regions_mapping = {
            "Tagkawayan": ["Del Gallego", "Guinyangan", "Calauag", "Lopez"],
            "Gumaca": ["Plaridel", "Atimonan"],
            "Alabat": ["Quezon-Quezon", "Perez"],
            "Agdangan": ["Padre Burgos", "Unisan", "Pitogo"],
            "Macalelon": ["Gen. Luna", "Catanauan", "Mulanay"],
            "San Narciso": ["Buenavista"],
            "San Francisco": ["San Andres"]
        }
        
        specific_sns = ["0310740090312319", "0310741070351937"]
        terminal_region_data = [] 
        opera_count = 0
        
        for l1_name, l2_list in regions_mapping.items():
            l1_node = Region(name=l1_name, level=1, parent_id=root_reg.id, daily_rate=7.0)
            db.add(l1_node)
            db.flush()
            
            for l2_name in l2_list:
                l2_node = Region(name=l2_name, level=2, parent_id=l1_node.id, daily_rate=7.0)
                db.add(l2_node)
                db.flush()
                
                u_name = "opera" if opera_count == 0 else f"opera{opera_count}"
                sn = specific_sns[opera_count] if opera_count < len(specific_sns) else f"031074{random.randint(1000000000, 9999999999)}"
                p_code = f"{opera_count + 10}"
                
                opera_f, opera_l = get_random_name()
                op_user = User(
                    username=u_name, password_hash=hash_password("test123"), 
                    role=2, region_id=l2_node.id, first_name=opera_f, last_name=opera_l, 
                    mobile=f"093{random.randint(10000000, 99999999)}"
                )
                db.add(op_user)
                db.flush()

                db.add(POSMachine(
                    pos_sn=sn, pos_code=p_code, status=1, region_id=l2_node.id, assigned_user_id=op_user.id
                ))
                
                terminal_region_data.append({"region_id": l2_node.id, "pos_sn": sn, "operator": u_name})
                opera_count += 1
        db.commit()

        # 3 & 4. 生成 2500 张 IC 卡 & 2500 套设备
        print("Step 3 & 4: Inventory (Cards & Units)...")
        cards = [{"card_number": "0082224" if i==0 else f"{8800000+i}", "card_uuid": "033A63AE" if i==0 else random_hex_uuid(), "status": 0} for i in range(2500)]
        db.bulk_insert_mappings(Card, cards)
        units = [{"shs_machine_id": str(222222+i), "solar_equipment_id": f"S{222222+i}", "radio_id": f"R{222222+i}", "flashlight_id": f"F{222222+i}", "led_light_id": f"L{222222+i}", "shs_status": 0, "production_date": datetime.now()} for i in range(2500)]
        db.bulk_insert_mappings(SolarUnit, units)
        db.commit()

        # 5. 生成 1500 个已绑定客户
        print("Step 5: Binding 1500 Customers...")
        all_cards = db.query(Card).limit(1500).all()
        all_units = db.query(SolarUnit).limit(1500).all()
        customer_metadata = []

        for i in range(1500):
            c_uuid = f"01{i+1:06d}"
            expiry = datetime(2024, 5, random.randint(1, 19), 12, 0) if i < 500 else datetime.now() + timedelta(days=random.randint(30, 90))
            gender = random.choice(["male", "female"])
            f, l = get_random_name(gender)
            reg = random.choice(terminal_region_data)
            
            db.add(Customer(uuid=c_uuid, first_name=f, last_name=l, gender=gender, mobile=f"09{random.randint(400000000, 999999999)}", region_id=reg["region_id"], status=1, expiry_time=expiry))
            
            card, unit = all_cards[i], all_units[i]
            card.customer_uuid, card.status = c_uuid, 1
            unit.customer_uuid, unit.shs_status, unit.bound_at = c_uuid, 1, datetime.now() - timedelta(days=30)
            customer_metadata.append({"uuid": c_uuid, "pos_sn": reg["pos_sn"], "operator": reg["operator"], "card_uuid": card.card_uuid, "shs_id": unit.shs_machine_id})
            if i % 500 == 0: db.flush()
        db.commit()

        # 6. 生成流水 (3-8 条)
        print("Step 6: Transactions (3-8 per user)...")
        tx_batch = []
        for meta in customer_metadata:
            has_today = random.random() < 0.05
            for j in range(random.randint(3, 8)):
                t_time = datetime.now() - timedelta(days=random.randint(1, 45))
                if j == 0 and has_today: t_time = datetime.now() - timedelta(minutes=random.randint(10, 300))
                tx_batch.append({
                    "transaction_id": f"TX{random_hex_uuid(12)}", "customer_uuid": meta["uuid"], "card_uuid": meta["card_uuid"], "shs_machine_id": meta["shs_id"],
                    "amount": random.choice([100, 200, 500]), "days": random.randint(7, 30), "action_type": "RECHARGE", "transaction_time": t_time, "pos_sn": meta["pos_sn"], "operator_username": meta["operator"]
                })
            if len(tx_batch) >= 2000:
                db.bulk_insert_mappings(TransactionLog, tx_batch); db.commit(); tx_batch = []
        if tx_batch: db.bulk_insert_mappings(TransactionLog, tx_batch); db.commit()

        # 7. 700 空用户
        print("Step 7: 700 Idle Customers...")
        for i in range(700):
            f, l = get_random_name()
            db.add(Customer(uuid=f"01{i+1501:06d}", first_name=f, last_name=l, gender="male", mobile=f"09{random.randint(400000000, 999999999)}", region_id=random.choice(terminal_region_data)["region_id"], status=1))
        db.commit()

        print("\n🎉 Success! Fine-grained demo environment is ready.")

    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed()
