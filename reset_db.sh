#!/bin/bash

# 1. 确保在项目根目录
cd "$(dirname "$0")" || exit

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

echo "🚀 Starting SHS Backend Service..."
echo "------------------------------------------------"
./.venv/bin/python main.py
