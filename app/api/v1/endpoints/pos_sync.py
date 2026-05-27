from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, Query, Body, BackgroundTasks
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_
from datetime import datetime, timedelta, timezone
from typing import Any, List

from app.api import deps
from app.db.session import SessionLocal
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

from sqlalchemy import or_, func

# ... (rest of imports)

def _bind_assets(db: Session, customer_uuid: str, card_uuid: str = None, shs_id: str = None, installed_at: datetime = None) -> bool:
    """内部辅助函数：将卡片和设备绑定到客户并激活状态。返回是否至少有一项成功绑定。"""
    success = False
    
    # 获取客户对象以更新安装时间
    customer = db.query(Customer).filter(Customer.uuid == customer_uuid).first()
    if not customer:
        print(f"⚠️ [BIND] Customer {customer_uuid} not found. Cannot bind assets.")
        return False

    if card_uuid:
        u_card_id = card_uuid.lower() # 统一转小写进行匹配
        # 严格比对：忽略数据库中的大小写差异
        card = db.query(Card).filter(
            or_(
                func.lower(Card.card_uuid) == u_card_id, 
                func.lower(Card.card_number) == u_card_id
            )
        ).first()
        
        if card:
            # --- 换卡逻辑优化：如果客户已有绑定的旧卡，且不是这张新卡，则将旧卡标记为损坏 ---
            db.query(Card).filter(
                Card.customer_uuid == customer_uuid,
                Card.id != card.id
            ).update({
                "status": 3, # Damaged
                "customer_uuid": None,
                "updated_at": datetime.now()
            })

            if card.customer_uuid is None or card.customer_uuid == customer_uuid:
                card.customer_uuid = customer_uuid
                card.status = 1  # Activated
                card.bound_at = datetime.now()
                # 顺便统一存为大写，方便后续展示
                card.card_uuid = card.card_uuid.upper()
                success = True
        else:
            print(f"⚠️ [BIND] Card {u_card_id} not found in DB.")
    
    if shs_id:
        solar_unit = db.query(SolarUnit).filter(SolarUnit.shs_machine_id == shs_id).first()
        if solar_unit:
            if solar_unit.customer_uuid is None or solar_unit.customer_uuid == customer_uuid:
                solar_unit.customer_uuid = customer_uuid
                solar_unit.shs_status = 1  # Active
                solar_unit.bound_at = datetime.now()
                success = True
        else:
            print(f"⚠️ [BIND] Device {shs_id} not found in DB.")

    # 如果绑定成功，且客户尚未设置安装时间，则记录安装时间
    if success and not customer.installed_at:
        customer.installed_at = installed_at or datetime.now()
    
    return success

