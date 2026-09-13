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

# 3. 启动后端服务 (默认使用 8008 端口，避开 8000 冲突；也可以传入参数自定义端口，如: ./start_dev.sh 8080)
PORT="${1:-8008}"
echo "🔥 Running FastAPI server on Port ${PORT}..."
PORT="${PORT}" ./.venv/bin/python main.py
