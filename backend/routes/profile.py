# routes/profile.py
# 客户配置文件路由
import logging
import time

from fastapi import APIRouter, Depends, Header
from pydantic import BaseModel
from sqlalchemy import text, select
from sqlalchemy.ext.asyncio import AsyncSession

from core.database import get_db
from core.security import get_current_user
from core.db_adapter import AdapterFactory
from models.user import User
from models.db_connection import DbConnection
from utils.engine_cache import EngineCache

router = APIRouter(prefix="/profile", tags=["profile"])
logger = logging.getLogger(__name__)

# 简单的内存缓存，带过期时间
# 键：user_id，值：(时间戳, 数据)
PROFILE_CACHE = {}
CACHE_TTL = 300  # 5 minutes

class OrderSummary(BaseModel):
    order_month: str
    total_quantity: int

class CustomerProfile(BaseModel):
    id: int
    name: str
    code: str | None = None
    email: str | None = None
    contact_person: str | None = None
    phone: str | None = None
    address: str | None = None

    # 扩展属性
    business_state: str | None = None
    payment_type: str | None = None

    # 关联数据
    recent_orders: list[OrderSummary] = []

    # 元数据
    cached: bool = False
    query_time_ms: float = 0

@router.get("", response_model=CustomerProfile)
async def get_user_profile(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    x_connection_id: int | None = Header(None, description="可选的目标数据库连接ID")
):
    """
    获取当前用户的详细客户配置文件。
    从目标业务数据库中查询客户信息，如果未提供连接或出错则优雅降级。
    """
    start_time = time.time()

    # 检查缓存
    cache_key = f"{current_user.id}_{x_connection_id}"
    if cache_key in PROFILE_CACHE:
        ts, data = PROFILE_CACHE[cache_key]
        if time.time() - ts < CACHE_TTL:
            data_copy = data.model_copy()
            data_copy.cached = True
            data_copy.query_time_ms = (time.time() - start_time) * 1000
            return data_copy

    # 默认兜底的基础用户信息
    base_profile = CustomerProfile(
        id=0,
        name=current_user.username,
        email=current_user.email,
        code="GUEST",
        query_time_ms=0
    )

    if not x_connection_id:
        base_profile.query_time_ms = (time.time() - start_time) * 1000
        return base_profile

    try:
        # 获取目标业务库的配置
        stmt = select(DbConnection).where(
            DbConnection.id == x_connection_id,
            DbConnection.user_id == current_user.id
        )
        result = await db.execute(stmt)
        db_conn_config = result.scalar_one_or_none()

        if not db_conn_config:
            base_profile.query_time_ms = (time.time() - start_time) * 1000
            return base_profile

        # 获取目标业务库的引擎
        adapter = AdapterFactory.get_adapter(db_conn_config.type)
        target_db_engine, engine_cache_key = await EngineCache.acquire(db_conn_config, adapter)

        try:
            # 建立一个直接连接业务库的 session
            async with AsyncSession(target_db_engine) as target_db:
                # 1. 查询客户信息
                customer_query = text("""
                    SELECT
                        id, name, code, email,
                        legal_person as contact_person,
                        company_phone as phone,
                        concat(ifnull(province_address,''), ifnull(city_address,''), ifnull(detail_address,'')) as address,
                        business_state, payment_type
                    FROM bas_custom
                    WHERE (email = :email AND email IS NOT NULL AND email != '')
                       OR (name = :username)
                    LIMIT 1
                """)

                result = await target_db.execute(customer_query, {"email": current_user.email, "username": current_user.username})
                customer = result.one_or_none()

                if not customer:
                    base_profile.query_time_ms = (time.time() - start_time) * 1000
                    return base_profile

                # 2. 查询最近6个月订单摘要（聚合）
                orders_query = text("""
                    SELECT
                        DATE_FORMAT(o.order_date, '%Y-%m') as order_month,
                        COALESCE(SUM(oda.total_number), 0) as total_quantity
                    FROM od_order_doc o
                    JOIN od_order_doc_article oda ON o.seq = oda.od_order_doc_seq
                    WHERE o.custom_seq = :customer_id
                      AND o.is_deleted = 0
                      AND oda.is_deleted = 0
                      AND o.order_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
                    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
                    ORDER BY order_month DESC
                    LIMIT 6
                """)

                orders_result = await target_db.execute(orders_query, {"customer_id": customer.id})
                orders = [OrderSummary(order_month=row.order_month, total_quantity=int(row.total_quantity))
                          for row in orders_result.all()]

                # 3. 构造完整响应
                profile = CustomerProfile(
                    id=customer.id,
                    name=customer.name,
                    code=customer.code,
                    email=customer.email,
                    contact_person=customer.contact_person,
                    phone=customer.phone,
                    address=customer.address,
                    business_state=customer.business_state,
                    payment_type=customer.payment_type,
                    recent_orders=orders,
                    cached=False,
                    query_time_ms=(time.time() - start_time) * 1000
                )

                # 更新缓存
                PROFILE_CACHE[cache_key] = (time.time(), profile)
                return profile
        finally:
            # 必须释放引擎缓存计数
            await EngineCache.release(engine_cache_key)

    except Exception as e:
        logger.error(f"获取用户 {current_user.id} 的目标数据库配置文件时出错：{str(e)}")
        # 降级处理：出错时返回基础用户信息
        base_profile.code = "ERROR"
        base_profile.query_time_ms = (time.time() - start_time) * 1000
        return base_profile