def process_pos_upload_task():
    """
    后台处理逻辑：
    1. 优先处理新客户，并执行即时资产绑定
    2. 处理交易流水
    """
    db = SessionLocal()
    try:
        # 1. 处理新开户人员资料
        staged_custs = db.query(POSStagingCustomer).filter(POSStagingCustomer.processed_status == 0).all()
        for sc in staged_custs:
            try:
                # 保护逻辑：如果数据库已有该 UUID
                existing_cust = db.query(Customer).filter(
                    or_(Customer.uuid == sc.customer_uuid, Customer.offline_origin_uuid == sc.customer_uuid)
                ).first()
                
                customer_uuid_for_tx = sc.customer_uuid

                if not existing_cust:
                    new_real_uuid = get_snowflake_id()
                    customer_uuid_for_tx = new_real_uuid
                    cust_data = {
                        "uuid": new_real_uuid,
                        "offline_origin_uuid": sc.customer_uuid,
                        "first_name": sc.first_name, "last_name": sc.last_name,
                        "gender": sc.gender, "mobile": sc.mobile, "email": sc.email,
                        "address": sc.address, "region_id": sc.region_id, "status": sc.status,
                        "beneficiary_count": sc.beneficiary_count,
                        "representative_name": sc.representative_name,
                        "rep_relationship": sc.rep_relationship,
                        "total_recharged_days": 0, "total_recharged_amount": 0,
                        "created_at": sc.created_at or datetime.now()
                    }
                    if sc.birthday: cust_data["birthday"] = sc.birthday.date()
                    new_customer = Customer(**cust_data)
                    db.add(new_customer)
                    db.flush()

                    # --- 关键修复：离线开户时自带的资产立即执行绑定 ---
                    if sc.card_uuid or sc.shs_machine_id:
                        _bind_assets(db, new_real_uuid, sc.card_uuid, sc.shs_machine_id, sc.created_at)

                sc.processed_status = 1
            except Exception as e:
                print(f"❌ [SYNC] Error processing staging customer {sc.customer_uuid}: {e}")
                sc.processed_status = 2
                sc.processing_error = str(e)
        db.flush()

        # 2. 处理暂存交易
        staged_txs = db.query(POSStagingTransaction).filter(POSStagingTransaction.processed_status == 0).all()
        for stx in staged_txs:
            try:
                # 幂等校验
                if db.query(TransactionLog).filter(TransactionLog.transaction_id == stx.transaction_id).first():
                    stx.processed_status = 1
                    continue

                customer = db.query(Customer).filter(
                    or_(Customer.uuid == stx.customer_uuid, Customer.offline_origin_uuid == stx.customer_uuid)
                ).first()

                if not customer:
                    raise Exception(f"Target customer {stx.customer_uuid} not found for transaction mapping.")

                real_customer_uuid = customer.uuid

                # 核心逻辑：只有充值成功才累加
                if stx.action_type == "RECHARGE":
                    days_to_add = Decimal(str(stx.days))
                    customer.total_recharged_days = (customer.total_recharged_days or Decimal('0')) + days_to_add
                    customer.total_recharged_amount = (customer.total_recharged_amount or Decimal('0')) + Decimal(str(stx.amount))

                    # 统一使用本地时间进行比较
                    tx_time = stx.transaction_time

                    current_expiry = customer.expiry_time
                    if current_expiry:
                        if current_expiry > tx_time:
                            customer.expiry_time = current_expiry + timedelta(days=float(days_to_add))
                        else:
                            customer.expiry_time = tx_time + timedelta(days=float(days_to_add))
                    else:
                        customer.expiry_time = tx_time + timedelta(days=float(days_to_add))

                    # 更新活跃时间
                    customer.updated_at = datetime.now()

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
                print(f"❌ [SYNC] Error processing staging transaction {stx.transaction_id}: {e}")
                stx.processed_status = 2
                stx.processing_error = str(e)
        db.commit()
    except Exception as e:
        print(f"❌ [SYNC] Critical error in background task: {e}")
        db.rollback()
    finally:
        db.close()

