from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from fastapi.responses import FileResponse
from pathlib import Path
import shutil

from app.api import deps

# 定义APK文件的存储路径
# 理想情况下，这些路径应该通过配置文件或环境变量来管理。
# 这里假设项目根目录是当前文件向上四级。
BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent
APK_UPLOAD_DIR = BASE_DIR / "static" / "apk"
APK_FILE_NAME = "latest.apk" # 上传的APK文件统一命名为latest.apk

# 确保APK存储目录存在
APK_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# 创建一个用于APK相关路由的APIRouter
# 设置prefix为"/apk"，这样所有此router下的路由都会自动带上"/apk"前缀
# 例如，上传接口将是 /apk/upload，下载接口将是 /apk/download
router = APIRouter(prefix="/apk", tags=["APK Management"])

# --- APK 文件管理 ---

@router.post("/upload")
def upload_apk(
    file: UploadFile = File(...),
    current_user=Depends(deps.get_current_admin_user)
):
    """
    上传APK文件。
    仅限管理员访问。新的APK文件会替换旧文件。
    
    Args:
        file: 要上传的APK文件。
        current_user: 当前认证的用户，必须是管理员。
    
    Returns:
        包含上传成功消息的字典。
    
    Raises:
        HTTPException: 如果文件不是.apk格式或上传失败。
    """
    if not file.filename.endswith(".apk"):
        raise HTTPException(status_code=400, detail="只允许上传 .apk 格式的文件")

    try:
        file_path = APK_UPLOAD_DIR / APK_FILE_NAME
        # 使用 with open 和 shutil.copyfileobj 以流式方式保存文件，对大文件更高效
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        return {"message": f"APK文件 '{file.filename}' 已成功上传并替换为 '{APK_FILE_NAME}'。"}
    except Exception as e:
        # 捕获可能的写入错误或文件系统错误
        raise HTTPException(status_code=500, detail=f"上传APK文件失败: {str(e)}")

@router.get("/download")
def download_apk():
    """
    下载最新的APK文件。
    任何人都可以访问。
    """
    file_path = APK_UPLOAD_DIR / APK_FILE_NAME
    
    # 检查文件是否存在
    if not file_path.is_file():
        raise HTTPException(status_code=404, detail="目前没有可供下载的APK文件。")
    
    # 使用 FileResponse 返回文件，FastAPI 会处理文件流和HTTP头
    return FileResponse(
        path=file_path, 
        media_type="application/vnd.android.package-archive", # 标准的APK文件MIME类型
        filename=APK_FILE_NAME # 客户端下载时显示的文件名
    )