# ChatBI Agent 系统架构图

## 🏗️ 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         用户/前端应用                              │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTP/SSE
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FastAPI 应用层                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  /query  │  │ /health  │  │/metrics  │  │/session  │        │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │
└───────┼─────────────┼─────────────┼─────────────┼──────────────┘
        │             │             │             │
        ▼             ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    核心服务层                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ ChatBIAgent  │  │HealthChecker │  │MemoryManager │          │
│  │  (LangGraph) │  │              │  │              │          │
│  └──────┬───────┘  └──────────────┘  └──────┬───────┘          │
└─────────┼──────────────────────────────────┼──────────────────┘
          │                                   │
          ▼                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                    LangGraph 状态图                               │
│                                                                   │
│  ┌─────────┐                                                     │
│  │  START  │                                                     │
│  └────┬────┘                                                     │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────────────┐                                            │
│  │  Agent 节点      │  ◄──────────┐                              │
│  │  (推理 & 决策)   │              │                              │
│  └────┬────────────┘              │                              │
│       │                           │                              │
│       ▼                           │                              │
│  ┌─────────────┐                 │                              │
│  │ 条件路由     │                 │                              │
│  │ should_     │                 │                              │
│  │ continue?   │                 │                              │
│  └──┬──────┬───┘                 │                              │
│     │      │                     │                              │
│  tools    end                    │                              │
│     │      │                     │                              │
│     ▼      ▼                     │                              │
│  ┌─────────────┐            ┌───────┐                          │
│  │  工具节点    │────────────│  END  │                          │
│  │  (执行工具)  │            └───────┘                          │
│  └─────────────┘                                                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    工具层                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ execute_sql  │  │get_table_    │  │search_       │          │
│  │              │  │schema        │  │knowledge     │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼──────────────────┼──────────────────┼──────────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    外部服务层                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   MySQL      │  │  Claude API  │  │  Voyage AI   │          │
│  │   Database   │  │  (Anthropic) │  │  (Embeddings)│          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  LangSmith   │  │  Prometheus  │  │    Redis     │          │
│  │  (Tracing)   │  │  (Metrics)   │  │   (Cache)    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└──────────────────────────────────────────────────────────────────┘
```

## 🔄 数据流详解

### 1. 查询处理流程

```
用户查询
   │
   ├─► 1. FastAPI 接收请求
   │      └─► 验证请求参数
   │      └─► 提取 session_id
   │
   ├─► 2. ChatBIAgent.ainvoke()
   │      └─► 初始化 AgentState
   │      └─► 加载会话记忆
   │
   ├─► 3. LangGraph 执行
   │      │
   │      ├─► Agent 节点
   │      │   └─► Claude Sonnet 4.5 推理
   │      │   └─► 决定下一步行动
   │      │
   │      ├─► 工具节点
   │      │   └─► 执行 SQL 查询
   │      │   └─► 获取表结构
   │      │   └─► 搜索知识库
   │      │
   │      └─► 条件路由
   │          └─► 继续 or 结束
   │
   ├─► 4. 状态更新
   │      └─► 更新消息历史
   │      └─► 保存 SQL 结果
   │      └─► 生成数据洞察
   │
   └─► 5. 返回响应
          └─► 格式化输出
          └─► 更新记忆
          └─► 记录指标
```

### 2. 流式响应流程

```
用户请求 (stream=true)
   │
   ├─► FastAPI StreamingResponse
   │
   ├─► ChatBIAgent.astream()
   │      │
   │      └─► async for event in graph.astream():
   │             │
   │             ├─► {"type": "event", "data": {...}}
   │             │   └─► SSE: data: {...}\n\n
   │             │
   │             ├─► {"type": "event", "data": {...}}
   │             │   └─► SSE: data: {...}\n\n
   │             │
   │             └─► {"type": "end"}
   │                 └─► SSE: data: {"type":"end"}\n\n
   │
   └─► 客户端接收 SSE 流
          └─► 实时显示思考过程
          └─► 显示工具执行结果
          └─► 显示最终答案
```

## 🧩 组件详解

### Agent 节点 (agent_node)

```python
async def agent_node(state: AgentState) -> AgentState:
    """
    职责:
    1. 接收当前状态
    2. 构建提示词
    3. 调用 Claude Sonnet 4.5
    4. 解析 LLM 响应
    5. 更新状态
    """
    messages = state["messages"]
    response = await llm_with_tools.ainvoke(messages)
    return {**state, "messages": messages + [response]}
```

### 工具节点 (tools_node)

```python
async def tools_node(state: AgentState) -> AgentState:
    """
    职责:
    1. 提取工具调用
    2. 执行工具函数
    3. 收集执行结果
    4. 更新状态
    """
    tool_calls = state["messages"][-1].tool_calls
    results = await execute_tools(tool_calls)
    return {**state, "tool_results": results}
```

### 条件路由 (should_continue)

```python
def should_continue(state: AgentState) -> Literal["tools", "end"]:
    """
    职责:
    1. 检查最后一条消息
    2. 判断是否有工具调用
    3. 决定下一步: 执行工具 or 结束
    """
    last_message = state["messages"][-1]
    if hasattr(last_message, "tool_calls") and last_message.tool_calls:
        return "tools"
    return "end"
