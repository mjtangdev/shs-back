from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, Query, Body
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, func
from datetime import datetime, timedelta
from typing import Any, List

from app.api import deps
from app.models.pos import POSMachine
from app.models.org import Region
from app.models.config import ProviderConfig
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer
from app.models.users import User
from app.models.card import Card
from app.models.solar_device import SolarUnit
from app.models.customer import Customer
from app.models.transaction import TransactionLog
from app.schemas.pos import POSSyncResponse, POSSyncUploadRequest
from snowflake import SnowflakeGenerator

router = APIRouter()
gen = SnowflakeGenerator(2)

def get_snowflake_id():
    return str(next(gen))

def _bind_assets_sync(db: Session, customer_uuid: str, card_uuid: str = None, shs_id: str = None, installed_at: datetime = None):
    """同步执行资产绑定逻辑：自动解绑旧资产，绑定新资产"""
    customer = db.query(Customer).filter(Customer.uuid == customer_uuid).first()
    if not customer: return False

    success = False
    if card_uuid:
        u_card_id = card_uuid.upper()
        # 1. 解绑并作废旧卡 (如果存在且不同)
        db.query(Card).filter(Card.customer_uuid == customer_uuid, Card.card_uuid != u_card_id).update({
            "status": 3, "customer_uuid": None, "updated_at": datetime.now()
        })
        # 2. 绑定新卡
        card = db.query(Card).filter(Card.card_uuid == u_card_id).first()
        if not card:
            card = Card(card_uuid=u_card_id, status=1, customer_uuid=customer_uuid, bound_at=datetime.now())
            db.add(card)
        else:
            card.customer_uuid, card.status, card.bound_at = customer_uuid, 1, datetime.now()
        success = True
    
    if shs_id:
        # 1. 释放旧设备
        db.query(SolarUnit).filter(SolarUnit.customer_uuid == customer_uuid, SolarUnit.shs_machine_id != shs_id).update({
            "shs_status": 0, "customer_uuid": None, "updated_at": datetime.now()
        })
        # 2. 占用新设备
        unit = db.query(SolarUnit).filter(SolarUnit.shs_machine_id == shs_id).first()
        if unit:
            unit.customer_uuid, unit.shs_status, unit.bound_at = customer_uuid, 1, datetime.now()
            success = True

    if success and not customer.installed_at:
        customer.installed_at = installed_at or datetime.now()
    return success

