#!/bin/bash

# 1. 确保在项目根目录
cd "$(dirname "$0")" || exit

echo "🚀 Starting SHS Backend Development Environment..."

# 2. 检查虚拟环境
if [ ! -d ".venv" ]; then
    echo "❌ Virtual environment .venv not found."
    echo "Please run: python -m venv .venv && ./.venv/bin/pip install -r requirements.txt"
    exit 1
fi

# 3. 启动后端服务 (默认使用 8000 端口，允许局域网设备全网访问)
PORT="${1:-8000}"
echo "🔥 Running FastAPI server on Port ${PORT}..."
PORT="${PORT}" ./.venv/bin/python main.py
