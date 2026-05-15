# SHS 后端管理系统 API 文档

**基础路径前缀**: `/api/v1` (前端请求时请确保包含此路径，以下列表为展示方便已省略)  
**认证方式**: Bearer Token (Header: `Authorization: Bearer <token>`)

---

## 1. 认证与系统状态 (Login & Setup)

| 方法 | 路径 | 说明 | 请求参数/数据 |
| :--- | :--- | :--- | :--- |
| POST | `/login/token` | 登录 | Form: `username`, `password` |
| POST | `/emergency-reset-admin` | 紧急重置管理员密码 | 仅限 Role 0 (超级管理员) |

---

## 2. 用户管理 (Users)

| 方法 | 路径 | 说明 | 请求数据 (JSON Body) |
| :--- | :--- | :--- | :--- |
| POST | `/user/` | 创建用户 | `username`, `password`, `first_name`, `last_name`, `mobile`, `role?`, `region_id?` |
| GET | `/user/` | 获取列表 | Query: `skip`, `limit` |
| PATCH | `/user/update` | 更新用户信息 | Body: `user_id` (必填), `first_name?`, `last_name?`, `region_id?` |
| DELETE | `/user/delete` | 逻辑删除用户 | Body: `user_id` (必填) |
| PATCH | `/user/me/change-password` | 修改个人密码 | `new_password` (必填，不可使用 admin123) |

---

## 3. 区域与费率管理 (Regions & Rates)

| 方法 | 路径 | 说明 | 请求数据 (JSON Body) |
| :--- | :--- | :--- | :--- |
| GET | `/regions/tree` | 获取区域树 | 无 (业务员仅能查看所属地区) |
| POST | `/regions/` | 创建子区域 | `name`, `parent_id` (0为根节点) |
| PATCH | `/regions/{region_id}/name` | 修改区域名称 | 路径参数: `region_id`, Body: `name` |
| GET | `/regions/{region_id}/rate` | 获取区域费率 | 路径参数: `region_id` |
| PATCH | `/regions/{region_id}/rate` | 修改区域费率 | 路径参数: `region_id`, Body: `new_rate` |
| PATCH | `/regions/sync-all-rates` | 全局同步费率 | `new_rate` (一键更新所有地区) |

---

## 4. 子公司/业务主体管理 (Entities)

| 方法 | 路径 | 说明 | 请求数据 (JSON Body) |
| :--- | :--- | :--- | :--- |
| POST | `/entities/` | 创建主体 | `name`, `entity_type?` (1:子公司, 2:代理), `region_id?` |
| GET | `/entities/` | 获取主体列表 | 无 (业务员自动过滤所属主体) |
| GET | `/entities/{entity_id}` | 获取单个主体信息 | 路径参数: `entity_id` |
| PATCH | `/entities/update` | 更新主体信息 | Body: `entity_id` (必填), `name?`, `region_id?` |
| DELETE | `/entities/delete` | 逻辑删除主体 | Body: `entity_id` (必填) |

---

## 5. 客户管理 (Customers)

| 方法 | 路径 | 说明 | 请求数据 |
| :--- | :--- | :--- | :--- |
| GET | `/customer/` | 获取客户列表 | Query: `search?`, `region_id?`, `skip`, `limit` |
| POST | `/customer/create` | 创建客户 | `first_name`, `last_name`, `gender`, `mobile`, `region_id` |
| PUT | `/customer/{customer_id}` | 编辑客户信息 | 路径参数: `customer_id`, Body: `mobile?`, `address?` |
| POST | `/customer/import` | Excel 批量导入 | Query: `region_id`, File: `file` |
| GET | `/customer/export` | 导出客户数据 | Query: `region_id?` |
| DELETE | `/customer/{customer_id}` | 物理删除客户 | 路径参数: `customer_id` |

---

## 6. 太阳能设备资产 (Solar Devices)

