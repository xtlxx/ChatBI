# 前后端 API 不匹配分析

> 此文档展示当前前后端 API 的不匹配情况,以及期望的对齐状态

---

## 📊 当前状态 vs 期望状态

### 1. 查询 API (Chat 功能)

#### ❌ 当前状态

**前端发送** (`lib/api-services.ts`)
```javascript
POST /query/stream  // ❌ 端点不存在
{
  "query": "显示销售数据",
  "connection_id": 1,     // ❌ 后端不支持
  "llm_config_id": 2      // ❌ 后端不支持
}
```

**后端期望** (`backend/app.py`)
```python
POST /query  # ✅ 实际端点
{
  "query": "显示销售数据",
  "session_id": "default",
  "stream": false,
  "metadata": {}
  # ❌ 缺少 connection_id 和 llm_config_id
}
```

**结果**: 🔴 **请求失败** (404 Not Found 或 422 Unprocessable Entity)

---

#### ✅ 期望状态

**前端发送**
```javascript
POST /query
{
  "query": "显示销售数据",
  "connection_id": 1,
  "llm_config_id": 2,
  "stream": true,
  "session_id": "default"
}
```

**后端接收**
```python
POST /query
{
  "query": "显示销售数据",
  "connection_id": 1,     # ✅ 新增字段
  "llm_config_id": 2,     # ✅ 新增字段
  "stream": true,
  "session_id": "default"
}
```

**修复方案**:
1. **前端**: 修改 `api-services.ts:118` 端点从 `/query/stream` 改为 `/query`
2. **后端**: 修改 `app.py:57-62` 添加 `connection_id` 和 `llm_config_id` 字段

---

### 2. SSE 流式响应格式

#### ❌ 当前状态

**后端发送** (`backend/app.py:360-370`)
```
data: {"type": "event", "data": {"sql": "SELECT ...", "summary": "..."}}

data: {"type": "end"}
```

**前端解析** (`hooks/useChatStream.ts:99-149`)
```javascript
switch (chunk.type) {
  case 'thought':        // ❌ 后端从不发送
  case 'observation':    // ❌ 后端从不发送
  case 'final_output':   // ❌ 后端从不发送
  case 'error':          // ✅ 匹配
  case 'end':            // ✅ 匹配
}
```

**结果**: 🔴 **前端无法解析响应,消息内容为空**

---

#### ✅ 期望状态

**后端发送**
```
data: {"type": "thought", "content": "我需要查询销售表"}

data: {"type": "observation", "content": "正在执行SQL查询..."}

data: {"type": "final_output", "content": {"sql": "SELECT ...", "summary": "...", "chartOption": {...}}}

data: {"type": "end"}
```

**前端解析**
```javascript
switch (chunk.type) {
  case 'thought':        // ✅ 显示在思维过程
  case 'observation':    // ✅ 显示观察结果
  case 'final_output':   // ✅ 显示最终答案
  case 'error':          // ✅ 显示错误
  case 'end':            // ✅ 结束流式传输
}
```

**修复方案**: 见 `PRIORITY_FIXES.md` 任务3

---

### 3. 认证 API

#### ❌ 当前状态

**前端调用** (`lib/api-services.ts:14-48`)
```javascript
POST /auth/login      // ❌ 端点不存在
POST /auth/register   // ❌ 端点不存在
GET  /auth/me         // ❌ 端点不存在
POST /auth/logout     // ❌ 端点不存在
```

**后端状态**: 🔴 **完全缺失这些端点**

**结果**: 🔴 **登录/注册页面完全无法工作**

---

#### ✅ 期望状态

**前端调用**
```javascript
POST /auth/login
{
  "username": "test",
  "password": "password123"
}

// 响应
{
  "id": 1,
  "username": "test",
  "email": "test@example.com",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**后端实现**
```python
@router.post("/auth/login")
async def login(credentials: LoginRequest):
    # 验证用户名密码
    # 生成 JWT token
    return {"id": user.id, "token": jwt_token, ...}
