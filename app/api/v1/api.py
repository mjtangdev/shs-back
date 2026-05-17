from fastapi import APIRouter
from app.api.v1.endpoints import hello, users, login, org, customer, card, pos, solar_device, provider, apk, pos_sync, finance, pos_terminal

api_router = APIRouter()

# 把 hello 的路由挂载进来
# 这里我们可以给它统一加上前缀和标签
api_router.include_router(hello.router, prefix="/hello", tags=["Greeting"])

api_router.include_router(login.router, prefix="/login", tags=["Authentication"])

# 挂载 users 模块 (这就是你缺少的步骤)
# prefix="/users" 意味着该文件下的所有接口都会带上这个前缀
api_router.include_router(users.router, prefix="/user", tags=["Users Management"])



api_router.include_router(org.router, prefix="/org", tags=["组织架构与业务主体"])

api_router.include_router(customer.router, prefix="/customer", tags=["Customer"])

api_router.include_router(card.router, prefix="/card", tags=["IC Card"])

api_router.include_router(pos.router, prefix="/pos", tags=["pos"])

# 挂载 POS 终端专用接口 (登录、状态检查)
api_router.include_router(pos_terminal.router, prefix="/pos-terminal", tags=["POS Terminal"])

api_router.include_router(solar_device.router, prefix="/solar_device", tags=["solar device"])

# 挂载 POS 业务同步路由
api_router.include_router(pos_sync.router, prefix="/pos-sync", tags=["POS Sync"])

api_router.include_router(provider.router, prefix="/provider", tags=["Provider Config"])

# 挂载 APK 文件管理路由 - 缺失的这一行
api_router.include_router(apk.router)

# 挂载财务管理路由
api_router.include_router(finance.router, prefix="/finance", tags=["Finance Management"])
