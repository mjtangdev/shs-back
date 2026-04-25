from fastapi import APIRouter

# 创建一个路由器 
router = APIRouter()

@router.get("/world")
def say_hello():
    return {"message": "Hello World from Router!"}