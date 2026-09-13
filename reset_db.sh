#!/bin/bash

# 1. 确保在项目根目录
cd "$(dirname "$0")" || exit

# 允许传参指定端口，例如: ./reset_db.sh 8008 ，若不传默认使用 8008 端口避开 8000 冲突
PORT="${1:-8008}"

echo "🛑 Stopping and removing Docker containers..."
docker compose down

echo "🧹 Cleaning up persistent database data..."
rm -rf ./postgres_data

echo "🏗️ Starting clean database container..."
docker compose up -d

echo "⏳ Waiting for database (5s)..."
sleep 5

echo "🌱 Initializing clean database (Tables + Admin Users)..."
./.venv/bin/python init_db_clean.py

echo "🚀 Starting SHS Backend Service on Port ${PORT}..."
echo "------------------------------------------------"
PORT="${PORT}" ./.venv/bin/python main.py
