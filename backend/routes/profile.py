# routes/profile.py
# 客户配置文件路由
import logging
import time

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from core.database import get_db
from core.security import get_current_user
from models.user import User

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
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前用户的详细客户配置文件。
    使用直接 SQL 进行性能优化和字段控制。
    """
    start_time = time.time()

    # 检查缓存
    if current_user.id in PROFILE_CACHE:
        ts, data = PROFILE_CACHE[current_user.id]
        if time.time() - ts < CACHE_TTL:
            data_copy = data.model_copy()
            data_copy.cached = True
            data_copy.query_time_ms = (time.time() - start_time) * 1000
            return data_copy

    try:
        # 1. 查询客户信息
        # 策略：先按邮箱匹配，再按姓名匹配
        # 优化：仅选择所需字段，使用 LIMIT 1
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

        result = await db.execute(customer_query, {"email": current_user.email, "username": current_user.username})
        customer = result.one_or_none()

        if not customer:
            # 降级处理：返回包装成配置文件的基础用户信息
            logger.warning(f"No customer found for user {current_user.username}")
            return CustomerProfile(
                id=0,
                name=current_user.username,
                email=current_user.email,
                code="GUEST",
                query_time_ms=(time.time() - start_time) * 1000
            )

        # 2. 查询最近6个月订单摘要（聚合）
        # 优化：使用索引列（customer_id/custom_seq, order_date）
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

        orders_result = await db.execute(orders_query, {"customer_id": customer.id})
        orders = [OrderSummary(order_month=row.order_month, total_quantity=int(row.total_quantity))
                  for row in orders_result.all()]

        # 3. 构造响应
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

        # 4. 更新缓存
        PROFILE_CACHE[current_user.id] = (time.time(), profile)

        return profile

    except Exception as e:
        logger.error(f"Error fetching profile for user {current_user.id}: {str(e)}", exc_info=True)
        # 降级处理：返回包装成配置文件的基础用户信息
        return CustomerProfile(
            id=0,
            name=current_user.username,
            email=current_user.email,
            code="ERROR",
            query_time_ms=(time.time() - start_time) * 1000
        )