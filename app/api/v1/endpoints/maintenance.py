import json
import zipfile
import io
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, BackgroundTasks, Form
from sqlalchemy.orm import Session

from app.api import deps
from app.models.users import User
from app.core.restore import perform_db_restore
from app.core.backup import perform_db_backup
from app.core.legacy_migration import run_legacy_sql_migration
from app.core.auth_utils import verify_password

router = APIRouter()

@router.post("/migrate-from-legacy-zip")
async def migrate_from_legacy_zip(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    password: str = Form(..., description="Administrator password for authorization"),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    """
    【危险/异步执行】上传 ZIP 并在后台进行全量迁移。
    需要输入管理员密码进行二次确认。
    """
    if current_user.role not in [0, 1]:
        raise HTTPException(status_code=403, detail="Permission denied")

    # 二次验证：校验提供的密码是否正确 (校验当前登录管理员的密码)
    if not verify_password(password, current_user.password_hash):
        raise HTTPException(status_code=401, detail="Authorization failed: Incorrect password")

    if not file.filename.endswith(".zip"):
        raise HTTPException(status_code=400, detail="Please upload a .zip file")

    files_dict = {}
    try:
        content = await file.read()
        with zipfile.ZipFile(io.BytesIO(content)) as z:
            for zip_info in z.infolist():
                if zip_info.is_dir(): continue
                filename = zip_info.filename.split('/')[-1]
                if filename.endswith(".sql"):
                    with z.open(zip_info) as f:
                        raw_content = f.read()
                        try:
                            files_dict[filename] = raw_content.decode("utf-8")
                        except UnicodeDecodeError:
                            files_dict[filename] = raw_content.decode("latin-1")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to parse ZIP file: {str(e)}")

    if not files_dict:
        raise HTTPException(status_code=400, detail="No .sql files found in the ZIP archive")

    # 立即排入后台队列
    background_tasks.add_task(run_legacy_sql_migration, files_dict)

    return {
        "status": "success",
        "message": "Migration started in background. Please wait ~1 min and check logs/dashboard."
    }

@router.post("/restore-from-json")
async def restore_db_from_json(
    file: UploadFile = File(...),
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    """
    【危险操作】从上传的 JSON 文件一键恢复/覆盖数据库。
    允许 Role 0 (Super Admin) 或 Role 1 (Admin) 执行。
    """
    if current_user.role not in [0, 1]:
        raise HTTPException(status_code=403, detail="Permission denied")

    try:
        content = await file.read()
        json_data = json.loads(content)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid JSON file: {str(e)}")

    success, message = perform_db_restore(json_content=json_data)
    if not success:
        raise HTTPException(status_code=500, detail=f"Restore failed: {message}")

    return {"status": "success", "message": "Database restored and synced successfully"}

@router.post("/export-to-json")
def export_db_to_json(
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    """
    手动触发全量数据导出到 production_data.json。
    """
    if current_user.role not in [0, 1]:
        raise HTTPException(status_code=403, detail="Permission denied")

    perform_db_backup()
    return {"status": "success", "message": "Backup generated successfully in production_data.json"}
