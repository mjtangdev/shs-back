# 使用 Python 3.12 稳定版
FROM python:3.12.7-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖（psycopg2 编译需要）
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件并安装
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制源码
COPY . .

# 暴露端口
EXPOSE 8000

# --- 关键修正：启动路径 ---
# 因为你的 main.py 在 app 文件夹里，所以是 app.main:app
# 加上 --proxy-headers 确保在使用 Nginx 转发时能获取正确 IP
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]