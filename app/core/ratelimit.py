from slowapi import Limiter
from slowapi.util import get_remote_address

# 创建限流器实例
# 默认使用内存存储。如果是多进程部署（如 gunicorn 多 worker），建议后续改用 Redis。
limiter = Limiter(key_func=get_remote_address)
