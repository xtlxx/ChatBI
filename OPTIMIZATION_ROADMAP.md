# ChatBI 性能与准确度优化实施方案

**目标**: 解决管理层最关心的"回答速度"和"准确度"问题  
**时间线**: 2-3周  
**优先级**: P0 (最高)

---

## 🎯 优化目标

| 指标 | 当前 | 目标 | 优化幅度 |
|------|------|------|----------|
| **简单查询响应时间** | 5-8秒 | 3-5秒 | ⬇️ 40% |
| **复杂查询响应时间** | 15-30秒 | 8-12秒 | ⬇️ 60% |
| **基础查询准确率** | 85% | 95%+ | ⬆️ 10% |
| **复杂查询准确率** | 70% | 85%+ | ⬆️ 15% |
| **并发支持** | 未测试 | 20 QPS | 新增 |

---

## 📊 优化策略清单

### Strategy 1: Prompt 工程优化 ⚡ (最快见效)
**预期提升**: 准确率 +8%, 速度 +25%  
**工作量**: 2-3天  
**优先级**: P0

#### 当前问题分析
从 `backend/agent/prompts.py` 分析得知:
```python
# 当前Prompt过于冗长,包含大量示例
system_prompt = """
You are an expert SQL analyst...
[大量通用说明和示例]
"""
```

#### 优化方案
1. **精简Prompt结构**
```python
# 新的Prompt分层设计
CORE_INSTRUCTION = """你是SQL专家,严格遵循4步流程:
1. 分析schema → 2. 规划查询 → 3. 执行SQL → 4. 生成报告"""

SCHEMA_GUIDE = """<仅在需要时动态注入的schema详细说明>"""

FEW_SHOT_EXAMPLES = """<根据查询类型选择2-3个最相关示例>"""
```

2. **动态示例选择**
```python
# backend/agent/prompts.py 新增
def get_relevant_examples(query: str, top_k: 3):
    """
    根据用户查询,从示例库检索最相关的Few-Shot示例
    使用Voyage AI嵌入模型进行语义匹配
    """
    query_embedding = voyage_client.embed([query])
    similar_examples = vector_store.similarity_search(
        query_embedding, k=top_k
    )
    return similar_examples
```

**预期效果**:
- Token使用量减少 30-40% → 成本降低 + 速度提升
- 示例精准度提升 → 准确率提升

---

### Strategy 2: Schema 语义增强 🎯 (准确度核心)
**预期提升**: 准确率 +12%  
**工作量**: 3-5天  
**优先级**: P0

#### 当前问题
```sql
-- 数据库原始Schema
CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL
);
```

LLM 无法理解:
- `amount` 是含税还是不含税?
- `order_date` 是下单时间还是发货时间?
- 订单状态如何判断?

#### 解决方案: 业务语义注释
```python
# backend/agent/tools.py 新增
ENHANCED_SCHEMA = {
    "orders": {
        "table_description": "订单主表,记录所有销售订单",
        "columns": {
            "order_id": "订单唯一ID,主键",
            "customer_id": "客户ID,关联customers表",
            "order_date": "订单创建时间(非发货时间)",
            "amount": "订单总金额(含税),单位:元",
            "status": "订单状态: 1=待付款, 2=已付款, 3=已发货, 4=已完成, 5=已取消"
        },
        "common_queries": [
            "本月销售额: SELECT SUM(amount) FROM orders WHERE order_date >= DATE_FORMAT(NOW(), '%Y-%m-01')",
            "待处理订单: SELECT * FROM orders WHERE status IN (1,2)"
        ]
    }
}
```

#### 实施步骤
1. **创建Schema注解文件** (`backend/schemas/business_metadata.json`)
2. **更新工具函数**
```python
# backend/agent/tools.py
@tool
def get_schema_info(table_name: Optional[str] = None):
    """获取增强后的Schema信息"""
    if table_name:
        return ENHANCED_SCHEMA.get(table_name)
    return ENHANCED_SCHEMA  # 返回所有表的元数据
```

