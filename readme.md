# SHS Management System Backend / SHS 管理系统后端

本项目是 SHS (Solar Home System) 管理系统的后端 API，基于 FastAPI 构建。
This project is the backend API for the SHS (Solar Home System) management system, built with FastAPI.

---

## 🐳 Docker Deployment / Docker 一键部署

### 1. One-click Deployment / 本地一键启动 (推荐)
```bash
# Start all services (Backend + Database) / 启动全栈服务
docker-compose up -d --build
```
- **Backend**: `http://localhost:8000`
- **Database**: `localhost:5432`

### 2. Database Operations (Inside Docker) / 容器内数据库操作
如果你在服务器上部署，使用以下命令初始化数据：
```bash
# Initialize tables and basic accounts / 初始化表结构及基础账号
docker exec -it shs-backend-api python init_db.py

# [Production Test] Seed 5000 items & 60,000 transactions / [生产测试] 生成 5000 套设备及 6 万条流水
docker exec -it shs-backend-api python seed_production_data.py

# Seed 1240 unbound customers and inventory / 生成 1240 条测试数据
docker exec -it shs-backend-api python seed_large_data.py
```

### 3. Multi-platform Build / 跨平台镜像打包
如果你需要构建并推送到 Docker Hub，请使用以下命令：
```bash
# Build for specific platform (e.g. AMD64) / 针对特定平台构建并加载到本地
docker buildx build --platform linux/amd64 -t mjtangdev/shs-backend:latest --load .

# Build for multiple platforms and push to Docker Hub / 一次性构建多平台镜像并推送
docker buildx build --platform linux/amd64,linux/arm64 -t mjtangdev/shs-backend:latest --push .
```

---

## 🚀 Quick Start / 快速启动 (Local Development)

### 1. Environment / 环境准备
```bash
# Create and activate virtual environment / 创建并激活虚拟环境
python -m venv .venv
source .venv/bin/activate  # Mac/Linux (Relative)
source /Users/michael/dev/shs/shs-back/.venv/bin/activate  # Mac/Linux (Absolute Path)
# .venv\Scripts\activate  # Windows

# Install dependencies / 安装依赖
pip install -r requirements.txt
```

### 2. Database Initialization / 数据库初始化
```bash
# Start Database (Docker required) / 启动数据库 (需安装 Docker)
docker-compose up -d db

# Initialize tables and seed test data / 初始化表结构并生成测试数据
./.venv/bin/python init_db.py

# Reset/Clean all data / 彻底清空并重置所有业务数据
./.venv/bin/python init_db.py

# [Production Test] Seed 5000 items & 60,000 transactions / [生产测试] 生成 5000 套设备及 6 万条流水
./.venv/bin/python seed_production_data.py

# Initialize a clean production-ready database (Admin only) / 初始化纯净生产数据库 (仅保留 admin)
./.venv/bin/python init_db_clean.py

# Seed 1240 unbound customers and inventory / 生成 1240 条测试数据
./.venv/bin/python seed_large_data.py
```

### 3. Run Service / 运行服务
```bash
./.venv/bin/python main.py
```
- **Base URL**: `http://127.0.0.1:8000`
- **API Docs**: `http://127.0.0.1:8000/docs` (Swagger UI)

---

## 🔑 Test Accounts / 核心账号信息 (测试模式)

| Role / 角色 | Username / 用户名 | Password / 密码 | Description / 说明 |
| :--- | :--- | :--- | :--- |
| **Super Admin** | `sysadmin` | `Supplier_Secure_Pwd_2026` | Vendor support / 供应商支持 |
| **Admin** | `admin` | `admin123` | System management / 系统管理 |
| **Operator** | `opera` | `test123` | POS login / 业务员登录 |
| **Management** | `manager` | `test123` | Dashboard / 管理层看板 |

---

## 🛠 API Endpoints / API 接口说明

### 1. Authentication / 认证模块 (`/api/v1/login`)
*   **POST** `/token` : Get OAuth2 access token (Form Data). / 获取 OAuth2 访问令牌。
*   **POST** `/token-json` : Login via JSON. / 通过 JSON 登录。

### 2. Dashboard / 首页看板 (`/api/v1/dashboard`)
*   **GET** `/stats` : Get real-time stats, revenue growth, and region rankings. / 获取实时统计、营收增长及区域排名。

### 3. Customer Management / 客户管理 (`/api/v1/customer`)
*   **GET** `/` : List customers / 客户列表
*   **GET** `/export` : Export detailed report (CSV with BOM, Excel friendly). / 导出详尽报表 (CSV 格式，极速且不乱码)。

### 4. POS Synchronization / POS 业务同步 (`/api/v1/pos-sync`)
*   **POST** `/upload` : Batch upload offline transactions and new customers. / 批量上传离线流水与新开户数据。

---

## 📋 Roles & Permissions / 权限说明
*   **Role 0 (Super Admin)**: Vendor support.
*   **Role 1 (Admin)**: System manager.
*   **Role 2 (Operator)**: Salesperson / POS user.
*   **Role 3 (Finance)**: Audits and reports.
*   **Role 4 (Management)**: Executive dashboard and analytics.

## 📁 Project Structure / 目录结构
*   `app/api`: Routes / 路由层
*   `app/models`: Database Models / 数据库模型
*   `app/schemas`: Pydantic Models / 数据校验
*   `seed_large_data.py`: Data seeding script (1240 customers). / 大规模数据生成脚本。
