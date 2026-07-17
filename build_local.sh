#!/bin/bash

# SHS Backend 本地镜像构建脚本 (使用国内加速镜像)
# ---------------------------------------------------------
IMAGE_NAME="mjtangdev/shs-backend:latest"

echo "🚀 开始构建 Docker 镜像 (已配置国内加速源)..."
echo "📍 目标平台: linux/amd64"

# 执行本地构建
echo "🔨 正在编译..."

# 使用标准构建命令
docker build --platform linux/amd64 -t $IMAGE_NAME .

if [ $? -eq 0 ]; then
    echo "---------------------------------------------------------"
    echo "✅ 镜像构建完成！"
    echo "📦 你现在可以在 Docker Desktop 的 'Images' 列表中看到它了。"
    echo ""
    echo "🚀 上传到 Docker Hub："
    echo "   1. 开启 VPN。"
    echo "   2. 运行: docker push $IMAGE_NAME"
    echo "   或者在 Docker Desktop 界面点击 'Push to Hub'。"
else
    echo "❌ 构建失败。"
    echo "💡 提示：如果依然失败，请检查是否能正常访问国内镜像 (如阿里云、清华源)。"
    exit 1
fi

echo "---------------------------------------------------------"
echo "🎉 任务已结束！"