```

**修复方案**: 见 `PRIORITY_FIXES.md` 任务4

---

### 4. 数据库连接 API

#### ❌ 当前状态

**前端调用** (`lib/api-services.ts:52-81`)
```javascript
GET    /connections           // ❌ 不存在
POST   /connections           // ❌ 不存在
PUT    /connections/{id}      // ❌ 不存在
DELETE /connections/{id}      // ❌ 不存在
POST   /connections/test      // ❌ 不存在
```

**后端状态**: 🔴 **完全缺失这些端点**

**结果**: 🔴 **Settings 页面数据库配置功能完全无法工作**

---

#### ✅ 期望状态

**前端调用**
```javascript
POST /connections
{
  "name": "生产数据库",
  "type": "mysql",
  "host": "localhost",
  "port": 3306,
  "username": "root",
  "password": "password",
  "database_name": "sales_db"
  // ✅ 不包含 user_id (从JWT提取)
}

// 响应
{
  "id": 1,
  "name": "生产数据库",
  "type": "mysql",
  "host": "localhost",
  "port": 3306,
  "username": "root",
  "database_name": "sales_db"
  // ✅ 不返回 password
}
```

**后端实现**
```python
@router.post("/connections")
async def create_connection(
    data: DbConnectionForm,
    current_user_id: int = Depends(get_current_user)  # 从JWT提取
):
    new_connection = DbConnection(
        user_id=current_user_id,  # ✅ 从token获取,不从请求体
        **data.dict()
    )
    # 保存到数据库
    return new_connection
```

**修复方案**: 见 `PRIORITY_FIXES.md` 任务5

---

### 5. LLM 配置 API

#### ❌ 当前状态

**前端调用** (`lib/api-services.ts:84-113`)
```javascript
GET    /llm-configs           // ❌ 不存在
POST   /llm-configs           // ❌ 不存在
PUT    /llm-configs/{id}      // ❌ 不存在
DELETE /llm-configs/{id}      // ❌ 不存在
POST   /llm-configs/test      // ❌ 不存在
```

**后端状态**: 🔴 **完全缺失这些端点**

**结果**: 🔴 **Settings 页面 LLM 配置功能完全无法工作**

---

#### ✅ 期望状态

**前端调用**
```javascript
POST /llm-configs
{
  "provider": "openai",
  "model_name": "gpt-4",
  "api_key": "sk-...",
  "base_url": "https://api.openai.com/v1"
  // ✅ 不包含 user_id
}

// 响应
{
  "id": 1,
  "provider": "openai",
  "model_name": "gpt-4",
  "base_url": "https://api.openai.com/v1"
  // ✅ 不返回 api_key
}
```

**后端实现**: 类似数据库连接API

**修复方案**: 见 `PRIORITY_FIXES.md` 任务6

---

### 6. 聊天历史 API

#### ❌ 当前状态

**前端调用** (`lib/api-services.ts:121-139`)
```javascript
GET  /chat/sessions           // ❌ 不存在
GET  /chat/history/{id}       // ❌ 不存在
POST /chat/sessions           // ❌ 不存在
DELETE /chat/sessions/{id}    // ❌ 不存在
```

**后端状态**: 🟡 **后端有 `/session/{id}` 但不完整**

**当前后端端点** (`backend/app.py:401-430`)
```python
DELETE /session/{session_id}           # ✅ 存在
GET    /session/{session_id}/stats     # ✅ 存在
# ❌ 缺少获取所有会话列表
# ❌ 缺少获取会话消息历史
# ❌ 缺少保存会话
```

---

#### ✅ 期望状态

**需要添加的端点**:
```python
@router.get("/chat/sessions")
async def get_sessions(current_user_id: int = Depends(get_current_user)):
    # 返回用户的所有聊天会话
    return [
        {"id": "session-1", "title": "销售分析", "created_at": "2026-01-20T10:00:00Z"},
        {"id": "session-2", "title": "库存查询", "created_at": "2026-01-20T11:00:00Z"}
    ]

@router.get("/chat/history/{session_id}")
async def get_history(session_id: str, current_user_id: int = Depends(get_current_user)):
    # 返回指定会话的消息历史
    return [
        {"id": "msg-1", "role": "user", "content": "显示销售数据"},
        {"id": "msg-2", "role": "ai", "content": "**SQL:**\n```sql\nSELECT ...\n```"}
    ]

@router.post("/chat/sessions")
async def save_session(
    title: str,
    messages: list,
    current_user_id: int = Depends(get_current_user)
):
    # 保存聊天会话
    return {"id": "new-session-id"}
