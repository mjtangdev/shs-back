# 使用 Python 3.12 稳定版
FROM python:3.12.7-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量，防止 Python 产生 .pyc 文件，并确保日志实时输出
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 安装系统依赖
# 既然你用了 psycopg2-binary，其实 gcc 已经不是必须的了
# 但保留它也不会出错，这里加上了 curl 方便你以后在容器内做健康检查
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 升级 pip 到最新（这一步对处理最新的 cryptography 和 bcrypt 很重要）
RUN pip install --no-cache-dir --upgrade pip

# 复制依赖文件并安装
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制源码
COPY . .

# 暴露端口
EXPOSE 8000

# 启动命令
# 保持你原来的路径配置，这是正确的
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]