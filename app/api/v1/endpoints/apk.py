from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from fastapi.responses import FileResponse
from pathlib import Path
import shutil
import logging

from app.api import deps

logger = logging.getLogger(__name__)

# 定义APK文件的存储路径
BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent
APK_UPLOAD_DIR = BASE_DIR / "static" / "apk"

# 确保APK存储目录存在
APK_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# 去掉 prefix="/apk" 以解决 URL 中出现重复 /apk/apk/ 的问题
router = APIRouter(tags=["APK Management"])

# --- 内部辅助函数 ---

def _save_apk(file: UploadFile, filename: str):
    if not file.filename.endswith(".apk"):
        raise HTTPException(status_code=400, detail="只允许上传 .apk 格式的文件")
    try:
        file_path = APK_UPLOAD_DIR / filename
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return True
    except Exception as e:
        logger.error(f"Save APK Error: {e}")
        raise HTTPException(status_code=500, detail=f"文件保存失败: {str(e)}")

def _get_apk_response(filename: str):
    file_path = APK_UPLOAD_DIR / filename
    if not file_path.is_file():
        raise HTTPException(status_code=404, detail=f"未找到文件: {filename}")
    return FileResponse(
        path=file_path, 
        media_type="application/vnd.android.package-archive",
        filename=filename
    )

# --- 1. 上传接口 (Upload) ---

@router.post("/new")
def upload_new_apk(
    file: UploadFile = File(...),
    current_user=Depends(deps.get_current_admin_user)
):
    """上传新版 POS APK (new.apk)"""
    _save_apk(file, "new.apk")
    return {"status": "success", "message": "新版 APK 已更新", "filename": "new.apk"}

@router.post("/old")
def upload_old_apk(
    file: UploadFile = File(...),
    current_user=Depends(deps.get_current_admin_user)
):
    """上传旧版 POS APK (old.apk)"""
    _save_apk(file, "old.apk")
    return {"status": "success", "message": "旧版 APK 已更新", "filename": "old.apk"}

# --- 2. 下载接口 (Download) ---

@router.get("/new")
def download_new_apk():
    """下载新版 POS APK"""
    return _get_apk_response("new.apk")

@router.get("/old")
def download_old_apk():
    """下载旧版 POS APK"""
    return _get_apk_response("old.apk")
