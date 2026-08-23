import asyncio
import json
from datetime import datetime
from typing import List, Any

class SSEManager:
    def __init__(self):
        # 存放所有活跃的客户端队列
        self.subscribers: List[asyncio.Queue] = []

    async def subscribe(self) -> asyncio.Queue:
        """创建一个新的消息队列供客户端订阅"""
        queue = asyncio.Queue()
        self.subscribers.append(queue)
        return queue

    def unsubscribe(self, queue: asyncio.Queue):
        """当连接断开时移除队列"""
        if queue in self.subscribers:
            self.subscribers.remove(queue)

    async def broadcast(self, event_type: str, data: Any):
        """向所有订阅者广播消息"""
        message = {
            "event": event_type,
            "data": data,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        # 构造 SSE 协议格式的数据
        sse_data = f"data: {json.dumps(message)}\n\n"
        
        # 并发向所有订阅者推送
        for queue in self.subscribers:
            try:
                await queue.put(sse_data)
            except Exception:
                # 容错：如果某个队列失效，不影响其他
                pass

    async def get_heartbeat(self):
        """每隔 20 秒产生一个心跳注释，防止代理服务器断开长连接"""
        while True:
            await asyncio.sleep(20)
            yield ": ping\n\n"

# 全局单例
sse_manager = SSEManager()
