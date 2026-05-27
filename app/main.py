import os
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

# 导入你的 API 路由
from app.api.v1.api import api_router
from app.core.ratelimit import limiter
from app.models.config import ProviderConfig 
from app.models.org import Region 
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer 
from app.models.transaction import TransactionLog 
from app.db.base_class import Base
from app.db.session import engine, SessionLocal
from app.models.users import User
from app.core.auth_utils import hash_password

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 【启动时执行】
    print("--- 正在检查并创建表结构 ---")
    Base.metadata.create_all(bind=engine)
    yield
    # 【关闭时执行】
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
        # 格式化错误信息：字段名 -> 错误原因
        field = " -> ".join([str(loc) for loc in error.get("loc", []) if loc != "body"])
        message = error.get("msg", "Validation error")
        errors.append(f"{field}: {message}")
    
    return JSONResponse(
        status_code=422,
        content={
            "detail": "Data validation failed",
            "errors": errors
        }
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

PROJECT_ROOT = Path(__file__).resolve().parent.parent
LOGO_PHYSICAL_DIR = PROJECT_ROOT / "static" / "uploads" / "logos"
LOGO_PHYSICAL_DIR.mkdir(parents=True, exist_ok=True)

app.mount("/static", StaticFiles(directory=LOGO_PHYSICAL_DIR), name="static")

app.include_router(api_router, prefix="/api/v1")

@app.get("/")
async def root():
    return {"status": "Backend is running", "message": "Welcome to SHS Backend API"}
