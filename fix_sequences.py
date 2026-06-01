from sqlalchemy import text
from app.db.session import SessionLocal, engine

def fix():
    db = SessionLocal()
    print("🔧 正在同步数据库主键序列...")
    
    tables = ["users", "customers", "cards", "solar_units", "transaction_logs", "regions", "pos_machines"]
    
    try:
        for table in tables:
            # 找到当前表最大的 ID，并把发号器拨到那个数字之后
            sql = f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), COALESCE(MAX(id), 1)) FROM {table}"
            db.execute(text(sql))
            print(f"✅ 表 {table} 同步完成")
        
        db.commit()
        print("\n🎉 所有序列已同步！现在您可以正常创建用户或客户了。")
    except Exception as e:
        print(f"❌ 修复失败: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    fix()
