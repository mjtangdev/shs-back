import uvicorn
import os

if __name__ == "__main__":
    # 获取端口，默认为 8000
    port = int(os.getenv("PORT", 8000))
    # 启动 uvicorn 服务，监听 0.0.0.0 以同时允许本地前端与局域网 POS 机通过 IP 访问
    uvicorn.run("app.main:app", host="0.0.0.0", port=port, reload=True)
