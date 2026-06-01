import re
import os
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.customer import Customer
from app.models.card import Card
from app.models.org import Region
from app.models.transaction import TransactionLog

# 设置导出文件夹路径
SQL_FOLDER = "/Users/michael/dev/shs/mysqlexport"

def parse_sql_values(file_path):
    """从 SQL INSERT 语句中提取数据的正则表达式解析器"""
    if not os.path.exists(file_path):
        print(f"⚠️ 文件不存在: {file_path}")
        return []
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 匹配 INSERT INTO ... VALUES (...), (...); 中的所有括号内容
    values_pattern = re.compile(r"\((.*?)\)(?=[,;])", re.DOTALL)
    rows = values_pattern.findall(content)
    
    parsed_rows = []
    for row in rows:
        # 处理逗号分割但保留引号内的内容
        items = re.findall(r"(?:'((?:''|[^'])*)'|([^,]+))", row)
        cleaned_items = [i[0].replace("''", "'") if i[0] else (i[1].strip() if i[1] else "NULL") for i in items]
        parsed_rows.append(cleaned_items)
    return parsed_rows

def migrate():
    db = SessionLocal()
    print("🚀 Starting Data Migration from Legacy SQL...")

    try:
        # 1. 建立地区缓存 {(Level1_Name, Level2_Name): ID}
        print("Step 1: Mapping Regions...")
        regions = db.query(Region).filter(Region.level == 2).all()
        region_map = {}
        for r in regions:
            l1_name = r.parent.name if r.parent else "Unknown"
            region_map[(l1_name.lower(), r.name.lower())] = r.id

        # 2. 解析客户数据
        print("Step 2: Parsing Clients...")
        clients_raw = parse_sql_values(os.path.join(SQL_FOLDER, "shsv1_ic_clients.sql"))
        
        # 建立 UUID 映射，方便后续关联
        client_data_map = {} # {client_id_8_digit: customer_obj}
        
        for row in clients_raw:
            try:
                # 根据 SQL 结构提取字段 (注意：索引位需根据 .sql 文件实际列顺序调整)
                c_id = row[2]  # client_id
                f_name = row[3] # first_name
                l_name = row[4] # last_name
                gender_num = row[5] # gender (1=female, 0/2=male)
                mobile = row[7] # mobile
                birthday = row[18] # birthday
                town = row[12]  # Level 1
                brgy = row[11]  # Level 2
                
                # 转换性别
                gender = "female" if gender_num == '1' else "male"
                
                # 匹配地区 ID
                r_id = region_map.get((town.lower(), brgy.lower()), None)
                if not r_id:
                    # 如果匹配不到具体小区，尝试只匹配城镇
                    l1_match = [rid for (t, b), rid in region_map.items() if t == town.lower()]
                    r_id = l1_match[0] if l1_match else regions[0].id # 兜底

                new_cust = Customer(
                    uuid=c_id,
                    first_name=f_name,
                    last_name=l_name,
                    gender=gender,
                    mobile=mobile if mobile != "NULL" else f"09{c_id}",
                    birthday=datetime.strptime(birthday, '%Y-%m-%d').date() if birthday != "NULL" else None,
                    region_id=r_id,
                    status=1,
                    created_at=datetime.now()
                )
                db.add(new_cust)
                client_data_map[c_id] = new_cust
            except Exception as e:
                continue
        
        db.flush()
        print(f"✅ Imported {len(client_data_map)} customers.")

        # 3. 解析并绑定卡片
        print("Step 3: Parsing and Binding Cards...")
        cards_raw = parse_sql_values(os.path.join(SQL_FOLDER, "shsv1_ic_clients_card.sql"))
        
        card_count = 0
        for row in cards_raw:
            try:
                c_id = row[1]      # client_id
                card_uuid = row[4] # card_id (UUID)
                card_num = row[15] # logic_card_id (卡号)
                rem_days = int(row[6]) if row[6] != "NULL" else 0
                last_tx_str = row[9] # last_recharge_time
                
                if c_id in client_data_map:
                    # 创建卡片记录
                    new_card = Card(
                        card_uuid=card_uuid.upper(),
                        card_number=card_num if card_num != "NULL" else card_uuid,
                        customer_uuid=c_id,
                        status=1,
                        bound_at=datetime.now()
                    )
                    db.add(new_card)
                    
                    # 计算客户到期时间
                    if last_tx_str != "NULL":
                        last_tx = datetime.strptime(last_tx_str, '%Y-%m-%d %H:%M:%S')
                        client_data_map[c_id].expiry_time = last_tx + timedelta(days=rem_days)
                    
                    card_count += 1
            except Exception:
                continue

        db.commit()
        print(f"✅ Bound {card_count} cards and updated expiry times.")
        print("\n🎉 Migration Completed!")

    except Exception as e:
        db.rollback()
        print(f"❌ Migration Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    migrate()
