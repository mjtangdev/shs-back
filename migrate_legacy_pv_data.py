"""
旧版本 PV 数据一键无损迁移脚本 (migrate_legacy_pv_data.py)
--------------------------------------------------------------------------------
功能说明：
  针对老版本系统的数据库数据，将原来存在 solar_units 表中的旧字段 solar_equipment_id 
  提取并清洗，自动无损迁移至新的 solar_pv_panels 独立物理表中。
  自动继承老数据的绑定客户、绑定主机、激活状态 (status) 和出厂日期。
"""
import logging
from datetime import datetime, timedelta
from app.db.session import SessionLocal, engine
from app.models.solar_device import SolarUnit, SolarPVPanel
from app.models.customer import Customer

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("pv_migration")

def migrate_legacy_pv_data():
    logger.info("🚀 开始执行旧版 PV 数据无损迁移至 solar_pv_panels 物理独立表...")
    db = SessionLocal()
    try:
        # 1. 查询所有带有有效 solar_equipment_id 的旧主机记录
        legacy_units = db.query(SolarUnit).filter(
            SolarUnit.solar_equipment_id.isnot(None),
            SolarUnit.solar_equipment_id != "",
            SolarUnit.solar_equipment_id != "-"
        ).all()

        logger.info(f"📊 扫描到 {len(legacy_units)} 条历史设备数据，开始提取 PV 光伏板记录...")

        migrated_count = 0
        skipped_count = 0

        for unit in legacy_units:
            pv_sn = unit.solar_equipment_id.strip()
            
            # 防重校验：如果 solar_pv_panels 表中已存在该 pv_sn，跳过
            existing = db.query(SolarPVPanel).filter(SolarPVPanel.pv_sn == pv_sn).first()
            if existing:
                skipped_count += 1
                continue

            # 查关联客户信息（补全客户姓名）
            cust_name = None
            if unit.customer_uuid:
                cust = db.query(Customer).filter(Customer.uuid == unit.customer_uuid).first()
                if cust:
                    cust_name = f"{cust.first_name} {cust.last_name}"

            # 确定 PV 板状态：若主机已绑定激活 (shs_status==1) 且有客户，标记为 1 (已激活)，否则标记为 0 (在库)
            is_active = (unit.shs_status == 1 and unit.customer_uuid is not None)
            pv_status = 1 if is_active else 0

            # 插入新物理表记录
            new_pv = SolarPVPanel(
                pv_sn=pv_sn,
                status=pv_status,
                shs_machine_id=unit.shs_machine_id if is_active else None,
                customer_uuid=unit.customer_uuid if is_active else None,
                customer_name=cust_name if is_active else None,
                production_date=unit.production_date or (datetime.now() - timedelta(days=15)),
                created_at=unit.created_at or datetime.now(),
                bound_at=unit.bound_at if is_active else None,
                updated_at=unit.updated_at or datetime.now()
            )
            db.add(new_pv)
            migrated_count += 1

        db.commit()
        logger.info(f"🎉 迁移成功！新建 PV 独立记录: {migrated_count} 条，已存在跳过: {skipped_count} 条。")
        return True, f"成功迁移 {migrated_count} 条，跳过 {skipped_count} 条"
    except Exception as e:
        db.rollback()
        logger.error(f"❌ 迁移失败: {e}")
        return False, str(e)
    finally:
        db.close()

if __name__ == "__main__":
    migrate_legacy_pv_data()
