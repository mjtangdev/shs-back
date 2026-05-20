import uvicorn
import os

if __name__ == "__main__":
    # 获取端口，默认为 8000
    port = int(os.getenv("PORT", 8000))
    # 启动 uvicorn 服务，指向 app/main.py 中的 app 实例
    uvicorn.run("app.main:app", host="0.0.0.0", port=port, reload=True)
