import os
import logging
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

# 配置日志记录到文件
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("backend.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# 导入你的 API 路由
from app.api.v1.api import api_router
from app.core.ratelimit import limiter
from app.models.config import ProviderConfig 
from app.models.org import Region 
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer 
from app.models.transaction import TransactionLog 
from sqlalchemy import text
from app.db.base_class import Base
from app.db.session import engine, SessionLocal
from app.models.users import User
from app.core.auth_utils import hash_password

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 【启动时执行】
    logger.info("--- 正在检查并创建表结构 ---")
    Base.metadata.create_all(bind=engine)

    # --- 自动校准主键序列 (Sequence Healing) ---
    logger.info("--- 正在自动校准数据库发号器 ---")
    try:
        db = SessionLocal()
        # 扫描核心业务表
        tables = ["users", "customers", "cards", "solar_units", "transaction_logs", "regions", "pos_machines"]
        for table in tables:
            # 检查表是否存在且有 id 字段
            db.execute(text(f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), COALESCE(MAX(id), 1)) FROM {table}"))
        db.commit()
        db.close()
        logger.info("✅ 数据库发号器校准完成")
    except Exception as e:
        logger.warning(f"⚠️ 发号器校准跳过 (通常发生在表还未完全建立时): {e}")

    # --- 启动定时备份任务 ---
    from apscheduler.schedulers.background import BackgroundScheduler
    from app.core.backup import perform_db_backup

    scheduler = BackgroundScheduler()
    # 每天凌晨 2:00 自动备份并发送邮件
    scheduler.add_job(perform_db_backup, 'cron', hour=2, minute=0)
    scheduler.start()
    logger.info("⏰ Database auto-backup scheduler started (Daily at 02:00)")

    yield
    # 【关闭时执行】
    scheduler.shutdown()
    pass

app = FastAPI(
    title="SHS Management System API",
    version="1.0.0",
    lifespan=lifespan
)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = []
    for error in exc.errors():
        # 获取精准的字段名 (过滤掉 body 层级)
        loc = error.get("loc", [])
        field = str(loc[-1]) if loc else "unknown"
        message = error.get("msg", "Validation error")
        errors.append(f"{field}: {message}")
    
    # 在 backend.log 中记录精准的字段报错
    logger.warning(f"❌ 422 Validation Error at {request.url.path}: {', '.join(errors)}")
    
    return JSONResponse(
        status_code=422,
        content={
            "detail": "Data validation failed",
            "errors": errors
        }
    )

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    # 记录手动的业务报错 (如 400 手机号已存在)
    if exc.status_code >= 400:
        logger.warning(f"⚠️ Business Error at {request.url.path}: {exc.status_code} - {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail}
    )

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    # 记录所有未处理的系统错误 (500)
    logger.error(f"System Error: {request.url.path} - {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal Server Error", "message": str(exc)}
    )

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# --- [ 跨域配置 ] ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 针对 Chrome 的 Private Network Access 限制增加处理
@app.middleware("http")
async def add_private_network_access_header(request: Request, call_next):
    if request.method == "OPTIONS":
        response = await call_next(request)
        response.headers["Access-Control-Allow-Private-Network"] = "true"
        return response
    response = await call_next(request)
    return response

PROJECT_ROOT = Path(__file__).resolve().parent.parent
LOGO_PHYSICAL_DIR = PROJECT_ROOT / "static" / "uploads" / "logos"
LOGO_PHYSICAL_DIR.mkdir(parents=True, exist_ok=True)

app.mount("/static", StaticFiles(directory=LOGO_PHYSICAL_DIR), name="static")

app.include_router(api_router, prefix="/api/v1")

@app.get("/")
async def root():
    return {"status": "Backend is running", "message": "Welcome to SHS Backend API"}