```

---

## 🔄 API 对齐优先级

| API 类别 | 前端状态 | 后端状态 | 优先级 | 预计工作量 |
|---------|---------|---------|--------|-----------|
| 查询 API | ✅ 完成 | 🟡 需修改 | 🔴 P0 | 30分钟 |
| SSE 流式 | ✅ 完成 | 🟡 需修改 | 🔴 P0 | 1小时 |
| 认证 API | ✅ 完成 | ❌ 缺失 | 🔴 P0 | 3小时 |
| 数据库连接 | ✅ 完成 | ❌ 缺失 | 🟡 P1 | 2.5小时 |
| LLM 配置 | ✅ 完成 | ❌ 缺失 | 🟡 P1 | 1.5小时 |
| 聊天历史 | ✅ 完成 | 🟡 部分 | 🔵 P2 | 2小时 |

**总计修复时间**: ~10.5小时 (约1.5个工作日)

---

## 📋 验证清单

修复完成后,使用此清单验证:

### 查询功能
```bash
# 1. 测试流式查询
curl -X POST http://localhost:8000/query \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "显示销售数据",
    "connection_id": 1,
    "llm_config_id": 1,
    "stream": true,
    "session_id": "test"
  }'

# 应该返回 SSE 流
# data: {"type": "thought", "content": "..."}
# data: {"type": "final_output", "content": {...}}
# data: {"type": "end"}
```

### 认证功能
```bash
# 2. 测试注册
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"password123"}'

# 3. 测试登录
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"password123"}'

# 4. 测试获取当前用户
TOKEN="从登录响应获取"
curl http://localhost:8000/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

### 数据库连接
```bash
# 5. 测试创建连接
curl -X POST http://localhost:8000/connections \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"测试数据库",
    "type":"mysql",
    "host":"localhost",
    "port":3306,
    "username":"root",
    "password":"password",
    "database_name":"test"
  }'

# 6. 测试获取连接列表
curl http://localhost:8000/connections \
  -H "Authorization: Bearer $TOKEN"

# 7. 测试连接测试
curl -X POST http://localhost:8000/connections/test \
  -H "Content-Type: application/json" \
  -d '{
    "name":"测试",
    "type":"mysql",
    "host":"localhost",
    "port":3306,
    "username":"root",
    "password":"password",
    "database_name":"test"
  }'
```

### 前端集成测试
```bash
# 8. 启动前端
cd frontend
npm run dev

# 访问 http://localhost:3000
# 应该:
# - 自动跳转到 /login
# - 可以注册新用户
# - 登录后跳转到 /chat
# - Settings 可以添加数据库连接
# - Settings 可以添加 LLM 配置
# - 聊天页面可以发送消息并收到流式响应
```

---

## 🎯 修复后的完整架构

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend (Next.js)                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  /login, /register  →  POST /auth/login                     │
│                     →  POST /auth/register                  │
│                     →  GET  /auth/me                        │
│                                                             │
│  /settings          →  GET    /connections                  │
│                     →  POST   /connections                  │
│                     →  PUT    /connections/{id}             │
│                     →  DELETE /connections/{id}             │
│                     →  POST   /connections/test             │
│                                                             │
│                     →  GET    /llm-configs                  │
│                     →  POST   /llm-configs                  │
│                     →  PUT    /llm-configs/{id}             │
│                     →  DELETE /llm-configs/{id}             │
│                                                             │
│  /chat              →  POST   /query (stream=true)          │
│                     →  GET    /chat/sessions                │
│                     →  GET    /chat/history/{id}            │
│                     →  POST   /chat/sessions                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Backend (FastAPI)                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  /auth/login        ←  JWT 生成                             │
│  /auth/register     ←  用户创建 + JWT                       │
│  /auth/me           ←  JWT 验证 (Depends)                   │
│                                                             │
│  /connections       ←  从 JWT 提取 user_id                  │
│  /llm-configs       ←  从 JWT 提取 user_id                  │
│                                                             │
│  /query             ←  使用 connection_id + llm_config_id   │
│                     ←  返回 SSE 流 (thought, observation,   │
│                        final_output, error, end)            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                               ▼
                        ┌──────────────┐
                        │   Database   │
                        │   (MySQL)    │
                        └──────────────┘
```

---

**最后更新**: 2026-01-20 22:49:38
