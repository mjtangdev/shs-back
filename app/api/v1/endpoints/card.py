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
from app.schemas.card import CardCreate, CardResponse, CardList

router = APIRouter()

# --- 1. 统一查询接口 (支持分页、搜索、状态过滤) ---
@router.get("/", response_model=CardList)
def get_cards(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 50,
    search: Optional[str] = Query(None),
    status: Optional[int] = Query(None), # 0: Stock, 1: Active, 2: Blocked, 3: Damaged
    current_user: Any = Depends(get_current_user)
):
    query = db.query(Card).outerjoin(
        Customer, Card.customer_uuid == Customer.uuid
    ).options(
        joinedload(Card.customer).joinedload(Customer.region).joinedload(Region.parent)
    )

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
        if c.customer:
            cust_name = f"{c.customer.first_name} {c.customer.last_name}"
            if c.customer.region:
                if c.customer.region.level == 2 and c.customer.region.parent:
                    city, town = c.customer.region.parent.name, c.customer.region.name
                else:
                    city = c.customer.region.name

        items.append({
            "id": c.id, "card_number": c.card_number, "card_uuid": c.card_uuid,
            "status": c.status, "customer_uuid": c.customer_uuid or "-",
            "customer_name": cust_name, "city_name": city, "town_name": town,
            "created_at": c.created_at, "bound_at": c.bound_at
        })
    return {"total": total, "items": items}

# --- 2. 手动创建/入库 ---
@router.post("/create")
def create_card(db: Session = Depends(get_db), card_in: CardCreate = None, current_user: Any = Depends(get_finance_or_admin)):
    existing = db.query(Card).filter(or_(Card.card_number == card_in.card_number, Card.card_uuid == card_in.card_uuid)).first()
    if existing:
        raise HTTPException(status_code=400, detail="Physical Card Number or UUID already exists")
    
    new_card = Card(**card_in.dict(), status=0, created_at=datetime.now())
    db.add(new_card)
    db.commit()
    return {"status": "success", "id": new_card.id}

# --- 3. Excel 批量导入 (Import) ---
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
        n = str(row.get('card_number', '')).strip()
        u = str(row.get('card_uuid', '')).strip()
        
        if not n or not u or n in exist_nums or u in exist_uuids:
            skipped.append(f"Row {idx+2}: Duplicate or Empty ID")
            continue

        batch.append(Card(card_number=n, card_uuid=u, status=0, created_at=datetime.now()))
        exist_nums.add(n); exist_uuids.add(u)

    if batch:
        db.add_all(batch)
        db.commit()
    
    return {"status": "success", "imported": len(batch), "skipped": skipped}

# --- 4. Excel 资产导出 (Export) ---
@router.get("/export")
def export_cards(
    db: Session = Depends(get_db), 
    status: Optional[int] = None,
    current_user: Any = Depends(get_finance_or_admin)
):
    query = db.query(Card).outerjoin(Customer, Card.customer_uuid == Customer.uuid)
    if status is not None:
        query = query.filter(Card.status == status)
        
    cards = query.all()
    status_map = {0: "In Stock", 1: "Activated", 2: "Blocked", 3: "Damaged"}
    
    rows = []
    for c in cards:
        city, town, name = "-", "-", "-"
        if c.customer:
            name = f"{c.customer.first_name} {c.customer.last_name}"
            if c.customer.region:
                city = c.customer.region.parent.name if (c.customer.region.level==2 and c.customer.region.parent) else c.customer.region.name
                town = c.customer.region.name if c.customer.region.level==2 else "-"
        
        rows.append({
            "Card Number": c.card_number, "Card UUID": c.card_uuid,
            "Status": status_map.get(c.status, "Unknown"),
            "Customer": name, "City": city, "Town": town,
            "Created Date": c.created_at.strftime("%Y-%m-%d") if c.created_at else "-",
            "Bound Date": c.bound_at.strftime("%Y-%m-%d") if c.bound_at else "-"
        })

    df = pd.DataFrame(rows)
    out = io.BytesIO()
    with pd.ExcelWriter(out, engine='openpyxl') as w:
        df.to_excel(w, index=False)
    out.seek(0)
    
    return StreamingResponse(
        out, 
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename=Cards_Report_{datetime.now().strftime('%Y%m%d')}.xlsx"}
    )

# --- 5. 删除卡片 (Delete) ---
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