import logging
from sqlalchemy import text
from app.db.session import SessionLocal

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("business_init")

def init_business_simple():
    db = SessionLocal()
    logger.info("🏗️  Starting Simple Business Structure Setup...")

    try:
        # 1. 清理现有区域和配置 (保留用户)
        db.execute(text("TRUNCATE TABLE regions, provider_configs RESTART IDENTITY CASCADE;"))

        # 2. 插入根节点 (Level 0)
        # 返回插入后的 ID
        root_id = db.execute(text(
            "INSERT INTO regions (name, level, daily_rate) VALUES ('QUEZELCO-1', 0, 7.0) RETURNING id"
        )).scalar()

        # 插入基础供应商配置
        db.execute(text(
            f"INSERT INTO provider_configs (name, tin, is_initialized) VALUES ('QUEZELCO-1 SHS', '12345678', true)"
        ))

        # 3. 逐个创建 14 个城镇结构 (就像你在网页上手动操作一样)
        mapping = {
            "Tagkawayan": ["Del Gallego", "Guinyangan", "Calauag", "Lopez"],
            "Gumaca": ["Plaridel", "Atimonan"],
            "Alabat": ["Quezon-Quezon", "Perez"],
            "Agdangan": ["Padre Burgos", "Unisan", "Pitogo"],
            "Macalelon": ["Gen. Luna", "Catanauan", "Mulanay"],
            "San Narciso": ["Buenavista"],
            "San Francisco": ["San Andres"]
        }

        for town, villages in mapping.items():
            # 创建城镇 (Level 1)
            t_id = db.execute(text(
                "INSERT INTO regions (name, level, parent_id, daily_rate) VALUES (:name, 1, :pid, 7.0) RETURNING id"
            ), {"name": town, "pid": root_id}).scalar()

            # 为每个城镇创建下属村落 (Level 2)
            for v in villages:
                db.execute(text(
                    "INSERT INTO regions (name, level, parent_id, daily_rate) VALUES (:name, 2, :pid, 7.0)"
                ), {"name": v, "pid": t_id})

        # 4. 链接管理员账号到新的根节点
        db.execute(text(f"UPDATE users SET region_id = {root_id} WHERE role IN (0, 1)"))

        db.commit()
        logger.info(f"✅ Setup Complete: 14 towns created and linked to root ID {root_id}")

    except Exception as e:
        db.rollback()
        logger.error(f"❌ Setup Failed: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    init_business_simple()
