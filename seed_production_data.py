import random
import string
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.db.session import SessionLocal, engine
from sqlalchemy import text
from app.db.base_class import Base
from app.models.org import Region, BusinessEntity
from app.models.users import User
from app.models.customer import Customer
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.transaction import TransactionLog
from app.models.config import ProviderConfig
from app.models.pos import POSMachine, POSActionLog
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer
from app.core.auth_utils import hash_password

# 姓名库：提供真实的菲律宾/通用英语姓名
MALE_NAMES = ["Juan", "Jose", "Robert", "Michael", "David", "Richard", "Antonio", "Manuel", "Christopher", "Ricardo", "Mark", "Paul", "Joseph", "Peter", "Andrew", "Reynaldo", "Eduardo", "Rolando", "Fernando", "Leonardo"]
FEMALE_NAMES = ["Maria", "Elena", "Elizabeth", "Jennifer", "Mary", "Linda", "Susan", "Margaret", "Dorothy", "Patricia", "Anna", "Sarah", "Karen", "Lisa", "Nancy", "Imelda", "Luzviminda", "Corazon", "Teresa", "Gloria"]
LAST_NAMES = ["Garcia", "Reyes", "Cruz", "Ramos", "Mendoza", "Santos", "Hernandez", "Castillo", "Diaz", "Gonzales", "Bautista", "Villanueva", "Valenzuela", "Aquino", "Mercado", "Espiritu", "Dela Cruz", "Pascua", "Santiago", "Soriano"]

def get_random_name(gender=None):
    """根据性别随机生成真实姓名"""
    if not gender:
        gender = random.choice(["male", "female"])
    
    first = random.choice(MALE_NAMES) if gender == "male" else random.choice(FEMALE_NAMES)
    last = random.choice(LAST_NAMES)
    return first, last

def random_hex_uuid(length=8):
    """生成 8 位随机 16 进制风格字符串"""
    return ''.join(random.choices(string.digits + "ABCDEF", k=length))

