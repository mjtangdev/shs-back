from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, Query, Body, BackgroundTasks
from sqlalchemy.orm import Session, joinedload
from datetime import datetime, timedelta, timezone
from typing import Any, List

from app.api import deps
from app.models.pos import POSMachine
from app.models.org import Region
from app.models.config import ProviderConfig
from app.models.pos_staging import POSStagingTransaction, POSStagingCustomer # 导入新的暂存模型
from app.models.users import User
from app.models.card import Card # 导入 Card 模型
from app.models.solar_device import SolarUnit # 导入 SolarUnit 模型
from app.models.customer import Customer
from app.models.transaction import TransactionLog
from app.schemas.pos import POSSyncResponse, POSSyncCustomerItem, POSSyncUploadRequest, POSSyncCardItem, POSSyncSolarUnitItem
from app.schemas.config import ProviderConfigRead
from snowflake import SnowflakeGenerator

router = APIRouter()

# 引入雪花算法生成器 (Worker ID=2 防止与 customer.py 冲突)
gen = SnowflakeGenerator(2)
def get_snowflake_id():
    return str(next(gen))

def _bind_assets(db: Session, customer_uuid: str, card_uuid: str = None, shs_id: str = None):
    """内部辅助函数：将卡片和设备绑定到客户并激活状态"""
    if card_uuid:
        card = db.query(Card).filter(Card.card_uuid == card_uuid).first()
        # 仅当资产未绑定或已绑定给该客户时执行（防止误绑定给他人）
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
    后台任务：处理暂存表数据。
    1. 将离线新客户同步至正式表并绑定资产。
    2. 处理交易流水，计算过期时间，累加充值统计，并补全资产绑定。
    """
    # 1. 先处理暂存客户（确保交易能找到客户对象）
    staged_custs = db.query(POSStagingCustomer).filter(POSStagingCustomer.processed_status == 0).all()
    for sc in staged_custs:
        try:
            # 幂等校验：兼容系统内已有的新旧ID
            existing_cust = db.query(Customer).filter(
                or_(Customer.uuid == sc.customer_uuid, Customer.offline_origin_uuid == sc.customer_uuid)
            ).first()
            
            if not existing_cust:
                # 核心：洗掉 POS 传上来的字母 UUID，后端重新生成统一的纯数字 ID
                new_real_uuid = get_snowflake_id()
                
                cust_data = {
                    "uuid": new_real_uuid, 
                    "offline_origin_uuid": sc.customer_uuid, # 保存 POS 的原始字母 ID 作为映射桥梁
                    "first_name": sc.first_name, "last_name": sc.last_name,
                    "gender": sc.gender, "mobile": sc.mobile, "email": sc.email,
                    "address": sc.address, "region_id": sc.region_id, "status": sc.status,
                    "total_recharged_days": 0, "total_recharged_amount": 0,
                    "created_at": sc.created_at # 使用 POS 端实际创建时间
                }
                if sc.birthday: cust_data["birthday"] = sc.birthday.date()
                new_customer = Customer(**cust_data)
                db.add(new_customer)
                db.flush() # 确保新客户ID生成，以便后续绑定

                # 处理新客户的资产绑定
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
            # 幂等校验：检查正式流水表是否已处理过此交易
            if db.query(TransactionLog).filter(TransactionLog.transaction_id == stx.transaction_id).first():
                stx.processed_status = 1
                continue

            # 查找真实的客户 (如果是之前白名单同步下去的，就是纯数字UUID；如果是离线新建刚传上来的，就通过 origin 映射)
            customer = db.query(Customer).filter(
                or_(Customer.uuid == stx.customer_uuid, Customer.offline_origin_uuid == stx.customer_uuid)
            ).first()

            if not customer:
                raise Exception("Customer not found for this transaction mapping.")

            real_customer_uuid = customer.uuid # 提取出后端洗白后的纯数字 ID

            if customer and stx.action_type == "RECHARGE":
                # 如果充值记录中带有资产 ID，尝试为现有客户执行绑定（处理离线补卡/换机场景）
                _bind_assets(db, real_customer_uuid, stx.card_uuid, stx.shs_machine_id)

                # --- 充值延期逻辑 ---
                days_to_add = Decimal(str(stx.days))
                # 累计充值统计
                customer.total_recharged_days = (customer.total_recharged_days or Decimal('0')) + days_to_add
                customer.total_recharged_amount = (customer.total_recharged_amount or Decimal('0')) + Decimal(str(stx.amount))

                # 基准时间：如果已过期则从交易时间算起，未过期则在原到期日累加
                tx_time_utc = stx.transaction_time.astimezone(timezone.utc) if stx.transaction_time.tzinfo else stx.transaction_time.replace(tzinfo=timezone.utc)

                if customer.expiry_date and customer.expiry_date > tx_time_utc:
                    # 未过期，在现有基础上累加
                    customer.expiry_date = customer.expiry_date + timedelta(days=float(days_to_add))
                else:
                    # 已过期或首次充值，从充值时间开始算
                    customer.expiry_date = tx_time_utc + timedelta(days=float(days_to_add))
                
                # 确保 expiry_date 也是带时区信息的
                customer.expiry_date = customer.expiry_date.replace(tzinfo=timezone.utc)

            # 写入正式流水
            db.add(TransactionLog(
                transaction_id=stx.transaction_id,
                customer_uuid=real_customer_uuid, # 强制将正式流水绑定在统一纯数字ID上
                card_uuid=stx.card_uuid,
                shs_machine_id=stx.shs_machine_id, # 保存设备的绑定溯源
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
    POS 业务数据同步 (增量上传)
    1. 接收离线新开客户信息
    2. 接收离线充值/交易流水 (后端据此计算财务)
    """
    # 1. 验证设备 (放宽限制：认人不认机，不再因 SN 码未录入或被删而拒绝上传)
    
    # 2. 快速暂存离线交易 (由后台任务异步处理)
    staged_tx_count = 0
    for tx in payload.transactions:
        # 检查该交易 ID 是否已存在于暂存表 (防止 POS 短时间内重复上传同一笔)
        # 后台任务处理时会再次检查 TransactionLog 表
        if db.query(POSStagingTransaction).filter(POSStagingTransaction.transaction_id == tx.transaction_id).first():
            continue # 暂存表幂等跳过

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
            operator_username=tx.operator_username, # 直接强制使用 POS 数据包中上传的操作员身份
            upload_time=datetime.utcnow(),
            processed_status=0 # 待处理
        )
        db.add(new_staging_tx)
        staged_tx_count += 1

    # 3. 快速暂存离线新开客户 (由后台任务异步处理)
    staged_cust_count = 0
    for cust in payload.new_customers:
        cust_uuid = cust.uuid
        if not cust_uuid: continue
        
        # 检查该客户 UUID 是否已存在于暂存表 (防止 POS 短时间内重复上传同一客户)
        # 后台任务处理时会再次检查 Customer 表
        if db.query(POSStagingCustomer).filter(POSStagingCustomer.customer_uuid == cust_uuid).first():
            continue # 暂存表幂等跳过

        # 验证并创建暂存客户对象
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
            operator_username=cust.operator_username, # 直接强制使用 POS 数据包中上传的操作员身份
            upload_time=datetime.utcnow(),
            processed_status=0 # 待处理
        )
        db.add(new_staging_cust)
        staged_cust_count += 1

    db.commit()
    
    # 启动后台处理
    background_tasks.add_task(process_pos_upload_task, db)
    
    return {
        "status": "success", 
        "staged_transactions": staged_tx_count,
        "staged_customers": staged_cust_count,
        "server_time": datetime.now()
    }


# --- 专供 POS 分批拉取接口 (支持游标分页与增量同步) ---

@router.get("/customers", response_model=List[POSSyncCustomerItem])
def sync_customers(
    since_id: int = Query(0, description="从哪个 ID 开始拉取"),
    limit: int = Query(100, le=500),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_operator_user)
):
    """
    分批读取客户表：
    1. 使用 since_id 进行游标分页，解决数据漂移问题。
    2. 自动根据业务员所属区域过滤客户。
    """
    query = db.query(Customer).filter(Customer.id > since_id)
    
    # 业务员只能看到自己区域的客户
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
    """分批读取卡片表"""
    return db.query(Card).filter(Card.id > since_id).order_by(Card.id.asc()).limit(limit).all()


@router.get("/solar-devices", response_model=List[POSSyncSolarUnitItem])
def sync_solar_devices(
    since_id: int = Query(0),
    limit: int = Query(100, le=500),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_operator_user)
):
    """分批读取设备表"""
    return db.query(SolarUnit).filter(SolarUnit.id > since_id).order_by(SolarUnit.id.asc()).limit(limit).all()
