# ChatBI Agent - 生产级 LangChain/LangGraph 系统

基于 **LangChain 0.3+** 和 **LangGraph 0.2+** 构建的生产级 AI 数据库查询助手。

## 🎯 核心特性

### ✅ 最新技术栈
- **LangChain 0.3+** - 最新的 LangChain 框架
- **LangGraph 0.2+** - 状态图驱动的 Agent 架构
- **Claude Sonnet 4.5** - Anthropic 最新旗舰模型
- **Voyage AI** - Anthropic 官方推荐的嵌入模型

### ✅ 生产级特性
- **异步优先** - 全面使用 async/await 模式
- **状态管理** - LangGraph StateGraph 实现复杂工作流
- **记忆系统** - 多层次对话记忆（短期、摘要、实体）
- **错误处理** - 完善的重试、超时和降级策略
- **可观测性** - LangSmith 追踪 + Prometheus 指标
- **流式响应** - 支持 SSE 流式输出
- **健康检查** - 完整的服务健康监控

### ✅ 安全性
- SQL 注入防护
- 只读查询限制
- API 密钥认证（可选）
- CORS 配置

## 📁 项目结构

```
backend/
├── agent/                  # Agent 核心组件
│   ├── __init__.py        # 包初始化
│   ├── graph.py           # LangGraph 状态图
│   ├── state.py           # 状态定义
│   ├── tools.py           # Agent 工具
│   ├── prompts.py         # 提示词模板
│   └── memory.py          # 记忆管理
├── app.py                 # FastAPI 应用
├── config.py              # 配置管理
├── logging_config.py      # 日志配置
├── requirements.txt       # Python 依赖
├── .env.example           # 环境变量示例
└── README.md              # 本文件
```

## 🚀 快速开始

### 1. 环境准备

```bash
# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
# Windows
.venv\Scripts\activate
# Linux/Mac
source .venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

### 2. 配置环境变量

```bash
# 复制环境变量示例
cp .env.example .env

# 编辑 .env 文件，填入你的配置
```

**必需配置**：
- `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` - 数据库连接
- `ANTHROPIC_API_KEY` - Claude API 密钥
- `VOYAGE_API_KEY` - Voyage AI API 密钥（可选，用于 RAG）
- `LANGCHAIN_API_KEY` - LangSmith API 密钥（可选，用于追踪）

### 3. 启动服务

```bash
# 开发模式
uvicorn app:app --reload --host 0.0.0.0 --port 8000

# 生产模式
uvicorn app:app --host 0.0.0.0 --port 8000 --workers 4
```

### 4. 访问 API

- **API 文档**: http://localhost:8000/docs
- **健康检查**: http://localhost:8000/health
- **Prometheus 指标**: http://localhost:8000/metrics

## 📖 API 使用示例

### 非流式查询

```bash
curl -X POST "http://localhost:8000/query" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "查询最近一个月的销售趋势",
    "session_id": "user-123",
    "stream": false
  }'
```

**响应**：
```json
{
  "summary": "根据查询结果，最近一个月销售额呈上升趋势...",
  "sql": "SELECT DATE(created_at) as date, SUM(amount) as total FROM orders WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH) GROUP BY DATE(created_at)",
  "chartOption": {
    "title": { "text": "销售趋势" },
    "xAxis": { "type": "category", "data": [...] },
    "yAxis": { "type": "value" },
    "series": [{ "type": "line", "data": [...] }]
  },
  "error": null,
  "session_id": "user-123"
}
```

### 流式查询

```bash
curl -X POST "http://localhost:8000/query" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "分析客户分布情况",
    "session_id": "user-123",
    "stream": true
  }'
```

**响应（SSE 流）**：
```
data: {"type":"event","data":{"agent":"正在分析查询..."}}

data: {"type":"event","data":{"tools":"执行 SQL 查询..."}}

data: {"type":"event","data":{"agent":"生成数据洞察..."}}

data: {"type":"end"}
```

### 会话管理

```bash
# 获取会话统计
curl "http://localhost:8000/session/user-123/stats"

# 清除会话
curl -X DELETE "http://localhost:8000/session/user-123"
```

## 🏗️ 架构设计

### LangGraph 状态图

```
┌─────────┐
│  START  │
└────┬────┘
     │
     ▼
┌─────────────┐
│   Agent     │ ◄─┐
│  Reasoning  │   │
└──────┬──────┘   │
       │          │
       ▼          │
   ┌───────┐      │
   │Should │      │
   │Continue?     │
   └───┬───┘      │
       │          │
    ┌──┴──┐       │
    │Tools│       │
    │Exec │───────┘
    └─────┘
       │
       ▼
    ┌─────┐
    │ END │
    └─────┘
