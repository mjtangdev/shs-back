import io
import pandas as pd
from datetime import datetime
from typing import Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_

from app.api.deps import get_db, get_current_user, get_finance_or_admin
from app.models.card import Card
from app.models.customer import Customer
from app.models.org import Region
from app.schemas.card import CardCreate, CardResponse, CardList, CardUpdate

router = APIRouter()

# --- 1. 统一查询接口 (支持分页、搜索、状态过滤) ---
@router.get("/", response_model=CardList)
def get_cards(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 50,
    region_id: Optional[int] = Query(None),
    search: Optional[str] = Query(None),
    status: Optional[int] = Query(None), # 0: Stock, 1: Active, 2: Blocked, 3: Damaged
    current_user: Any = Depends(get_current_user)
):
    query = db.query(Card).outerjoin(
        Customer, Card.customer_uuid == Customer.uuid
    ).options(
        joinedload(Card.customer).joinedload(Customer.region).joinedload(Region.parent)
    )
    
    # 确定过滤的基础 region_id
    filter_region_id = region_id
    if current_user.role == 2:
        filter_region_id = current_user.region_id

    if filter_region_id is not None:
        # 递归获取子区域 ID
        allowed_ids = [filter_region_id]
        children = db.query(Region.id).filter(Region.parent_id == filter_region_id).all()
        if children:
            c_ids = [c[0] for c in children]
            allowed_ids.extend(c_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(c_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
        
        # 业务员隔离逻辑：可以看在库(0)或自己区域的
        if current_user.role == 2:
            query = query.filter(or_(Card.status == 0, Customer.region_id.in_(allowed_ids)))
        else:
            query = query.filter(Customer.region_id.in_(allowed_ids))

    if status is not None:
        query = query.filter(Card.status == status)

    if search:
        sf = f"%{search}%"
        query = query.filter(or_(Card.card_number.ilike(sf), Card.card_uuid.ilike(sf)))

    total = query.count()
    cards = query.order_by(Card.updated_at.desc()).offset(skip).limit(limit).all()

    items = []
    for c in cards:
        city, town, cust_name = "-", "-", "-"
        cust_id = None
        if c.customer:
            cust_id = c.customer.id
            cust_name = f"{c.customer.first_name} {c.customer.last_name}"
            if c.customer.region:
                reg = c.customer.region
                if reg.level == 2:
                    town = reg.name
                    city = reg.parent.name if reg.parent else "-"
                else:
                    city = reg.name

        items.append({
            "id": c.id, "card_number": c.card_number, "card_uuid": c.card_uuid,
            "status": c.status, "customer_id": cust_id, "customer_uuid": c.customer_uuid or "-",
            "customer_name": cust_name, "city_name": city, "town_name": town,
            "created_at": c.created_at, "bound_at": c.bound_at
        })
    return {"total": total, "items": items}

# --- 2. 手动创建/入库 ---
@router.post("/create")
def create_card(db: Session = Depends(get_db), card_in: CardCreate = None, current_user: Any = Depends(get_finance_or_admin)):
    # Enforce uppercase for UUID
    card_in.card_uuid = card_in.card_uuid.strip().upper()
    existing = db.query(Card).filter(or_(Card.card_number == card_in.card_number, Card.card_uuid == card_in.card_uuid)).first()
    if existing:
        raise HTTPException(status_code=400, detail="Physical Card Number or UUID already exists")
    
    new_card = Card(**card_in.dict(), status=0, created_at=datetime.now())
    db.add(new_card)
    db.commit()
    return {"status": "success", "id": new_card.id}

# --- 3. Excel 批量导入 (Import) ---
@router.get("/import-template")
def get_card_import_template(current_user: Any = Depends(get_finance_or_admin)):
    """获取 IC 卡导入 Excel 模板"""
    df = pd.DataFrame(columns=["card_number", "card_uuid"])
    # 示例数据
    df.loc[0] = ["00880001", "A1B2C3D4"]
    
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Sheet1')
    
    output.seek(0)
    return StreamingResponse(
        output,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": "attachment; filename=iccard_import_template.xlsx"}
    )

@router.post("/import")
async def import_cards(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
):
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="Invalid Excel file")

    contents = await file.read()
    df = pd.read_excel(io.BytesIO(contents), dtype=str)
    df = df.where(pd.notnull(df), None)
    df.columns = [str(c).strip().lower().replace(" ", "_") for c in df.columns]

    exist_nums = {c[0] for c in db.query(Card.card_number).all()}
    exist_uuids = {c[0] for c in db.query(Card.card_uuid).all()}
    
    batch, skipped = [], []
    for idx, row in df.iterrows():
        n = str(row.get('card_number', '')).strip() if row.get('card_number') else None
        u = str(row.get('card_uuid', '')).strip().upper() # Enforce Uppercase
        
        # 只要有 UUID 就可以放行入库
        if not u or u in exist_uuids:
            skipped.append(f"Row {idx+2}: Duplicate or Empty UUID")
            continue
        
        # 只有在提供了卡号且卡号重复时才跳过
        if n and n in exist_nums:
            skipped.append(f"Row {idx+2}: Duplicate Card Number")
            continue

        batch.append(Card(card_number=n, card_uuid=u, status=0, created_at=datetime.now()))
        if n: exist_nums.add(n)
        exist_uuids.add(u)

    if batch:
        db.add_all(batch)
        db.commit()
    
    return {"status": "success", "imported": len(batch), "skipped": skipped}

# --- 4. Excel 资产导出 (Export) ---
@router.get("/export")
def export_cards(
    db: Session = Depends(get_db), 
    status: Optional[int] = None,
    region_id: Optional[int] = Query(None),
    current_user: Any = Depends(get_finance_or_admin)
):
    query = db.query(Card).outerjoin(Customer, Card.customer_uuid == Customer.uuid).options(
        joinedload(Card.customer).joinedload(Customer.region).joinedload(Region.parent).joinedload(Region.parent)
    )
    if status is not None:
        query = query.filter(Card.status == status)

    if region_id:
        allowed_ids = [region_id]
        children = db.query(Region.id).filter(Region.parent_id == region_id).all()
        if children:
            c_ids = [c[0] for c in children]
            allowed_ids.extend(c_ids)
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(c_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
        
        # Filter cards bound to customers in these regions
        query = query.filter(Customer.region_id.in_(allowed_ids))
        
    cards = query.all()
    status_map = {0: "In Stock", 1: "Activated", 2: "Blocked", 3: "Damaged"}
    
    rows = []
    for c in cards:
        municipality, barangay, purok, name = "-", "-", "-", "-"
        if c.customer:
            name = f"{c.customer.first_name} {c.customer.last_name}"
            if c.customer.region:
                reg = c.customer.region
                if reg.level == 2:
                    purok = reg.name
                    if reg.parent:
                        barangay = reg.parent.name
                        if reg.parent.parent:
                            municipality = reg.parent.parent.name
                elif reg.level == 1:
                    barangay = reg.name
                    if reg.parent:
                        municipality = reg.parent.name
                elif reg.level == 0:
                    municipality = reg.name
        
        rows.append({
            "Card Number": c.card_number, "Card UUID": c.card_uuid,
            "Status": status_map.get(c.status, "Unknown"),
            "Full Name": name, 
            "Municipality": municipality,
            "Barangay": barangay, 
            "Purok": purok,
            "LATITUDE": "-", 
            "LONGITUDE": "-",
            "IAS": "-",
            "DATE INSTALLED": c.bound_at.strftime("%Y-%m-%d") if c.bound_at else "-",
            "IR REPORT NO.": "-",
            "REMARKS": "-",
            "CREATED DATE": c.created_at.strftime("%Y-%m-%d %H:%M") if c.created_at else "-",
            "LAST UPDATED": c.updated_at.strftime("%Y-%m-%d %H:%M") if c.updated_at else "-"
        })

    df = pd.DataFrame(rows)
    
    # 直接导出为 Excel (.xlsx) 格式
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='IC-Cards')
    
    output.seek(0)
    filename = f"shs-iccard_{datetime.now().strftime('%Y%m%d')}.xlsx"
    return StreamingResponse(
        output, 
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

# --- 5. 更新卡片 (Update) ---
@router.put("/{card_id}")
def update_card(
    card_id: int,
    card_in: CardUpdate,
    db: Session = Depends(get_db),
    current_user: Any = Depends(get_finance_or_admin)
):
    card = db.query(Card).filter(Card.id == card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")

    # 只允许更新 card_number
    if card_in.card_number is not None:
        # 检查卡号冲突
        if card_in.card_number != card.card_number:
            existing = db.query(Card).filter(Card.card_number == card_in.card_number).first()
            if existing:
                raise HTTPException(status_code=400, detail="Physical Card Number already exists")
        card.card_number = card_in.card_number

    card.updated_at = datetime.now()
    db.add(card)
    db.commit()
    db.refresh(card)
    return {"status": "success", "id": card.id}

# --- 6. 删除卡片 (Delete) ---
@router.delete("/{card_id}")
def delete_card(card_id: int, db: Session = Depends(get_db), current_user: Any = Depends(get_finance_or_admin)):
    card = db.query(Card).filter(Card.id == card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    # 业务保护逻辑：已经绑定的卡片(Status=1)不允许直接删除，必须先解绑或标注为损毁
    if card.status == 1:
        raise HTTPException(status_code=400, detail="Cannot delete an active card. Please unbind it first.")
    
    db.delete(card)
    db.commit()
    return {"status": "success", "message": f"Card {card.card_number} deleted"}

@router.post("/{card_id}/reset")
def reset_card_to_stock(
    card_id: int, 
    db: Session = Depends(get_db), 
    current_user: Any = Depends(get_finance_or_admin)
):
    card = db.query(Card).filter(Card.id == card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    # 执行“洗白”逻辑
    card.status = 0
    card.customer_uuid = None
    card.bound_at = None
    # 可以在这里记录一下更新时间，表示该卡片被回收重置了
    card.updated_at = datetime.now()
    
    db.commit()
    return {"status": "success", "message": f"Card {card.card_number} has been reset to stock."}