3. **Prompt中引用**
```python
system_prompt += f"\n\n数据库Schema:\n{get_schema_info()}"
```

---

### Strategy 3: 向量知识库加速 🚀 (速度核心)
**预期提升**: 速度 +50% (针对重复查询)  
**工作量**: 5-7天  
**优先级**: P0

#### 架构设计
```
用户查询 → 向量检索 → [缓存命中?]
                         ├─ 是 → 直接返回历史结果 (1秒)
                         └─ 否 → LLM生成新SQL → 缓存结果
```

#### 技术实现
```python
# backend/services/query_cache.py (新建)
from voyageai import Client as VoyageClient
from pinecone import Pinecone

class QueryCache:
    def __init__(self):
        self.voyage = VoyageClient(api_key=settings.VOYAGE_API_KEY)
        self.pc = Pinecone(api_key=settings.PINECONE_API_KEY)
        self.index = self.pc.Index("chatbi-query-cache")
    
    async def check_cache(self, query: str, threshold=0.92):
        """
        检查语义相似的历史查询
        threshold: 相似度阈值 (0.92 = 高度相似)
        """
        # 1. 生成查询向量
        query_vector = self.voyage.embed(
            [query], 
            model="voyage-3-large"
        ).embeddings[0]
        
        # 2. 向量搜索
        results = self.index.query(
            vector=query_vector,
            top_k=1,
            include_metadata=True
        )
        
        # 3. 判断是否命中
        if results.matches and results.matches[0].score >= threshold:
            cached_result = results.matches[0].metadata
            return {
                "hit": True,
                "sql": cached_result["sql"],
                "data": cached_result["data"],
                "chart": cached_result["chart"],
                "similarity": results.matches[0].score
            }
        
        return {"hit": False}
    
    async def save_to_cache(self, query: str, sql: str, data, chart):
        """保存查询结果到缓存"""
        query_vector = self.voyage.embed([query]).embeddings[0]
        
        self.index.upsert(vectors=[{
            "id": f"query_{hash(query)}",
            "values": query_vector,
            "metadata": {
                "query": query,
                "sql": sql,
                "data": json.dumps(data),
                "chart": json.dumps(chart),
                "timestamp": datetime.now().isoformat()
            }
        }])
```

#### 集成到Agent
```python
# backend/app.py 修改查询端点
@app.post("/query")
async def query_database(request: QueryRequest):
    # 1. 检查缓存
    cache_result = await query_cache.check_cache(request.query)
    
    if cache_result["hit"]:
        logger.info(f"缓存命中! 相似度: {cache_result['similarity']}")
        return {
            "summary": f"[从缓存获取] {request.query}",
            "sql": cache_result["sql"],
            "data": cache_result["data"],
            "chartOption": cache_result["chart"],
            "cached": True
        }
    
    # 2. 缓存未命中,调用Agent
    result = await agent.ainvoke(request.query)
    
    # 3. 保存结果到缓存
    await query_cache.save_to_cache(
        request.query,
        result["sql"],
        result["data"],
        result["chartOption"]
    )
    
    return result
```

**预期效果**:
- 重复查询响应时间: 30秒 → 1秒 (提升 97%)
- 缓存命中率预估: 40-60% (基于管理层查询模式)
- 成本节省: 每月节省 $30-50

---

### Strategy 4: 数据库连接池优化 ⚙️
**预期提升**: 并发能力 +200%, 延迟 -15%  
**工作量**: 1-2天  
**优先级**: P1

#### 当前配置
```python
# backend/config.py
DB_POOL_SIZE: int = 10
DB_MAX_OVERFLOW: int = 20
```

#### 优化配置
```python
# 根据实际负载调整
DB_POOL_SIZE: int = 20  # 增加常驻连接
DB_MAX_OVERFLOW: int = 40  # 峰值支持
DB_POOL_RECYCLE: int = 3600  # 1小时回收,防止连接超时
DB_POOL_PRE_PING: bool = True  # 使用前检查连接有效性
```

