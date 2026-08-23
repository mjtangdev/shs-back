from typing import List
from fastapi import WebSocket

class ConnectionManager:
    def __init__(self):
        # 存放活跃的 WebSocket 连接
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        """向所有连接的客户端推送消息"""
        import json
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception:
                # 自动清理断开的连接
                self.active_connections.remove(connection)

# 全局单例
manager = ConnectionManager()
