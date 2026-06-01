#!/bin/bash

# SHS Backend 多平台镜像构建与推送脚本
# ---------------------------------------------------------
IMAGE_NAME="mjtangdev/shs-backend:latest"

echo "🚀 开始构建多平台 Docker 镜像: $IMAGE_NAME"
echo "📍 目标平台: linux/amd64 (云服务器), linux/arm64 (苹果芯片/树莓派)"

# 1. 检查 buildx 是否可用
if ! docker buildx ls | grep -q "multi-platform"; then
    echo "🔧 正在初始化 Docker Buildx 多平台构建器..."
    docker buildx create --name mybuilder --use
    docker buildx inspect --bootstrap
fi

# 2. 执行核心构建并推送
echo "🔨 正在编译并推送镜像 (这可能需要几分钟，取决于网络)..."
docker buildx build --platform linux/amd64,linux/arm64 -t $IMAGE_NAME --push .

if [ $? -eq 0 ]; then
    echo "✅ 镜像已成功推送至 Docker Hub!"
    echo "🔗 镜像地址: https://hub.docker.com/r/mjtangdev/shs-backend"
else
    echo "❌ 构建或推送失败，请检查网络连接或 Docker 登录状态。"
    exit 1
fi

echo "---------------------------------------------------------"
echo "🎉 所有任务已完成！"