@router.post("/upload")
def upload_offline_data(
    payload: POSSyncUploadRequest,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    POS 离线同步接口 (同步实时处理版)：
    确保 upload 成功返回后，数据已进入正式表，后续 bootstrap 可立即拉取最新状态。
    """
    print(f"📥 Received sync from POS: {payload.pos_sn}")
    
    # 1. 处理新注册 (New Registrations)
    new_cust_count = 0
    for rc in payload.new_registrations:
        if db.query(Customer).filter(or_(Customer.uuid == rc.uuid, Customer.offline_origin_uuid == rc.uuid)).first():
            continue
        
        real_uuid = get_snowflake_id()
        new_cust = Customer(
            uuid=real_uuid, offline_origin_uuid=rc.uuid,
            first_name=rc.first_name, last_name=rc.last_name,
            gender=rc.gender, mobile=rc.mobile, email=rc.email,
            address=rc.address, region_id=rc.region_id, status=1,
            beneficiary_count=rc.beneficiary_count, representative_name=rc.representative_name,
            created_at=rc.created_at or datetime.now()
        )
        db.add(new_cust)
        db.flush()
        # 立即处理开户自带的资产绑定
        if rc.card_uuid or rc.shs_machine_id:
            _bind_assets_sync(db, real_uuid, rc.card_uuid, rc.shs_machine_id, rc.created_at)
        new_cust_count += 1

    # 2. 处理资产变更 (Asset Installations)
    install_count = 0
    for inst in payload.asset_installations:
        # 兼容性查找：POS 可能传的是 offline_uuid
        target_cust = db.query(Customer).filter(or_(Customer.uuid == inst.customer_uuid, Customer.offline_origin_uuid == inst.customer_uuid)).first()
        if target_cust:
            if _bind_assets_sync(db, target_cust.uuid, inst.card_uuid, inst.shs_machine_id, inst.installed_at):
                install_count += 1
    
    # 3. 处理交易流水 (Transactions)
    tx_count = 0
    for tx in payload.transactions:
        if db.query(TransactionLog).filter(TransactionLog.transaction_id == tx.transaction_id).first():
            continue
        
        target_cust = db.query(Customer).filter(or_(Customer.uuid == tx.customer_uuid, Customer.offline_origin_uuid == tx.customer_uuid)).with_for_update().first()
        if not target_cust: continue

        # 更新有效期
        days_to_add = Decimal(str(tx.days))
        tx_time = tx.transaction_time
        if target_cust.expiry_time and target_cust.expiry_time > tx_time:
            target_cust.expiry_time += timedelta(days=float(days_to_add))
        else:
            target_cust.expiry_time = tx_time + timedelta(days=float(days_to_add))
        
        target_cust.total_recharged_days = (target_cust.total_recharged_days or 0) + days_to_add
        target_cust.total_recharged_amount = (target_cust.total_recharged_amount or 0) + Decimal(str(tx.amount))

        db.add(TransactionLog(
            transaction_id=tx.transaction_id, customer_uuid=target_cust.uuid,
            card_uuid=tx.card_uuid.upper() if tx.card_uuid else None,
            shs_machine_id=tx.shs_machine_id, days=tx.days, amount=tx.amount,
            transaction_time=tx.transaction_time, action_type=tx.action_type,
            pos_sn=payload.pos_sn, operator_username=tx.operator_username
        ))
        tx_count += 1

    db.commit()
    print(f"✅ Sync done: {new_cust_count} regs, {install_count} assets, {tx_count} txs.")
    
    # 额外反馈：获取当前 POS 的实时锁定状态
    pos_status = db.query(POSMachine).filter(POSMachine.pos_sn == payload.pos_sn).first()
    
    return {
        "status": "success", 
        "new_customers": new_cust_count, 
        "transactions": tx_count,
        "is_locked": pos_status.lock_status != 0 if pos_status else False,
        "server_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

@router.get("/bootstrap", response_model=POSSyncResponse)
def pos_bootstrap_sync(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    POS 一键启动同步接口：
    由于 upload 已经同步处理，此接口返回的数据保证是最新最准的。
    """
    if current_user.role != 2:
        raise HTTPException(status_code=403, detail="Only operators can bootstrap sync")

    allowed_ids = [current_user.region_id]
    children = db.query(Region.id).filter(Region.parent_id == current_user.region_id).all()
    if children:
        child_ids = [c[0] for c in children]; allowed_ids.extend(child_ids)
        sub_children = db.query(Region.id).filter(Region.parent_id.in_(child_ids)).all()
        allowed_ids.extend([sc[0] for sc in sub_children])

    customers_raw = db.query(Customer).options(joinedload(Customer.cards), joinedload(Customer.solar_units), joinedload(Customer.region))\
                      .filter(Customer.region_id.in_(allowed_ids), Customer.status == 1).all()

    customers_data = []
    bound_card_uuids = []
    bound_shs_ids = []
    for c in customers_raw:
        c_card = c.cards[0].card_uuid if c.cards else None
        c_shs = c.solar_units[0].shs_machine_id if c.solar_units else None
        if c_card: bound_card_uuids.append(c_card)
        if c_shs: bound_shs_ids.append(c_shs)
        
        customers_data.append({
            "id": c.id, "uuid": c.uuid, "first_name": c.first_name, "last_name": c.last_name,
            "card_uuid": c_card or "", "shs_machine_id": c_shs or "", "status": c.status,
            "total_recharged_days": float(c.total_recharged_days or 0),
            "expiry_time": c.expiry_time, "region_name": c.region.name if c.region else "Unknown",
            "created_at": c.created_at,
            "updated_at": c.updated_at
        })

    # 避免空列表产生 SQLAlchemy Warning
    card_filters = [Card.status == 0]
    if bound_card_uuids:
        card_filters.append(Card.card_uuid.in_(bound_card_uuids))
    full_cards = db.query(Card).filter(or_(*card_filters)).limit(1000).all()

    unit_filters = [SolarUnit.shs_status == 0]
    if bound_shs_ids:
        unit_filters.append(SolarUnit.shs_machine_id.in_(bound_shs_ids))
    full_units = db.query(SolarUnit).filter(or_(*unit_filters)).limit(1000).all()

    # 4. 获取这些客户最近的流水记录 (最近 1000 条作为参考池)
    customer_uuids = [c["uuid"] for c in customers_data]
    recent_transactions = []
    if customer_uuids:
        recent_transactions = db.query(TransactionLog)\
            .filter(TransactionLog.customer_uuid.in_(customer_uuids))\
            .order_by(TransactionLog.transaction_time.desc())\
            .limit(1000).all()

    config = db.query(ProviderConfig).first()
    region = db.query(Region).filter(Region.id == current_user.region_id).first()

    return {
        "server_time": datetime.now(), "provider": config, "daily_rate": region.daily_rate if region else 7.0,
        "region_name": region.name if region else "Unknown", "is_locked": False,
        "customers": customers_data, 
        "cards": full_cards, 
        "solar_units": full_units,
        "transactions": recent_transactions
    }