| 方法 | 路径 | 说明 | 请求数据 |
| :--- | :--- | :--- | :--- |
| GET | `/solar_device/` | 获取设备列表 | Query: `search?`, `status?` (0:在库, 1:激活) |
| POST | `/solar_device/create` | 手动入库 | `shs_machine_id`, `production_date` 等5大ID |
| POST | `/solar_device/import` | Excel 批量导入 | File: `file` |
| POST | `/solar_device/{unit_id}/reset` | 回收入库 | 路径参数: `unit_id` (清空客户绑定) |
| DELETE | `/solar_device/{unit_id}` | 删除在库设备 | 路径参数: `unit_id` (激活中不可删) |

---

## 7. 智能卡片管理 (Cards)

| 方法 | 路径 | 说明 | 请求数据 |
| :--- | :--- | :--- | :--- |
| GET | `/card/` | 获取卡片列表 | Query: `search?`, `status?` |
| POST | `/card/create` | 手动入库 | `card_number`, `card_uuid` |
| POST | `/card/import` | Excel 批量导入 | File: `file` |
| GET | `/card/export` | 导出卡片资产 | Query: `status?` |
| POST | `/card/{card_id}/reset` | 锁定/回收入库 | 路径参数: `card_id` |
| DELETE | `/card/{card_id}` | 删除卡片 | 路径参数: `card_id` |

---

## 8. POS 终端管理 (POS)

| 方法 | 路径 | 说明 | 请求数据 |
| :--- | :--- | :--- | :--- |
| GET | `/pos/` | 获取 POS 列表 | Query: `search?` |
| POST | `/pos/create` | 手动录入 POS | `pos_sn` (16位，自动补零), `branch_office?` |
| PUT | `/pos/{pos_sn}` | 编辑 POS 信息 | 路径参数: `pos_sn`, Body: `status?`, `branch_office?` |
| POST | `/pos/lock` | 锁定终端 | `pos_sn`, `remark` |
| POST | `/pos/unlock` | 解锁终端 | `pos_sn`, `remark` |
| GET | `/pos/{pos_sn}/logs` | 查看审计日志 | 路径参数: `pos_sn` |
| DELETE | `/pos/{pos_sn}` | 软删除 POS | 路径参数: `pos_sn` |

---

## 9. POS 业务数据同步 (POS Sync)

*此模块接口专门提供给 POS 终端手持设备使用，主要基于操作员权限进行数据下发。*

| 方法 | 路径 | 说明 | 请求参数/数据 |
| :--- | :--- | :--- | :--- |
| GET | `/pos-sync/download` | 下载业务白名单 | Query: `pos_sn` |
| POST | `/pos-sync/upload` | 增量上传离线数据 | `pos_sn`, `new_customers` (列表), `transactions` (列表) |

---

## 10. 供应商与 APK 配置 (System)

| 方法 | 路径 | 说明 | 请求数据 |
| :--- | :--- | :--- | :--- |
| GET | `/provider/` | 获取总公司配置 | 无 |
| PATCH | `/provider/` | 更新公司信息 | Form-Data: `name?`, `logo` (File), `tin?`, `phone?` |
| POST | `/apk/upload` | 上传/更新 APK | File: `file` (仅管理员) |
| GET | `/apk/download` | 下载最新 APK | 无 (公开接口) |
| GET | `/hello/world` | 连通性测试 | 无 |

---

### 权限定义
- **Role 0 (Super Admin)**: 供应商支持人员，拥有最高重置权限。
- **Role 1 (Admin)**: 客户侧管理员，负责区域划分、用户创建、子公司分配。
- **Role 2 (Operator)**: 业务员，主要进行客户录入、设备查询，受区域限制。
- **Role 3 (Finance)**: 财务，主要进行费率调整、POS 锁定解锁及报表导出。

### 业务说明
1. **初始化流程**: 管理员首次登录需修改默认密码(`admin123`) -> 配置总公司名称/TIN -> 修改顶级地区名称。
2. **区域绑定**: 创建业务员或子公司时，若指定 `region_id`，系统会自动关联其上级市/镇。
3. **逻辑删除**: 用户、POS、子公司均采用逻辑删除，数据保留以维护操作审计的一致性。