```

## 📊 状态管理

### AgentState 结构

```python
class AgentState(TypedDict):
    # 核心状态
    messages: List[BaseMessage]      # 消息历史
    query: str                       # 用户查询
    session_id: str                  # 会话 ID
    
    # SQL 相关
    sql_query: Optional[str]         # 生成的 SQL
    sql_result: Optional[Any]        # 执行结果
    
    # 输出相关
    data_insight: Optional[str]      # 数据洞察
    echarts_option: Optional[Dict]   # 图表配置
    
    # 上下文
    context: List[Dict]              # 检索上下文
    
    # 错误处理
    error: Optional[str]             # 错误信息
    retry_count: int                 # 重试次数
    
    # 追踪
    steps: List[str]                 # 执行步骤
    metadata: Dict[str, Any]         # 元数据
```

### 状态流转示例

```
初始状态:
{
  "messages": [],
  "query": "查询最近一个月的销售趋势",
  "session_id": "user-123",
  "sql_query": null,
  "sql_result": null,
  ...
}

↓ Agent 节点执行后

{
  "messages": [
    HumanMessage("查询最近一个月的销售趋势"),
    AIMessage(tool_calls=[{"name": "execute_sql", ...}])
  ],
  "query": "查询最近一个月的销售趋势",
  "steps": ["agent_reasoning"],
  ...
}

↓ 工具节点执行后

{
  "messages": [..., ToolMessage(content="...")],
  "sql_query": "SELECT DATE(created_at), SUM(amount) ...",
  "sql_result": [{...}, {...}],
  "steps": ["agent_reasoning", "tool_execution"],
  ...
}

↓ 最终状态

{
  "messages": [..., AIMessage("根据数据...")],
  "sql_query": "SELECT ...",
  "sql_result": [{...}],
  "data_insight": "销售额呈上升趋势...",
  "echarts_option": {...},
  "steps": ["agent_reasoning", "tool_execution", "agent_reasoning"],
  ...
}
```

## 🔍 监控与追踪

### LangSmith 追踪

```
Run: query_database
├─► Input: {"query": "查询销售趋势", "session_id": "user-123"}
│
├─► ChatBIAgent.ainvoke
│   ├─► agent_node
│   │   └─► Claude API Call
│   │       ├─► Prompt Tokens: 1234
│   │       ├─► Completion Tokens: 567
│   │       └─► Latency: 1.2s
│   │
│   ├─► tools_node
│   │   └─► execute_sql
│   │       ├─► SQL: SELECT ...
│   │       ├─► Rows: 30
│   │       └─► Latency: 0.3s
│   │
│   └─► agent_node
│       └─► Claude API Call
│           └─► Latency: 0.8s
│
└─► Output: {"summary": "...", "sql": "...", "chartOption": {...}}
    └─► Total Latency: 2.5s
```

### Prometheus 指标

```
# 请求计数
chatbi_requests_total{endpoint="/query", method="POST", status="success"} 1234

# 请求耗时
chatbi_request_duration_seconds{endpoint="/query"} 2.5

# Agent 执行时间
chatbi_agent_execution_seconds 2.3

# SQL 查询计数
chatbi_sql_queries_total{status="success"} 1234
```

## 🛡️ 错误处理流程

```
工具执行
   │
   ├─► try:
   │      └─► 执行 SQL 查询
   │
   ├─► except Exception as e:
   │      │
   │      ├─► 记录错误日志
   │      │   └─► logger.error("sql_query_failed", error=str(e))
   │      │
   │      ├─► 检查重试次数
   │      │   └─► if retry_count < MAX_RETRIES:
   │      │          └─► 指数退避重试
   │      │
   │      └─► 返回错误信息
   │          └─► {"error": "SQL 执行失败: ..."}
   │
   └─► finally:
          └─► 更新指标
              └─► SQL_QUERY_COUNT.labels(status="error").inc()
```

## 🚀 性能优化点

### 1. 异步执行

```python
# 所有 I/O 操作都是异步的
async def execute_sql_query(query: str):
    async with db_engine.connect() as conn:
        result = await conn.execute(query)
        return result.fetchall()
```

### 2. 连接池

```python
# 数据库连接池
engine = create_async_engine(
    database_url,
    pool_size=10,           # 连接池大小
    max_overflow=20,        # 最大溢出
    pool_pre_ping=True      # 连接健康检查
)
```

### 3. 缓存策略（待实现）

```python
# Redis 缓存
@cache(ttl=3600)
async def get_table_schema(table_name: str):
    # 缓存表结构查询
    ...
```

### 4. 并发控制

```python
# 使用 asyncio.gather 并发执行
results = await asyncio.gather(
    execute_sql(query1),
    execute_sql(query2),
    search_knowledge(query)
)
```

---

**架构设计原则**:
- ✅ 单一职责 - 每个组件只做一件事
- ✅ 开闭原则 - 易于扩展，无需修改核心代码
- ✅ 依赖倒置 - 依赖抽象而非具体实现
- ✅ 接口隔离 - 最小化接口依赖
- ✅ 异步优先 - 所有 I/O 操作异步化
