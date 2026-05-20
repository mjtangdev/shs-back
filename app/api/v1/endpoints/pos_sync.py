from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, Query, Body, BackgroundTasks
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_
from datetime import datetime, timedelta, timezone
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
from app.schemas.pos import POSSyncResponse, POSSyncCustomerItem, POSSyncUploadRequest, POSSyncCardItem, POSSyncSolarUnitItem
from app.schemas.config import ProviderConfigRead
from snowflake import SnowflakeGenerator

router = APIRouter()

# 引入雪花算法生成器
gen = SnowflakeGenerator(2)
def get_snowflake_id():
    return str(next(gen))

def _bind_assets(db: Session, customer_uuid: str, card_uuid: str = None, shs_id: str = None):
    """内部辅助函数：将卡片和设备绑定到客户并激活状态"""
    if card_uuid:
        # 同时匹配物理 UID 和协议 ID (card_number)
        card = db.query(Card).filter(or_(Card.card_uuid == card_uuid, Card.card_number == card_uuid)).first()
        if card and (card.customer_uuid is None or card.customer_uuid == customer_uuid):
            card.customer_uuid = customer_uuid
            card.status = 1  # Activated
            card.bound_at = datetime.now(timezone.utc)
    
    if shs_id:
        solar_unit = db.query(SolarUnit).filter(SolarUnit.shs_machine_id == shs_id).first()
        if solar_unit and (solar_unit.customer_uuid is None or solar_unit.customer_uuid == customer_uuid):
            solar_unit.customer_uuid = customer_uuid
            solar_unit.shs_status = 1  # Active
            solar_unit.bound_at = datetime.now(timezone.utc)

def process_pos_upload_task(db: Session):
    """
    极速同步策略后端处理逻辑：
    1. 优先处理新客户，将其洗白为正式 UUID 并保留原始映射。
    2. 处理交易流水：
        - 幂等校验。
        - 仅当 status 为 "SUCCESS" 时更新资产绑定和财务统计。
        - 自动累加充值天数和金额。
    """
    # 1. 先处理暂存客户
    staged_custs = db.query(POSStagingCustomer).filter(POSStagingCustomer.processed_status == 0).all()
    for sc in staged_custs:
        try:
            existing_cust = db.query(Customer).filter(
                or_(Customer.uuid == sc.customer_uuid, Customer.offline_origin_uuid == sc.customer_uuid)
            ).first()
            
            if not existing_cust:
                new_real_uuid = get_snowflake_id()
                cust_data = {
                    "uuid": new_real_uuid, 
                    "offline_origin_uuid": sc.customer_uuid,
                    "first_name": sc.first_name, "last_name": sc.last_name,
                    "gender": sc.gender, "mobile": sc.mobile, "email": sc.email,
                    "address": sc.address, "region_id": sc.region_id, "status": sc.status,
                    "total_recharged_days": 0, "total_recharged_amount": 0,
                    "created_at": sc.created_at
                }
                if sc.birthday: cust_data["birthday"] = sc.birthday.date()
                new_customer = Customer(**cust_data)
                db.add(new_customer)
                db.flush()
                _bind_assets(db, new_real_uuid, sc.card_uuid, sc.shs_machine_id)
            
            sc.processed_status = 1
        except Exception as e:
            sc.processed_status = 2
            sc.processing_error = str(e)
    db.flush()

    # 2. 处理暂存交易
    staged_txs = db.query(POSStagingTransaction).filter(POSStagingTransaction.processed_status == 0).all()
    for stx in staged_txs:
        try:
            if db.query(TransactionLog).filter(TransactionLog.transaction_id == stx.transaction_id).first():
                stx.processed_status = 1
                continue

            customer = db.query(Customer).filter(
                or_(Customer.uuid == stx.customer_uuid, Customer.offline_origin_uuid == stx.customer_uuid)
            ).first()

            if not customer:
                raise Exception("Target customer not found for transaction mapping.")

            real_customer_uuid = customer.uuid

            # 核心逻辑：只有 POS 标记为 SUCCESS 的流水才触发生命周期变更
            # 注意：POS 的 status 字段由 POSStagingTransaction 映射，如果原模型没存 status，需检查
            # 假设 POSStagingTransaction 已根据我们的需求增加了字段，或通过 action_type 区分

            # 如果充值成功，更新余额和绑定
            if stx.action_type == "RECHARGE":
                _bind_assets(db, real_customer_uuid, stx.card_uuid, stx.shs_machine_id)

                days_to_add = Decimal(str(stx.days))
                customer.total_recharged_days = (customer.total_recharged_days or Decimal('0')) + days_to_add
                customer.total_recharged_amount = (customer.total_recharged_amount or Decimal('0')) + Decimal(str(stx.amount))

                tx_time_utc = stx.transaction_time.astimezone(timezone.utc) if stx.transaction_time.tzinfo else stx.transaction_time.replace(tzinfo=timezone.utc)
                if customer.expiry_date and customer.expiry_date > tx_time_utc:
                    customer.expiry_date = customer.expiry_date + timedelta(days=float(days_to_add))
                else:
                    customer.expiry_date = tx_time_utc + timedelta(days=float(days_to_add))
                customer.expiry_date = customer.expiry_date.replace(tzinfo=timezone.utc)

            # 写入正式流水
            db.add(TransactionLog(
                transaction_id=stx.transaction_id,
                customer_uuid=real_customer_uuid,
                card_uuid=stx.card_uuid or "",
                shs_machine_id=stx.shs_machine_id,
                days=stx.days,
                amount=stx.amount,
                transaction_time=stx.transaction_time,
                action_type=stx.action_type,
                pos_sn=stx.pos_sn,
                operator_username=stx.operator_username
            ))
            stx.processed_status = 1
        except Exception as e:
            stx.processed_status = 2
            stx.processing_error = str(e)
    db.commit()