#### 添加连接池监控
```python
# backend/app.py
from prometheus_client import Gauge

db_pool_size_gauge = Gauge('db_pool_size', 'Current DB pool size')
db_pool_overflow_gauge = Gauge('db_pool_overflow', 'DB pool overflow count')

@app.get("/metrics/db-pool")
async def get_db_pool_metrics():
    """数据库连接池指标"""
    pool = engine.pool
    return {
        "size": pool.size(),
        "checked_in": pool.checkedin(),
        "checked_out": pool.checkedout(),
        "overflow": pool.overflow(),
        "total": pool.size() + pool.overflow()
    }
```

---

### Strategy 5: Agent 推理优化 🧠
**预期提升**: 复杂查询准确率 +10%  
**工作量**: 3-4天  
**优先级**: P1

#### 优化点 1: 添加自我验证步骤
```python
# backend/agent/graph.py 新增验证节点
async def sql_validation_node(state: AgentState):
    """SQL语法和逻辑验证"""
    last_sql = extract_sql_from_messages(state["messages"])
    
    # 1. 语法检查 (使用 sqlparse)
    try:
        parsed = sqlparse.parse(last_sql)[0]
        if not is_valid_readonly_query(parsed):
            return {
                "error": "检测到非只读操作,已拒绝执行",
                "steps": ["sql_validation_failed"]
            }
    except Exception as e:
        return {
            "error": f"SQL语法错误: {e}",
            "steps": ["sql_syntax_error"]
        }
    
    # 2. 逻辑验证 (检查是否包含必要的WHERE条件等)
    if "DELETE" in last_sql.upper() or "UPDATE" in last_sql.upper():
        return {"error": "禁止修改数据"}
    
    return {"steps": ["sql_validation_passed"]}
```

#### 优化点 2: 多步推理链
```python
# 针对复杂查询,强制LLM分步思考
COMPLEX_QUERY_PROMPT = """
对于复杂查询,必须分步完成:

Step 1: 理解需求
- 用户想要什么数据?
- 涉及哪些业务概念?

Step 2: 识别表关系
- 需要哪些表?
- 如何JOIN?

Step 3: 设计查询
- 先写子查询
- 再组合主查询

Step 4: 验证逻辑
- 是否正确处理了NULL值?
- 是否需要DISTINCT?
"""
```

---

## 🗓️ 实施时间线

### Week 1: 速度优化
- Day 1-2: Prompt精简 + 动态示例
- Day 3-4: 向量缓存基础架构
- Day 5-7: 缓存集成测试 + 数据库连接池优化

### Week 2: 准确度优化
- Day 1-3: Schema语义增强
- Day 4-5: SQL验证节点
- Day 6-7: 多步推理优化

### Week 3: 测试与调优
- Day 1-3: 基准测试 + 性能调优
- Day 4-5: 准确率评估 + Few-Shot示例库建设
- Day 6-7: 文档更新 + 部署准备

---

## 📈 成功指标

### 量化指标
- [ ] 简单查询平均响应时间 < 5秒
- [ ] 复杂查询平均响应时间 < 12秒
- [ ] 缓存命中率 > 50%
- [ ] 基础查询准确率 > 95%
- [ ] 支持 20 QPS 并发

### 质量指标
- [ ] 100个测试查询通过率 > 90%
- [ ] 管理层试用反馈满意度 > 4.5/5
- [ ] 生产环境稳定运行 7天无重大故障

---

## 💡 快速实施建议

### 优先级排序 (如果时间紧张)
1. **必做 (Week 1)**: Prompt优化 + 向量缓存
2. **次要 (Week 2)**: Schema增强
3. **可选 (Week 3)**: 多步推理优化

### 资源需求
- 👨‍💻 1名全职后端开发
- 💰 基础设施成本:
  - Pinecone向量数据库: $70/月 (Starter Plan)
  - Voyage AI嵌入: ~$20/月
  - 总计: ~$100/月

---

**下一步行动**: 
1. 确认优化优先级
2. 分配开发资源
3. 启动 Week 1 Sprint

**技术负责人**: [待指定]  
**预计完成时间**: 2026-02-12