```

### 数据流

```
用户查询
   │
   ▼
FastAPI 端点
   │
   ▼
ChatBIAgent (LangGraph)
   │
   ├─► Agent 推理节点
   │   └─► Claude Sonnet 4.5
   │
   ├─► 工具执行节点
   │   ├─► execute_sql
   │   ├─► get_table_schema
   │   ├─► search_schema
   │   └─► search_knowledge
   │
   └─► 状态更新
       └─► 记忆管理
           └─► 响应返回
```

## 🔧 配置说明

### LLM 配置

```python
# Claude Sonnet 4.5 (推荐)
ANTHROPIC_MODEL=claude-sonnet-4-20250514
LLM_TEMPERATURE=0.1
LLM_MAX_TOKENS=4096
```

### 嵌入模型配置

```python
# Voyage AI (Anthropic 官方推荐)
VOYAGE_MODEL=voyage-3-large        # 通用场景
# VOYAGE_MODEL=voyage-code-3       # 代码场景
# VOYAGE_MODEL=voyage-finance-2    # 金融场景
# VOYAGE_MODEL=voyage-law-2        # 法律场景
```

### 记忆配置

```python
# 对话记忆
MAX_TOKEN_LIMIT=4000              # 最大 token 限制
SUMMARY_THRESHOLD=10              # 触发摘要的消息数
```

### 监控配置

```python
# LangSmith 追踪
LANGCHAIN_TRACING_V2=true
LANGCHAIN_PROJECT=chatbi-production

# Prometheus 指标
ENABLE_METRICS=true
METRICS_PORT=9090
```

## 📊 监控与可观测性

### LangSmith 追踪

访问 [LangSmith](https://smith.langchain.com) 查看：
- Agent 执行轨迹
- 工具调用详情
- Token 使用统计
- 错误和异常

### Prometheus 指标

```bash
# 查看指标
curl http://localhost:8000/metrics
```

**可用指标**：
- `chatbi_requests_total` - 请求总数
- `chatbi_request_duration_seconds` - 请求耗时
- `chatbi_agent_execution_seconds` - Agent 执行时间
- `chatbi_sql_queries_total` - SQL 查询总数

### 结构化日志

日志格式（JSON）：
```json
{
  "event": "query_completed",
  "timestamp": "2026-01-20T21:00:00Z",
  "level": "info",
  "session_id": "user-123",
  "execution_time": 2.5,
  "app": "chatbi-agent"
}
```

## 🧪 测试

```bash
# 运行测试
pytest tests/

# 异步测试
pytest tests/ -v --asyncio-mode=auto

# 覆盖率
pytest --cov=agent --cov-report=html
```

## 🚀 部署

### Docker 部署

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

```bash
# 构建镜像
docker build -t chatbi-agent .

# 运行容器
docker run -p 8000:8000 --env-file .env chatbi-agent
```

### Kubernetes 部署

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chatbi-agent
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chatbi-agent
  template:
    metadata:
      labels:
        app: chatbi-agent
    spec:
      containers:
      - name: chatbi-agent
        image: chatbi-agent:latest
        ports:
        - containerPort: 8000
        env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: chatbi-secrets
              key: db-host
        # ... 其他环境变量
```

## 📝 最佳实践

### 1. 错误处理

```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
async def call_llm():
    # LLM 调用逻辑
    pass
```

### 2. 超时控制

```python
import asyncio

async def query_with_timeout(query: str, timeout: int = 60):
    try:
        return await asyncio.wait_for(
            agent.ainvoke(query),
            timeout=timeout
        )
    except asyncio.TimeoutError:
        return {"error": "查询超时"}
```

### 3. 缓存策略

```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_table_schema(table_name: str):
    # 缓存表结构查询
    pass
```

## 🔐 安全建议

1. **启用 API 认证**
   ```python
   ENABLE_AUTH=true
   ```

2. **限制 CORS 源**
   ```python
   ALLOWED_ORIGINS=["https://your-domain.com"]
   ```

3. **使用环境变量**
   - 不要在代码中硬编码密钥
   - 使用 `.env` 文件或密钥管理服务

4. **SQL 注入防护**
   - 已内置：只允许 SELECT 语句
   - 使用参数化查询

## 📚 参考资源

- [LangChain 文档](https://python.langchain.com/)
- [LangGraph 文档](https://langchain-ai.github.io/langgraph/)
- [Anthropic Claude 文档](https://docs.anthropic.com/)
- [Voyage AI 文档](https://docs.voyageai.com/)
- [LangSmith 文档](https://docs.smith.langchain.com/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**构建时间**: 2026-01-20  
**版本**: 3.0.0  
**作者**: ChatBI Team
