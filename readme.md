# SHS 后端管理系统 API 文档 / SHS Backend API Documentation

**基础路径前缀 / Base Path**: `/api/v1`  
**认证方式 / Auth**: Bearer Token (Header: `Authorization: Bearer <token>`)

---

## 1. 认证与系统状态 / Auth & System Status

| 方法 / Method | 路径 / Path | 说明 / Description | 请求参数 / Params |
| :--- | :--- | :--- | :--- |
| POST | `/login/token` | 登录 / Login | Form: `username`, `password` |
| POST | `/emergency-reset-admin` | 紧急重置管理员密码 / Reset Admin | Role 0 Only |

---

## 2. 用户管理 / User Management

| 方法 / Method | 路径 / Path | 说明 / Description | 请求数据 / Request Body |
| :--- | :--- | :--- | :--- |
| POST | `/user/` | 创建用户 / Create User | `username`, `password`, `role`, `region_id` |
| GET | `/user/` | 获取列表 / List Users | Query: `skip`, `limit` |
| PATCH | `/user/update` | 更新用户信息 / Update User | `user_id`, `first_name?`, `region_id?` |
| DELETE | `/user/delete` | 逻辑删除用户 / Delete User | `user_id` |
| PATCH | `/user/me/change-password` | 修改个人密码 / Change Pwd | `new_password` |

---

## 3. 区域与费率 / Regions & Rates

| 方法 / Method | 路径 / Path | 说明 / Description | 请求数据 / Request Body |
| :--- | :--- | :--- | :--- |
| GET | `/regions/tree` | 获取区域树 / Region Tree | - |
| POST | `/regions/` | 创建子区域 / Create Sub-region | `name`, `parent_id` |
| PATCH | `/regions/{region_id}/name` | 修改区域名称 / Update Name | `name` |
| GET | `/regions/{region_id}/rate` | 获取区域费率 / Get Rate | - |
| PATCH | `/regions/{region_id}/rate` | 修改区域费率 / Update Rate | `new_rate` |
| PATCH | `/regions/sync-all-rates` | 全局同步费率 / Sync All Rates | `new_rate` |

---

## 4. 子公司与主体 / Entities

| 方法 / Method | 路径 / Path | 说明 / Description | 请求数据 / Request Body |
| :--- | :--- | :--- | :--- |
| POST | `/entities/` | 创建主体 / Create Entity | `name`, `entity_type`, `region_id` |
| GET | `/entities/` | 获取主体列表 / List Entities | - |
| PATCH | `/entities/update` | 更新主体信息 / Update Entity | `entity_id`, `name?` |
| DELETE | `/entities/delete` | 逻辑删除主体 / Delete Entity | `entity_id` |

---

## 5. 客户管理 / Customer Management

| 方法 / Method | 路径 / Path | 说明 / Description | 请求参数 / Params |
| :--- | :--- | :--- | :--- |
| GET | `/customer/` | 获取客户列表 / List Customers | Query: `search`, `skip`, `limit` |
| POST | `/customer/create` | 创建客户 / Create Customer | `first_name`, `last_name`, `mobile`, `region_id` |
| PUT | `/customer/{customer_id}` | 编辑客户 / Update Customer | `mobile`, `address` |
| POST | `/customer/import` | Excel 导入 / Import | File: `file`, Query: `region_id` |
| GET | `/customer/export` | 导出数据 / Export | - |

---

## 6. 太阳能设备 / Solar Devices

| 方法 / Method | 路径 / Path | 说明 / Description | 请求参数 / Params |
| :--- | :--- | :--- | :--- |
| GET | `/solar_device/` | 设备列表 / List Devices | Query: `status` (0:Stock, 1:Active) |
| POST | `/solar_device/create` | 手动入库 / Manual Import | IDs, `production_date` |
| POST | `/solar_device/import` | Excel 批量导入 / Batch Import | File: `file` |
| POST | `/solar_device/{unit_id}/reset` | 回收入库 / Recover Device | - |

---

## 7. 智能卡片 / Smart Cards

| 方法 / Method | 路径 / Path | 说明 / Description | 请求参数 / Params |
| :--- | :--- | :--- | :--- |
| GET | `/card/` | 卡片列表 / List Cards | Query: `status` |
| POST | `/card/create` | 手动入库 / Manual Create | `card_number`, `card_uuid` |
| POST | `/card/import` | Excel 批量导入 / Batch Import | File: `file` |
| POST | `/card/{card_id}/reset` | 回收入库 / Reset Card | - |

---

## 8. POS 终端管理 / POS Management

| 方法 / Method | 路径 / Path | 说明 / Description | 请求参数 / Params |
| :--- | :--- | :--- | :--- |
| GET | `/pos/check/{pos_sn}` | **公开: SN 校验** / **Public: SN Check** | **无需 Token / No Token Required** |
| GET | `/pos/` | POS 列表 / List POS | Query: `search` |
| POST | `/pos/create` | 手动录入 / Register POS | `pos_sn`, `branch_office` |
| POST | `/pos/lock` | 锁定终端 / Lock POS | `pos_sn`, `remark` |
| POST | `/pos/unlock` | 解锁终端 / Unlock POS | `pos_sn` |

---

## 9. POS 业务同步 / POS Sync (Offline Support)

| 方法 / Method | 路径 / Path | 说明 / Description | 备注 / Note |
| :--- | :--- | :--- | :--- |
| GET | `/pos-sync/customers` | **批量下载客户** / **Batch Get Customers** | 支持 `since_id` 增量同步 / Incremental |
| GET | `/pos-sync/cards` | **批量下载卡片** / **Batch Get Cards** | 支持 `since_id` 增量同步 / Incremental |
| GET | `/pos-sync/solar-devices` | **批量下载设备** / **Batch Get Devices** | 支持 `since_id` 增量同步 / Incremental |
| POST | `/pos-sync/upload` | **同步离线数据** / **Sync Offline Data** | 上传新客户及交易 / Upload New Custs & Txs |
| ~~GET~~ | ~~/pos-sync/download~~ | ~~下载白名单 / Download All~~ | **弃用 / Deprecated** |

---

## 10. 系统配置 / System Config

| 方法 / Method | 路径 / Path | 说明 / Description | 请求参数 / Params |
| :--- | :--- | :--- | :--- |
| GET | `/provider/` | 获取公司配置 / Get Provider Info | - |
| PATCH | `/provider/` | 更新公司信息 / Update Provider | `name`, `logo`, `tin` |
| GET | `/apk/download` | 下载最新 APK / Download APK | 公开 / Public |

---

### 权限角色 / Roles
- **Role 0 (Super Admin)**: 供应商支持 / Vendor Support.
- **Role 1 (Admin)**: 客户管理员 / Client Admin.
- **Role 2 (Operator)**: 业务员 (POS用户) / Sales Operator (POS User).
- **Role 4 (Management)**: 管理层 / Management (Read-only data insight).
- **Role 3 (Finance)**: 财务 / Finance (Rate & Billing).

### 业务说明 / Business Logic
1. **增量同步 / Incremental Sync**: POS 端应使用 `since_id` 调用接口，获取自上次同步以来的变更数据。
2. **数据隔离 / Data Isolation**: 业务员只能获取其所属区域 (`region_id`) 下的客户数据。
3. **公开接口 / Public API**: `pos/check` 接口旨在提供极速的设备状态静默检测。
