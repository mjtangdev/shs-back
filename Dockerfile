# --- 第一阶段：构建环境 ---
FROM python:3.12.7-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 安装编译依赖 (针对不同架构自动适配)
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# 构建 Wheel 包，包含所有依赖项（移除 --no-deps 以确保包含 sqlalchemy 等所需的 greenlet）
RUN pip install --no-cache-dir --upgrade pip && \
    pip wheel --no-cache-dir --wheel-dir /app/wheels -r requirements.txt


# --- 第二阶段：运行环境 ---
FROM python:3.12.7-slim

WORKDIR /app

# 只安装运行时的基础库
RUN apt-get update && apt-get install -y \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制编译好的依赖
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt

# 复制源码
COPY . .

EXPOSE 8000

# 使用 uvicorn 启动
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
