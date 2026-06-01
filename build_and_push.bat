@echo off
set IMAGE_NAME=mjtangdev/shs-backend:latest

echo =========================================================
echo  SHS Backend 多平台镜像构建 (Windows 版)
echo =========================================================

echo 🚀 开始构建并推送镜像: %IMAGE_NAME%
echo 📍 目标平台: linux/amd64, linux/arm64

:: 1. 检查并启用 Buildx
docker buildx inspect mybuilder >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo 🔧 正在初始化 Docker Buildx 构建器...
    docker buildx create --name mybuilder --use
    docker buildx inspect --bootstrap
)

:: 2. 执行构建与推送
echo 🔨 正在执行多平台构建并推送 (请确保已执行 docker login)...
docker buildx build --platform linux/amd64,linux/arm64 -t %IMAGE_NAME% --push .

if %ERRORLEVEL% eq 0 (
    echo.
    echo ✅ 镜像已成功推送至 Docker Hub!
) else (
    echo.
    echo ❌ 构建失败! 请检查 Docker Desktop 是否启动，以及是否已登录。
    pause
)

echo =========================================================
echo 🎉 构建任务完成!
pause