@router.post("/upload")
def upload_offline_data(
    payload: POSSyncUploadRequest,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    POS 极端同步接口：接收业务分类后的三桶数据
    """
    operator_name = current_user.username
    
    # A. 先保存新开户档案到暂存区
    staged_cust_count = 0
    for cust in payload.new_registrations:
        if db.query(POSStagingCustomer).filter(POSStagingCustomer.customer_uuid == cust.uuid).first():
            continue
        new_staging_cust = POSStagingCustomer(
            customer_uuid=cust.uuid,
            first_name=cust.first_name, last_name=cust.last_name,
            card_uuid=cust.card_uuid.upper() if cust.card_uuid else None,
            shs_machine_id=cust.shs_machine_id,
            gender=cust.gender, mobile=cust.mobile, email=cust.email,
            birthday=cust.birthday, address=cust.address, region_id=cust.region_id,
            beneficiary_count=cust.beneficiary_count,
            representative_name=cust.representative_name, rep_relationship=cust.rep_relationship,
            status=1, pos_sn=payload.pos_sn or "UNKNOWN",
            operator_username=cust.operator_username or operator_name,
            upload_time=datetime.now(),
            created_at=cust.created_at, # 记录录入时间
            processed_status=0
        )
        db.add(new_staging_cust)
        staged_cust_count += 1
    db.flush()

    # B. 处理安装与绑定关系 (立即生效)
    installed_count = 0
    for install in payload.asset_installations:
        # 执行资产绑定，并记录安装时间 (installed_at)
        if _bind_assets(db, install.customer_uuid, install.card_uuid.upper() if install.card_uuid else None, install.shs_machine_id, install.installed_at):
            installed_count += 1
    db.flush()

    # C. 保存交易流水到暂存区
    staged_tx_count = 0
    for tx in payload.transactions:
        if db.query(POSStagingTransaction).filter(POSStagingTransaction.transaction_id == tx.transaction_id).first():
            continue
        new_staging_tx = POSStagingTransaction(
            transaction_id=tx.transaction_id,
            customer_uuid=tx.customer_uuid,
            card_uuid=tx.card_uuid.upper() if tx.card_uuid else "",
            days=tx.days, shs_machine_id=tx.shs_machine_id,
            amount=tx.amount, transaction_time=tx.transaction_time,
            action_type=tx.action_type, pos_sn=payload.pos_sn or "UNKNOWN",
            operator_username=tx.operator_username or operator_name,
            upload_time=datetime.now(),
            processed_status=0
        )
        db.add(new_staging_tx)
        staged_tx_count += 1

    db.commit()

    # --- 核心改进：同步执行后台任务 ---
    # 不再使用 background_tasks，而是直接在返回前完成“暂存区”到“正式表”的转换
    # 这样可以确保 POS 紧接着拉取客户列表时，数据已经是最新计算过的
    process_pos_upload_task()
    
    return {
        "status": "success", 
        "staged_registrations": staged_cust_count,
        "installed_assets": installed_count,
        "staged_transactions": staged_tx_count,
        "server_time": datetime.now()
    }

@router.get("/customers", response_model=List[POSSyncCustomerItem])
def sync_customers(
    since_id: int = Query(0),
    limit: int = Query(100, le=500),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """POS 增量同步客户：支持管理员全量、业务员区域递归"""
    query = db.query(Customer).options(
        joinedload(Customer.cards),
        joinedload(Customer.solar_units),
        joinedload(Customer.region)
    ).filter(Customer.id > since_id)
    
    # 业务员隔离逻辑：递归查找下属所有区域的客户
    if current_user.role == 2 and current_user.region_id:
        allowed_ids = [current_user.region_id]
        # 查找一级子区域
        children = db.query(Region.id).filter(Region.parent_id == current_user.region_id).all()
        if children:
            child_ids = [c[0] for c in children]
            allowed_ids.extend(child_ids)
            # 查找二级子区域
            sub_children = db.query(Region.id).filter(Region.parent_id.in_(child_ids)).all()
            allowed_ids.extend([sc[0] for sc in sub_children])
        
        query = query.filter(Customer.region_id.in_(allowed_ids))
    elif current_user.role == 2 and not current_user.region_id:
        return [] # 未分配区域的业务员同步不到任何数据

    return query.order_by(Customer.id.asc()).limit(limit).all()

@router.get("/cards", response_model=List[POSSyncCardItem])
def sync_cards(
    since_id: int = Query(0),
    limit: int = Query(100, le=500),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    # 仅同步：在库(0) 或 已激活(1) 的卡片。过滤掉锁定(2)或损坏(3)的卡片
    return db.query(Card).filter(
        Card.id > since_id,
        Card.status.in_([0, 1]) 
    ).order_by(Card.id.asc()).limit(limit).all()

@router.get("/solar-devices", response_model=List[POSSyncSolarUnitItem])
def sync_solar_devices(
    since_id: int = Query(0),
    limit: int = Query(100, le=500),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    return db.query(SolarUnit).filter(SolarUnit.id > since_id).order_by(SolarUnit.id.asc()).limit(limit).all()
