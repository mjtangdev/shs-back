from fastapi import APIRouter
from app.api.v1.endpoints import (
    hello, users, login, org, customer, card, 
    pos, solar_device, provider, apk, 
    pos_sync, finance, pos_terminal, dashboard
)

api_router = APIRouter()

# 基础与认证
api_router.include_router(hello.router, prefix="/hello", tags=["Greeting"])
api_router.include_router(login.router, prefix="/login", tags=["Authentication"])
api_router.include_router(users.router, prefix="/user", tags=["Users Management"])

# 首页仪表盘
api_router.include_router(dashboard.router, prefix="/dashboard", tags=["Dashboard"])

# 业务管理
api_router.include_router(org.router, prefix="/org", tags=["Organization"])
api_router.include_router(customer.router, prefix="/customer", tags=["Customer"])
api_router.include_router(card.router, prefix="/card", tags=["IC Card"])
api_router.include_router(solar_device.router, prefix="/solar_device", tags=["Solar Device"])

# POS 相关
api_router.include_router(pos.router, prefix="/pos", tags=["POS Management"])
api_router.include_router(pos_terminal.router, prefix="/pos-terminal", tags=["POS Terminal"])
api_router.include_router(pos_sync.router, prefix="/pos-sync", tags=["POS Sync"])

# 系统配置与财务
api_router.include_router(provider.router, prefix="/provider", tags=["Provider Config"])
api_router.include_router(apk.router, prefix="/apk", tags=["APK Management"])
api_router.include_router(finance.router, prefix="/finance", tags=["Finance Management"])
