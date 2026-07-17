import logging
import sys
import os

# 确保脚本能找到 app 目录
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.restore import perform_db_restore

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("seed_production")

def seed_production():
    """从 production_data.json 恢复生产数据镜像"""
    json_file = "production_data.json"

    if not os.path.exists(json_file):
        print(f"❌ Error: {json_file} not found in current directory.")
        return

    print(f"🚀 Found production data: {json_file}")
    print("⏳ Restoring database (this will overwrite current data)...")

    success, message = perform_db_restore(json_file_path=json_file)

    if success:
        print("\n🎉 SUCCESS: All real data restored and sequences synced!")
    else:
        print(f"\n❌ FAILED: {message}")

if __name__ == "__main__":
    seed_production()