@router.post("/upload")
def upload_offline_data(
    payload: POSSyncUploadRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(deps.get_db),
    current_operator: User = Depends(deps.get_current_operator_user)
):
    """
    POS 极端同步接口：接收离线上传的所有业务动作
    """
    # 处理交易流水
    staged_tx_count = 0
    for tx in payload.transactions:
        # 增加过滤：如果 POS 明确标记为 FAILED 的流水，后端仅记录，不参与充值逻辑
        # 这里在暂存层先原样保存
        if db.query(POSStagingTransaction).filter(POSStagingTransaction.transaction_id == tx.transaction_id).first():
            continue

        new_staging_tx = POSStagingTransaction(
            transaction_id=tx.transaction_id,
            customer_uuid=tx.customer_uuid,
            card_uuid=tx.card_uuid,
            days=tx.days,
            shs_machine_id=tx.shs_machine_id,
            amount=tx.amount,
            transaction_time=tx.transaction_time,
            action_type=tx.action_type,
            pos_sn=payload.pos_sn or "UNKNOWN",
            operator_username=tx.operator_username,
            upload_time=datetime.utcnow(),
            processed_status=0
        )
        db.add(new_staging_tx)
        staged_tx_count += 1

    # 处理新开客户
    staged_cust_count = 0
    for cust in payload.new_customers:
        if db.query(POSStagingCustomer).filter(POSStagingCustomer.customer_uuid == cust.uuid).first():
            continue

        new_staging_cust = POSStagingCustomer(
            customer_uuid=cust.uuid,
            first_name=cust.first_name,
            last_name=cust.last_name,
            card_uuid=cust.card_uuid,
            shs_machine_id=cust.shs_machine_id,
            gender=cust.gender,
            mobile=cust.mobile,
            email=cust.email,
            birthday=cust.birthday,
            address=cust.address,
            region_id=cust.region_id,
            status=1,
            pos_sn=payload.pos_sn or "UNKNOWN",
            operator_username=cust.operator_username,
            upload_time=datetime.utcnow(),
            processed_status=0
        )
        db.add(new_staging_cust)
        staged_cust_count += 1

    db.commit()
    background_tasks.add_task(process_pos_upload_task, db)
    
    return {
        "status": "success", 
        "staged_transactions": staged_tx_count,
        "staged_customers": staged_cust_count,
        "server_time": datetime.now()
    }

@router.get("/customers", response_model=List[POSSyncCustomerItem])
def sync_customers(
    since_id: int = Query(0),
    limit: int = Query(100, le=500),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_operator_user)
):
    query = db.query(Customer).filter(Customer.id > since_id)
    if current_user.role == 2:
        query = query.filter(Customer.region_id == current_user.region_id)
    return query.order_by(Customer.id.asc()).limit(limit).all()

@router.get("/cards", response_model=List[POSSyncCardItem])
def sync_cards(
    since_id: int = Query(0),
    limit: int = Query(100, le=500),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_operator_user)
):
    return db.query(Card).filter(Card.id > since_id).order_by(Card.id.asc()).limit(limit).all()

@router.get("/solar-devices", response_model=List[POSSyncSolarUnitItem])
def sync_solar_devices(
    since_id: int = Query(0),
    limit: int = Query(100, le=500),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_operator_user)
):
    return db.query(SolarUnit).filter(SolarUnit.id > since_id).order_by(SolarUnit.id.asc()).limit(limit).all()
