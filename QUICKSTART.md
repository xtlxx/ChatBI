# 🚀 快速开始指南

> 从零开始运行企业级 AI SQL 分析平台

---

## 📋 前置要求

### 软件要求
- Python 3.10+
- Node.js 18+
- MySQL 8.0+ (或 PostgreSQL 14+)
- Git

### 推荐工具
- VS Code
- Postman (API 测试)
- MySQL Workbench (数据库管理)

---

## 🗄️ 第一步: 数据库设置

### 1.1 创建数据库

```sql
CREATE DATABASE chatbi DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 1.2 执行初始化脚本

```bash
# Windows (MySQL)
mysql -u root -p chatbi < backend/database_init.sql

# 或者在 MySQL Workbench 中直接执行 backend/database_init.sql
```

### 1.3 验证表创建

```sql
USE chatbi;
SHOW TABLES;

-- 应该看到:
-- users
-- db_connections
-- llm_configs
-- chat_sessions
-- chat_messages
```

---

## ⚙️ 第二步: 后端设置

### 2.1 进入后端目录

```bash
cd backend
```

### 2.2 创建虚拟环境

```bash
python -m venv .venv
```

### 2.3 激活虚拟环境

```bash
# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# Windows CMD
.venv\Scripts\activate.bat

# Linux/Mac
source .venv/bin/activate
```

### 2.4 安装依赖

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**注意**: 如果安装失败,请尝试:
```bash
pip install python-jose[cryptography] passlib[bcrypt] asyncpg aiomysql
```

### 2.5 配置环境变量

创建 `.env` 文件:

```bash
# backend/.env
DATABASE_URL=mysql+aiomysql://root:your_password@localhost:3306/chatbi
JWT_SECRET_KEY=your-super-secret-key-change-this-in-production
ANTHROPIC_API_KEY=your-anthropic-api-key
LANGCHAIN_API_KEY=your-langsmith-api-key
LANGCHAIN_PROJECT=chatbi-production
```

### 2.6 启动后端

```bash
# 开发模式 (自动重载)
uvicorn app:app --reload --host 0.0.0.0 --port 8000

# 或者直接运行
python app.py
```

### 2.7 验证后端

访问: http://localhost:8000/docs

应该看到 Swagger UI,包含以下端点:

**Authentication**
- POST `/auth/register` - 用户注册
- POST `/auth/login` - 用户登录
- GET `/auth/me` - 获取当前用户
- POST `/auth/logout` - 登出

**Database Connections**
- GET `/connections` - 获取所有连接
- POST `/connections` - 创建连接
- GET `/connections/{id}` - 获取指定连接
- PUT `/connections/{id}` - 更新连接
- DELETE `/connections/{id}` - 删除连接
- POST `/connections/test` - 测试连接

**LLM Configurations**
- GET `/llm-configs` - 获取所有配置
- POST `/llm-configs` - 创建配置
- GET `/llm-configs/{id}` - 获取指定配置
- PUT `/llm-configs/{id}` - 更新配置
- DELETE `/llm-configs/{id}` - 删除配置
- POST `/llm-configs/test` - 测试配置

**Query**
- POST `/query` - 执行查询 (支持流式)

**Health**
- GET `/health` - 健康检查

---

## 🎨 第三步: 前端设置

### 3.1 进入前端目录

```bash
cd ../frontend
```

### 3.2 安装依赖

```bash
npm install
```

**注意**: 如果安装较慢,可以使用国内镜像:
```bash
npm config set registry https://registry.npmmirror.com
npm install
```

### 3.3 配置环境变量

创建 `.env.local` 文件:

```bash
# frontend/.env.local
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

### 3.4 启动前端

```bash
npm run dev
```

### 3.5 访问应用

打开浏览器访问: http://localhost:3000

应该自动跳转到登录页面。

---

## 🧪 第四步: 功能测试

### 4.1 测试注册

1. 访问 http://localhost:3000/register
2. 填写:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `password123`
3. 点击注册
4. 应该自动跳转到 `/chat` 页面

### 4.2 测试数据库连接

1. 点击右上角 Settings
2. 切换到 "Database Connections" 标签
3. 点击 "Add Connection"
4. 填写:
   - Name: `本地测试数据库`
   - Type: `MySQL`
   - Host: `localhost`
   - Port: `3306`
   - Username: `root`
   - Password: `your_password`
   - Database: `chatbi`
5. 点击 "Test Connection"
6. 成功后点击 "Save"

### 4.3 测试 LLM 配置

