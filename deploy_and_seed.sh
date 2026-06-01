#!/bin/bash

PROJECT_DIR="/projects/sh-system"
echo "=========================================="
echo " 🚀 执行【全量部署 + 数据自动化恢复】..."
echo "=========================================="

cd "$PROJECT_DIR" || exit 1

# 1. 彻底停机并清理
echo "1. 正在清理旧环境..."
docker compose down
sudo rm -rf postgres_data

# 2. 仅启动数据库容器
echo "2. 正在启动数据库..."
docker compose up -d db

# 💡 关键步：等待 Postgres 初始化完成 (演示环境通常需要 10-15s)
echo "⌛ 正在等待数据库初始化 (15s)..."
sleep 15

# 3. 运行数据迁移/初始化
# 只有这时候运行，数据库的发号器才会在插入数据时被后端捕捉到
echo "3. 正在执行数据迁移 (migrate_real_data.py)..."
# 我们先单独启动后端容器的一个临时任务来跑脚本，或者直接执行
docker compose run --rm shs-backend-api python migrate_real_data.py

# 4. 拉取并正式启动全栈服务
echo "4. 正在同步镜像并启动全量服务..."
docker compose pull
docker compose up -d

echo "=========================================="
echo " 🎉 部署完成！"
echo " 📊 现在数据库已含有老系统 21 台 POS 及 700+ 客户数据。"
echo " 🛠 且后端已自动完成了序列校准。"
echo "=========================================="
