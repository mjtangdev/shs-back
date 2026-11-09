"""
测试并执行 q1database 目录下老 MySQL 数据的全量无损迁移
"""
import os
import logging
from app.core.legacy_migration import run_legacy_sql_migration

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("q1_migration")

def main():
    q1_dir = os.path.join(os.path.dirname(__file__), "q1database")
    if not os.path.exists(q1_dir):
        logger.error(f"❌ 目录 {q1_dir} 不存在！")
        return

    logger.info(f"📂 正在读取 {q1_dir} 目录下的所有老 MySQL SQL 脚本...")
    files_dict = {}
    for fname in os.listdir(q1_dir):
        if fname.endswith(".sql"):
            fpath = os.path.join(q1_dir, fname)
            with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
                files_dict[fname] = f.read()

    logger.info(f"✨ 成功读取 {len(files_dict)} 个 SQL 文件，开始执行无损迁移...")
    success, msg = run_legacy_sql_migration(files_dict)
    if success:
        logger.info(f"🎉 迁移成功！{msg}")
    else:
        logger.error(f"❌ 迁移失败：{msg}")

if __name__ == "__main__":
    main()