1. 切换到 "LLM Models" 标签
2. 点击 "Add LLM Model"
3. 填写:
   - Provider: `OpenAI`
   - Model Name: `gpt-4`
   - API Key: `your_openai_api_key`
   - Base URL: (留空或填自定义端点)
4. 点击 "Test Connection"
5. 成功后点击 "Save"

### 4.4 测试聊天功能

1. 返回 Chat 页面
2. 在顶部选择器中:
   - 选择刚才创建的数据库连接
   - 选择刚才创建的 LLM 配置
3. 输入查询,例如: `显示所有用户`
4. 应该看到流式响应

---

## 🐛 常见问题

### 问题 1: 后端启动失败

**错误**: `ModuleNotFoundError: No module named 'jose'`

**解决**:
```bash
pip install python-jose[cryptography]
```

---

### 问题 2: 数据库连接失败

**错误**: `Can't connect to MySQL server on 'localhost'`

**解决**:
1. 确认 MySQL 服务正在运行
2. 检查 `.env` 中的数据库凭证
3. 测试连接:
```bash
mysql -u root -p -e "SELECT 1"
```

---

### 问题 3: 前端 API 调用 401

**错误**: 前端控制台显示 `401 Unauthorized`

**解决**:
1. 检查 localStorage 是否有 `jwt_token`
2. 重新登录
3. 检查后端日志中的 token 验证错误

---

### 问题 4: CORS 错误

**错误**: `Access to fetch at 'http://localhost:8000' ... blocked by CORS policy`

**解决**:
检查 `backend/app.py` 中的 CORS 配置:
```python
allow_origins=["http://localhost:3000"],  # 确保包含前端地址
```

---

## 📊 API 使用示例

### 注册用户

```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "demo",
    "email": "demo@example.com",
    "password": "password123"
  }'

# 响应
{
  "id": 1,
  "username": "demo",
  "email": "demo@example.com",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 登录

```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "demo",
    "password": "password123"
  }'
```

### 创建数据库连接

```bash
TOKEN="your-jwt-token"

curl -X POST http://localhost:8000/connections \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "生产数据库",
    "type": "mysql",
    "host": "localhost",
    "port": 3306,
    "username": "root",
    "password": "password",
    "database_name": "sales_db"
  }'
```

### 执行查询

```bash
curl -X POST http://localhost:8000/query \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "显示所有用户",
    "connection_id": 1,
    "llm_config_id": 1,
    "stream": false,
    "session_id": "test-session"
  }'
```

### 流式查询 (SSE)

```bash
curl -X POST http://localhost:8000/query \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "分析销售趋势",
    "connection_id": 1,
    "llm_config_id": 1,
    "stream": true
  }'

# 响应 (SSE 格式)
data: {"type":"thought","content":"我需要查询销售表"}

data: {"type":"final_output","content":{"sql":"SELECT ...","summary":"...","chartOption":{...}}}

data: {"type":"end"}
```

---

## 🔐 安全注意事项

### 生产环境必须做的事:

1. **更改 JWT 密钥**
```bash
# 生成安全的随机密钥
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

2. **加密存储敏感数据**
- 数据库密码应该使用 AES 加密存储
- API 密钥应该使用加密存储

3. **启用 HTTPS**
```python
# 仅允许 HTTPS 请求
app.add_middleware(
    HTTPSRedirectMiddleware,
    ...
)
```

4. **限制 CORS**
```python
allow_origins=["https://your-production-domain.com"],
```

5. **添加速率限制**
```bash
pip install slowapi
```

---

## 📝 下一步

完成基本设置后,您可以:

1. ✅ 查看 `CODE_REVIEW.md` - 了解代码质量
2. ✅ 查看 `PRIORITY_FIXES.md` - 查看待优化项
3. ✅ 查看 `API_MISMATCH_ANALYSIS.md` - 理解API设计
4. ✅ 添加更多功能 (见 P2/P3 任务)
5. ✅ 编写单元测试
6. ✅ 部署到生产环境

---

## 🎯 验收检查

完成所有步骤后,应该能够:

- [x] 用户可以注册和登录
- [x] 登录后自动跳转到聊天页面
- [x] 可以在 Settings 中添加数据库连接
- [x] 可以在 Settings 中添加 LLM 配置
- [x] 可以在聊天页面选择连接和模型
- [x] 发送查询后能收到流式响应
- [x] 错误时显示友好的提示
- [x] 未登录时无法访问受保护页面

---

**最后更新**: 2026-01-20  
**维护者**: 开发团队  
**问题反馈**: GitHub Issues
