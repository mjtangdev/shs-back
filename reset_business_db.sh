#!/bin/bash

# 1. 确保在项目根目录
cd "$(dirname "$0")" || exit

echo "🛑 Step 1: Stopping and removing PostgreSQL container..."
docker stop shs_db_container >/dev/null 2>&1
docker rm shs_db_container >/dev/null 2>&1

echo "🧹 Step 2: Starting clean PostgreSQL database container..."
docker run -d --name shs_db_container -p 5432:5432 -e POSTGRES_USER=solar_admin -e POSTGRES_PASSWORD=Webdev123 -e POSTGRES_DB=shs_db postgres:16

echo "⏳ Step 3: Waiting for database initialization (3s)..."
sleep 3

echo "🏗️ Step 4: Ground Zero - Initializing DB Schema and Core Users..."
./.venv/bin/python init_db_clean.py

echo "🎨 Step 5: Business Setup - Creating Standard Regions and Admins..."
./.venv/bin/python reset_standard_structure.py

echo "🚀 Step 6: Starting SHS Backend Service..."
echo "------------------------------------------------"
./.venv/bin/python main.py
