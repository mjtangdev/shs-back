import os
import logging
import time
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from sqlalchemy import text

# 导入业务模型
from app.db.base_class import Base
from app.db.session import engine, SessionLocal
from app.api.v1.api import api_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler("backend.log"), logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("🚀 SHS Backend Starting...")
    try:
        from app.models import org, users, customer, card, solar_device, transaction, pos
        Base.metadata.create_all(bind=engine)
        
        # 序列校准
        db = SessionLocal()
        tables = ["users", "customers", "cards", "solar_units", "transaction_logs", "regions", "pos_machines"]
        for table in tables:
            try:
                seq = db.execute(text(f"SELECT pg_get_serial_sequence('{table}', 'id')")).scalar()
                if seq:
                    db.execute(text(f"SELECT setval('{seq}', COALESCE((SELECT MAX(id) FROM {table}), 1), (SELECT MAX(id) FROM {table}) IS NOT NULL)"))
            except Exception as e:
                logger.warning(f"⚠️ {table} sequence sync skipped: {e}")
        db.commit()
        db.close()
        logger.info("✅ Database ready.")
    except Exception as e:
        logger.error(f"❌ Startup error: {e}")

    # 定时备份
    from apscheduler.schedulers.background import BackgroundScheduler
    from app.core.backup import perform_db_backup
    scheduler = BackgroundScheduler()
    scheduler.add_job(perform_db_backup, 'cron', hour=2, minute=0)
    scheduler.start()
    yield
    scheduler.shutdown()

app = FastAPI(title="SHS API", version="1.0.0", lifespan=lifespan)

# --- 核心 CORS 配置：只使用这一套标准做法 ---
origins = [
    "https://shstest.site",
    "https://api.shstest.site",
    "http://shstest.site",
    "http://localhost:3000",
    "http://localhost:5173",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:5173"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# 挂载静态资源
PROJECT_ROOT = Path(__file__).resolve().parent.parent
LOGO_PHYSICAL_DIR = PROJECT_ROOT / "static" / "uploads" / "logos"
LOGO_PHYSICAL_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/static", StaticFiles(directory=LOGO_PHYSICAL_DIR), name="static")

# 挂载路由
app.include_router(api_router, prefix="/api/v1")

@app.get("/")
async def root(): return {"status": "running"}