def seed_data():
    db = SessionLocal()
    print("🚀 Starting customized production-scale data seeding...")

    try:
        # 0. 彻底重置表结构，确保 schema 与模型同步
        print("Step 0: Dropping and recreating all tables (to sync schema)...")
        Base.metadata.drop_all(bind=engine)
        Base.metadata.create_all(bind=engine)
        
        try:
            db.execute(text('DROP INDEX IF EXISTS "ix_cards_card_number" CASCADE;'))
            db.execute(text('ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_card_number_key CASCADE;'))
            db.execute(text("CREATE UNIQUE INDEX ix_cards_card_number ON cards (card_number) WHERE card_number != '';"))
        except Exception:
            db.rollback()
        db.commit()

        # 1. 核心账号与总公司
        print("Step 1: Creating Global Admin...")
        root_reg = Region(name="QUEZELCO-1", level=0)
        db.add(root_reg)
        db.flush()
        
        db.add(User(
            username="admin",
            password_hash=hash_password("admin123"),
            first_name="System", last_name="Admin",
            role=1, mobile="09111111111", region_id=root_reg.id, is_active=True
        ))
        db.add(ProviderConfig(
            name="SHS Main Provider", 
            tin=f"SHS{random.randint(10000000, 99999999)}",
            is_initialized=True
        ))
        db.commit()

        # 2. 创建 20 个区域及特定的 POS
        print("Step 2: Creating Regions and POS machines (Specific Mapping)...")
        terminal_region_ids = []
        opera_count = 0
        
        # 特定 SN 列表
        specific_sns = ["0310740090312319", "0310741070351937"]
        
        # 地区映射关系
        regions_mapping = {
            "Tagkawayan": ["Del Gallego", "Guinyangan", "Calauag", "Lopez"],
            "Gumaca": ["Plaridel", "Atimonan"],
            "Alabat": ["Quezon-Quezon", "Perez"],
            "Agdangan": ["Padre Burgos", "Unisan", "Pitogo"],
            "Macalelon": ["Gen. Luna", "Catanauan", "Mulanay"],
            "San Narciso": ["Buenavista"],
            "San Francisco": ["San Andres"]
        }
        
        for brgy_name, puroks in regions_mapping.items():
            brgy = Region(name=brgy_name, level=1, parent_id=root_reg.id, daily_rate=7.0)
            db.add(brgy)
            db.flush()
            
            for purok_name in puroks:
                purok = Region(name=purok_name, level=2, parent_id=brgy.id, daily_rate=7.0)
                db.add(purok)
                db.flush()
                p_id = purok.id
                terminal_region_ids.append(p_id)
                
                opera_username = "opera" if opera_count == 0 else f"opera{opera_count}"
                
                # 分配 SN
                if opera_count < len(specific_sns):
                    current_sn = specific_sns[opera_count]
                else:
                    current_sn = f"031074{random.randint(1000000000, 9999999999)}"
                
                pos_code = f"{opera_count + 10}"
                
                # 创建人员
                admin_f, admin_l = get_random_name()
                opera_f, opera_l = get_random_name()
                
                db.add(User(username=f"admin_{opera_count}", password_hash=hash_password("test123"), role=1, region_id=p_id, is_active=True, first_name=admin_f, last_name=admin_l, mobile=f"092{random.randint(10000000, 99999999)}"))
                new_opera = User(username=opera_username, password_hash=hash_password("test123"), role=2, region_id=p_id, is_active=True, first_name=opera_f, last_name=opera_l, mobile=f"093{random.randint(10000000, 99999999)}")
                db.add(new_opera)
                db.flush()

                # 创建 POS 并绑定人员
                db.add(POSMachine(pos_sn=current_sn, pos_code=pos_code, status=1, region_id=p_id, assigned_user_id=new_opera.id))
                opera_count += 1
        db.commit()

        # 3. 2500 卡片 (含特定第一张)
        print("Step 3: Generating 2500 IC Cards...")
        cards_data = []
        for i in range(2500):
            if i == 0:
                u, n = "033A63AE", "0082224"
            else:
                u, n = random_hex_uuid(), f"{8800000 + i}"
            cards_data.append({"card_number": n, "card_uuid": u, "status": 0, "created_at": datetime.now()})
        db.bulk_insert_mappings(Card, cards_data)
        db.commit()

        # 4. 2500 设备 (从 222222 开始)
        print("Step 4: Generating 2500 Solar Units...")
        units_data = []
        for i in range(2500):
            shs_id = str(222222 + i)
            units_data.append({
                "shs_machine_id": shs_id, "solar_equipment_id": f"SOL-{shs_id}",
                "radio_id": f"RAD-{shs_id}", "flashlight_id": f"FLA-{shs_id}", "led_light_id": f"LED-{shs_id}",
                "shs_status": 0, "production_date": datetime.now(), "created_at": datetime.now()
            })
        db.bulk_insert_mappings(SolarUnit, units_data)
        db.commit()

        # 5. 生成 1500 个已绑定客户
        print("Step 5: Binding 1500 customers...")
        all_cards = db.query(Card).limit(1500).all()
        all_units = db.query(SolarUnit).limit(1500).all()
        customer_assets = {}

        for i in range(1500):
            c_uuid = f"01{i+1:06d}"
            gender = random.choice(["male", "female"])
            f_name, l_name = get_random_name(gender)

            # 500 个过期 (5.1 ~ 5.19)
            if i < 500:
                expiry = datetime(2024, 5, random.randint(1, 19), random.randint(0, 23))
            else:
                expiry = datetime.now() + timedelta(days=random.randint(30, 90))

            new_cust = Customer(
                uuid=c_uuid, first_name=f_name, last_name=l_name, gender=gender,
                mobile=f"09{random.randint(400000000, 999999999)}", region_id=random.choice(terminal_region_ids), status=1, expiry_time=expiry
            )
            db.add(new_cust)
            
            card, unit = all_cards[i], all_units[i]
            card.customer_uuid, card.status = c_uuid, 1
            unit.customer_uuid, unit.shs_status, unit.bound_at = c_uuid, 1, datetime.now() - timedelta(days=30)
            customer_assets[c_uuid] = {"card_uuid": card.card_uuid, "shs_id": unit.shs_machine_id}
            if i % 500 == 0: db.flush()
        db.commit()

        # 6. 生成流水 (每人 3-8 条)
        print("Step 6: Generating transactions (3-8 per user)...")
        tx_batch = []
        for c_uuid, assets in customer_assets.items():
            has_today = random.random() < 0.05
            num_tx = random.randint(3, 8)
            for j in range(num_tx):
                t_time = datetime.now() - timedelta(days=random.randint(1, 45))
                if j == 0 and has_today: t_time = datetime.now() - timedelta(minutes=random.randint(10, 300))
                
                tx_batch.append({
                    "transaction_id": f"TX{random_hex_uuid(12)}", "customer_uuid": c_uuid, "card_uuid": assets["card_uuid"],
                    "shs_machine_id": assets["shs_id"], "amount": random.choice([100, 200, 500]), "days": random.randint(7, 30),
                    "action_type": "RECHARGE", "transaction_time": t_time, "pos_sn": "0310740090312319", "operator_username": "opera", "created_at": datetime.now()
                })
            if len(tx_batch) >= 2000:
                db.bulk_insert_mappings(TransactionLog, tx_batch)
                db.commit()
                tx_batch = []
        if tx_batch:
            db.bulk_insert_mappings(TransactionLog, tx_batch)
            db.commit()

        # 7. 生成 700 名空用户
        print("Step 7: Generating 700 idle customers...")
        for i in range(700):
            gender = random.choice(["male", "female"])
            f_name, l_name = get_random_name(gender)
            db.add(Customer(
                uuid=f"01{i+1501:06d}", first_name=f_name, last_name=l_name,
                gender=gender, mobile=f"09{random.randint(400000000, 999999999)}",
                region_id=random.choice(terminal_region_ids), status=1
            ))
        db.commit()

        print("\n🎉 Seeding Completed Successfully!")
        print(f"Total: 2200 Customers (1500 Bound, 700 Idle)")
        print(f"Inventory: 2500 Cards, 2500 Units (starting from 222222)")
        print(f"Staff: 'opera' has SN 0310740090312319")

    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
