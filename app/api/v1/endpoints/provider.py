import os
import shutil
from pathlib import Path
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile, Form, Response
from datetime import datetime # <-- 添加这一行
from sqlalchemy.orm import Session
from app.api import deps
from app.models.config import ProviderConfig
from app.schemas.config import ProviderConfigRead, ProviderConfigUpdate
from sqlalchemy.exc import IntegrityError

router = APIRouter()

# 定义上传目录。假设项目根目录下有 'static' 文件夹
# 确保 UPLOAD_DIR 是绝对路径，并且指向项目根目录下的 static/uploads/logos
# Path(__file__).resolve().parent 是 app/api/v1/endpoints
# .parent.parent.parent.parent 是项目根目录 (shs-backend)
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent.parent
UPLOAD_DIR = PROJECT_ROOT / "static" / "uploads" / "logos"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)  # 确保目录存在

@router.get("/", response_model=ProviderConfigRead)
def get_provider_config(
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_user)
):
    """获取总公司/供应商配置信息"""
    config = db.query(ProviderConfig).order_by(ProviderConfig.id.asc()).first()
    if not config:
        # 如果走到这里，说明初始化逻辑可能失败了，这是一个内部服务器错误
        raise HTTPException(status_code=500, detail="Provider configuration not found, but should have been initialized.")
        
    return config

@router.patch("/", response_model=ProviderConfigRead)
async def update_provider_config( # 修改为 async 函数以处理文件 I/O
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_admin_user),
    # 使用 Form 来接收非文件字段，这些字段都是可选的
    name: Optional[str] = Form(None),
    tin: Optional[str] = Form(None),
    phone: Optional[str] = Form(None),
    email: Optional[str] = Form(None),
    address: Optional[str] = Form(None),
    logo: Optional[UploadFile] = File(None), # 接收上传的文件
):
    """
    更新总公司配置（支持上传 Logo 文件）。
    仅限 Role 1 (管理员) 操作。
    """
    # 显式按 ID 排序，确保 PATCH 和 GET 操作的是同一条记录
    config = db.query(ProviderConfig).order_by(ProviderConfig.id.asc()).first()
    if not config:
        # 如果走到这里，说明初始化逻辑可能失败了，这是一个内部服务器错误
        raise HTTPException(status_code=500, detail="Provider configuration not found, but should have been initialized.")
    
    # 调试日志：查看后端实际收到的字段值
    print(f"DEBUG: Received PATCH request - name: {name}, tin: {tin}, phone: {phone}")

    # 构建更新数据字典，只包含非None的值
    update_data = {}
    
    # 简化判断逻辑：只要传了值（即使是空字符串，如果业务允许）就更新
    if name is not None: update_data["name"] = name.strip()
    if tin is not None: update_data["tin"] = tin.strip()
    if phone is not None: update_data["phone"] = phone.strip()
    if email is not None: update_data["email"] = email.strip()
    if address is not None: update_data["address"] = address.strip()

    # 处理文件上传
    if logo and logo.filename:
        # 简单的文件类型和大小检查
        ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}
        ext = logo.filename.split(".")[-1].lower()
        if ext not in ALLOWED_EXTENSIONS:
            raise HTTPException(status_code=400, detail=f"Invalid file type. Only {', '.join(ALLOWED_EXTENSIONS)} are allowed.")
        
        # 固定文件名以实现“覆盖”逻辑，不再使用时间戳
        filename = f"logo.{ext}"
        file_path = UPLOAD_DIR / filename

        # 清理旧的 logo 文件（防止不同后缀的文件残留，如旧的是 .jpg，新的是 .png）
        for old_file in UPLOAD_DIR.glob("logo.*"):
            old_file.unlink(missing_ok=True)

        with file_path.open("wb") as buffer:
            shutil.copyfileobj(logo.file, buffer) # 使用 shutil 写入文件
        
        # 将保存后的文件路径存储到数据库中
        # 这里的 URL 路径需要与 main.py 中 app.mount 的配置相匹配
        # 添加时间戳参数 (?t=...) 强制触发前端浏览器刷新缓存
        timestamp = int(datetime.now().timestamp())
        update_data["logo_url"] = f"/static/{filename}?t={timestamp}"

    # 始终执行更新操作，因为 config 保证存在
    try:
        for field, value in update_data.items():
            setattr(config, field, value)
            
        # 只要 update_data 不为空，或者上传了新 logo，就认为已经完成了初始化
        if update_data:
            config.is_initialized = True

        db.commit()
        db.refresh(config) # 强制刷新对象状态

    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Update failed: TIN already exists.")
    except Exception as e:
        db.rollback()
        print(f"DEBUG: ProviderConfig update failed with unexpected error: {e}") # 打印详细错误信息
        raise HTTPException(status_code=400, detail=f"Update failed: {str(e)}")
    
    return config