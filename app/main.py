import os
import logging
import json
import secrets
from datetime import datetime
from typing import Any
from fastapi import FastAPI, Request, HTTPException, Depends, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi.openapi.docs import get_swagger_ui_html, get_redoc_html
from fastapi.openapi.utils import get_openapi
from contextlib import asynccontextmanager
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from sqlalchemy import text

# 1. 导入业务模型
from app.db.base_class import Base
from app.db.session import engine, SessionLocal
from app.api.v1.api import api_router
from app.api.v1.endpoints import apk
from app.core.websocket_manager import manager
from fastapi import WebSocket, WebSocketDisconnect

# --- [ 核心增强 ] 全局统一日期序列化器 (去除 T) ---
class NonTJSONResponse(JSONResponse):
    """
    自定义响应类：将所有 datetime 对象统一格式化为 yyyy-MM-dd HH:mm:ss
    不再输出 ISO 格式中的 'T'。
    """
    def render(self, content: Any) -> bytes:
        return json.dumps(
            content,
            ensure_ascii=False,
            allow_nan=False,
            indent=None,
            separators=(",", ":"),
            default=lambda obj: obj.strftime("%Y-%m-%d %H:%M:%S") if isinstance(obj, datetime) else str(obj),
        ).encode("utf-8")

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
        from app.models.users import User
        from app.models.org import Region
        from app.models.config import ProviderConfig
        from app.core.auth_utils import hash_password

        Base.metadata.create_all(bind=engine)
        
        db = SessionLocal()
        
        # --- [ 自动初始化检查 ] ---
        # 如果数据库中没有用户，则自动创建默认账号
        if not db.query(User).first():
            logger.info("🌱 No users found. Initializing default accounts...")
            
            # 1. 创建基础根区域
            root_region = Region(name="Pangasinan", level=0, daily_rate=7.0)
            db.add(root_region)
            db.flush()

            # 2. 创建超级管理员 (Role 0)
            db.add(User(
                username="superadmin",
                password_hash=hash_password("Supplier_Secure_Pwd_2026"),
                first_name="Supplier", last_name="Support",
                role=0, mobile="1111111111", region_id=root_region.id,
                is_active=True
            ))

            # 3. 创建系统管理员 (Role 1)
            db.add(User(
                username="admin",
                password_hash=hash_password("admin123"),
                first_name="System", last_name="Admin",
                role=1, mobile="09123456789", region_id=root_region.id,
                is_active=True
            ))

            # 4. 初始化供应商基础配置
            db.add(ProviderConfig(
                name="Default SHS Provider",
                tin="TIN_INIT_0000",
                is_initialized=False
            ))
            db.commit()
            logger.info("✅ Default accounts (superadmin/admin) created.")

        # 序列同步维护
        tables = ["users", "customers", "cards", "solar_units", "solar_pv_panels", "transaction_logs", "regions", "pos_machines"]
        for table in tables:
            try:
                max_id = db.execute(text(f"SELECT MAX(id) FROM {table}")).scalar() or 1
                seq = db.execute(text(f"SELECT pg_get_serial_sequence('{table}', 'id')")).scalar()
                if seq:
                    db.execute(text(f"SELECT setval('{seq}', {max_id}, true)"))
            except: pass
        db.commit()

        # ==============================================================================
        # ⚠️【一次性平滑迁移补丁 / MIGRATION PATCH】
        # 作用：将老数据库中旧列解绑 NOT NULL 限制，并清理老系统自动生成的假 PV 序列号 (末尾带 1)
        # 提示：首次上线升级跑完后，后续版本开发如需关闭，可将此代码块注释掉！
        # ==============================================================================
        try:
            db.execute(text("ALTER TABLE solar_units ALTER COLUMN solar_equipment_id DROP NOT NULL;"))
            db.execute(text("UPDATE solar_units SET solar_equipment_id = NULL WHERE solar_equipment_id = shs_machine_id || '1';"))
            db.commit()
        except Exception:
            db.rollback()
        # ==============================================================================
        db.close()
        logger.info("✅ Database ready and sequences synced.")
    except Exception as e:
        logger.error(f"❌ Startup error: {e}")

    # 定时备份 (生产模式：每天 0点 和 12点 各执行一次)
    from apscheduler.schedulers.background import BackgroundScheduler
    from app.core.backup import perform_db_backup
    scheduler = BackgroundScheduler()
    # 使用 cron 触发器，在 0:00 和 12:00 备份
    scheduler.add_job(perform_db_backup, 'cron', hour='0,12', minute=0)
    scheduler.start()
    yield
    scheduler.shutdown()

# --- [ 核心增强 ] API 文档保护 ---
security = HTTPBasic()

def get_current_username(credentials: HTTPBasicCredentials = Depends(security)):
    # 你可以修改这里的账号密码，或者从环境变量读取
    correct_username = secrets.compare_digest(credentials.username, "superadmin")
    correct_password = secrets.compare_digest(credentials.password, "Supplier_Secure_Pwd_2026")
    if not (correct_username and correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username

# 💡 应用自定义响应类
app = FastAPI(
    title="SHS API", 
    version="1.0.0", 
    lifespan=lifespan,
    default_response_class=NonTJSONResponse,
    docs_url=None,
    redoc_url=None,
    openapi_url=None
)

# --- [ 核心增强 ] 422 参数校验异常处理 ---
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """
    自定义 422 错误处理：将复杂的验证错误简化为人类易读的提示。
    例如: "字段 'mobile' 校验失败: 长度不能小于 5"
    """
    errors = []
    for error in exc.errors():
        # 获取发生错误的字段名 (例如: body -> user_in -> mobile)
        field = " -> ".join([str(loc) for loc in error.get("loc")])
        msg = error.get("msg")
        errors.append(f"[{field}]: {msg}")

    error_detail = " | ".join(errors)
    logger.warning(f"❌ Validation Error on {request.url.path}: {error_detail}")

    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "status": "error",
            "message": "数据格式验证失败 (422)",
            "detail": error_detail,
            "errors": exc.errors() # 保留原有的详细错误结构供调试
        },
    )

# --- 自定义文档路由 ---
@app.get("/docs", include_in_schema=False)
async def protected_swagger_ui_html(username: str = Depends(get_current_username)):
    return get_swagger_ui_html(
        openapi_url="/openapi.json",
        title=app.title + " - Swagger UI",
        oauth2_redirect_url=app.swagger_ui_oauth2_redirect_url,
        swagger_js_url="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js",
        swagger_css_url="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css",
    )

@app.get("/redoc", include_in_schema=False)
async def protected_redoc_html(username: str = Depends(get_current_username)):
    return get_redoc_html(
        openapi_url="/openapi.json",
        title=app.title + " - ReDoc",
    )

@app.get("/openapi.json", include_in_schema=False)
async def get_open_api_endpoint(username: str = Depends(get_current_username)):
    return get_openapi(title=app.title, version=app.version, routes=app.routes)

# CORS 配置：兼容 localhost 前端开发端口 (3000/3001/5173 等) 与 allow_credentials=True
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:3002",
        "http://localhost:5173",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:3001",
        "http://127.0.0.1:3002",
        "http://127.0.0.1:5173",
    ],
    allow_origin_regex=r"https?://.*",
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
app.include_router(apk.router, prefix="/apk")

@app.get("/")
async def root(): return {"status": "running", "time": datetime.now()}
