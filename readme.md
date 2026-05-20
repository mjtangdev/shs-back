# SHS Management System Backend / SHS 管理系统后端

本项目是 SHS (Solar Home System) 管理系统的后端 API，基于 FastAPI 构建。
This project is the backend API for the SHS (Solar Home System) management system, built with FastAPI.

---

## 🚀 Quick Start / 快速启动

### 1. Environment / 环境准备
```bash
# Create and activate virtual environment / 创建并激活虚拟环境
python -m venv .venv
source .venv/bin/activate  # Mac/Linux
# .venv\Scripts\activate  # Windows

# Install dependencies / 安装依赖
pip install -r requirements.txt
```

### 2. Database Initialization / 数据库初始化
```bash
# Start Database (Docker required) / 启动数据库 (需安装 Docker)
docker-compose up -d

# Initialize tables and seed test data / 初始化表结构并生成测试数据
# Includes admin accounts and 4-digit pure numeric device IDs
# 包含管理员账号及 4 位纯数字设备 ID
python init_db.py
```

### 3. Run Service / 运行服务
```bash
python main.py
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

---

## 🛠 API Endpoints / API 接口说明

### 1. Authentication / 认证模块 (`/api/v1/login`)
*   **POST** `/token`
    *   **Description**: Get OAuth2 access token (Form Data). / 获取 OAuth2 访问令牌 (表单提交)。
    *   **Payload**: `username`, `password`
*   **POST** `/token-json`
    *   **Description**: Login via JSON. / 通过 JSON 登录。
    *   **Payload**: `{"username": "admin", "password": "..."}`
*   **POST** `/emergency-reset-admin`
    *   **Description**: Reset 'admin' password to 'admin123' (Role 0 only). / 重置管理员密码 (仅限超级管理员)。

### 2. POS Terminal specialized / POS 终端专用 (`/api/v1/pos-terminal`)
*   **POST** `/login`
    *   **Description**: POS dedicated login, returns `daily_rate` and `region_name`. / POS 专用登录，返回费率和地区名称。
    *   **Payload**: `{"username": "...", "password": "...", "pos_sn": "..."}`
*   **GET** `/check/{pos_sn}`
    *   **Description**: Check POS status silently. / 静默检查 POS 状态。

### 3. Users Management / 用户管理 (`/api/v1/user`)
*   **GET** `/` : List users / 用户列表
*   **POST** `/` : Create user / 创建用户
    *   **Payload**: `{"username": "...", "password": "...", "role": 2, "region_id": 1, ...}`
*   **PATCH** `/update` : Update user / 更新用户 (Body 传 `user_id`)
*   **DELETE** `/delete` : Logical delete user / 逻辑删除用户 (Body 传 `user_id`)
*   **PATCH** `/me/change-password` : Change own password / 修改个人密码

### 4. Organization & Rates / 组织架构与费率 (`/api/v1/org`)
*   **GET** `/regions/tree` : Get hierarchical region tree / 获取地区层级树
*   **POST** `/regions/` : Create new region / 创建新地区
    *   **Payload**: `{"name": "Town Name", "parent_id": 1}`
*   **PATCH** `/regions/update-rate` : Update region daily rate / 修改区域费率
    *   **Payload**: `{"region_id": 1, "new_rate": 30.0}`
*   **PATCH** `/regions/sync-all-rates` : Sync all regions to one rate / 全局同步费率
*   **POST** `/entities/` : Create subsidiary or agent / 创建子公司或代理
    *   **Payload**: `{"name": "...", "entity_type": 1, "region_id": 1}`

### 5. Customer Management / 客户管理 (`/api/v1/customer`)
*   **GET** `/` : List customers with region names / 客户列表 (含完整地区名)
*   **POST** `/create` : Manual create customer (Snowflake ID) / 手动录入客户 (雪花 ID)
    *   **Payload**: `{"first_name": "...", "last_name": "...", "gender": "male", "mobile": "...", "region_id": 1}`
*   **PUT** `/{customer_id}` : Update customer details / 修改客户详情
*   **POST** `/import` : Bulk import via Excel / Excel 批量导入
*   **GET** `/export` : Export customer list to Excel / 导出客户列表

### 6. Asset Management / 资产管理 (`/api/v1/card` & `/api/v1/solar_device`)
*   **GET** `/api/v1/card/` : List IC cards / 卡片列表
*   **POST** `/api/v1/solar_device/create` : Register new device set / 录入成套设备
    *   **Payload**: `{"shs_machine_id": "...", "solar_equipment_id": "...", "radio_id": "...", "flashlight_id": "...", "led_light_id": "...", "production_date": "..."}`
*   **POST** `/api/v1/solar_device/{unit_id}/reset` : Reset device to 'In Stock' / 重置设备回库

### 7. POS Synchronization / POS 业务同步 (`/api/v1/pos-sync`)
*   **GET** `/solar-devices` : Pull in-stock devices for POS / POS 拉取在库设备
    *   **Returns**: `[{ "shs_machine_id": "...", "solar_equipment_id": "...", ... }]`
*   **POST** `/upload` : Batch upload offline customers & transactions / 批量上传离线数据
    *   **Payload**: `{ "pos_sn": "...", "new_customers": [...], "transactions": [...] }`

### 8. POS Machine Admin / POS 机管理 (`/api/v1/pos`)
*   **GET** `/` : List all registered POS machines / 已注册 POS 列表
*   **POST** `/create` : Manually register a POS / 手动登记 POS
*   **POST** `/lock` / `/unlock` : Remotely lock/unlock device / 远程锁定/解锁
*   **POST** `/{pos_sn}/assign` : Assign POS to an operator / 将 POS 分配给业务员

---

## 📋 Roles & Permissions / 权限说明
*   **Role 0 (Super Admin)**: Vendor support, highest access. / 供应商支持。
*   **Role 1 (Admin)**: Client admin, manages regions/users. / 客户管理员。
*   **Role 2 (Operator)**: Salesperson, POS terminal operations. / 业务员。
*   **Role 3 (Finance)**: Reconciliation and rate audits. / 财务对账。

## 📁 Project Structure / 目录结构
*   `app/api`: Routes and endpoints / 路由接口层
*   `app/models`: Database models (SQLAlchemy) / 数据库模型
*   `app/schemas`: Data validation (Pydantic) / 数据校验模型
*   `app/core`: Auth, Config, Rate limits / 核心配置与认证
*   `init_db.py`: Database seeding script / 数据库初始化脚本
