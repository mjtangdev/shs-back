#!/bin/bash

# 1. 确保在项目根目录
cd "$(dirname "$0")" || exit

echo "🛑 Step 1: Stopping and removing Docker containers..."
docker compose down

echo "🧹 Step 2: Cleaning up persistent database data..."
rm -rf ./postgres_data

echo "🏗️ Step 3: Starting clean database container..."
docker compose up -d

echo "⏳ Step 4: Waiting for database (5s)..."
sleep 5

echo "🏗️ Step 5: Ground Zero - Initializing DB and Core Users..."
./.venv/bin/python init_db_clean.py

echo "🎨 Step 6: Business Setup - Creating 14 Towns and linking admins..."
./.venv/bin/python reset_standard_structure.py

echo "🚀 Step 7: Starting SHS Backend Service..."
echo "------------------------------------------------"
./.venv/bin/python main.py
