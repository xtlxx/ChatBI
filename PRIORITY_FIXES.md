# 🚨 优先修复任务清单

> **创建时间**: 2026-01-20  
> **预计完成**: 2026-01-27 (1周内)

---

## 🔴 P0 - 阻塞性问题 (今天必须修复)

### 任务 1: 修复 API 端点不匹配
**文件**: `frontend/lib/api-services.ts`  
**问题**: `/query/stream` 端点不存在  
**预计时间**: 30分钟

```typescript
// 修改前 (第118行)
sendMessage: async (payload: ChatRequestPayload) => {
  return await api.stream('/query/stream', payload);  // ❌
}

// 修改后
sendMessage: async (payload: ChatRequestPayload) => {
  return await api.stream('/query', { ...payload, stream: true });  // ✅
}
```

**验证**: 
```bash
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"query":"测试","stream":true}'
```

---

### 任务 2: 后端添加 connection_id 和 llm_config_id 字段
**文件**: `backend/app.py`  
**问题**: QueryRequest 缺少必需字段  
**预计时间**: 15分钟

```python
# 修改 backend/app.py 第57-62行
class QueryRequest(BaseModel):
    """查询请求模型"""
    query: str = Field(..., description="用户查询问题")
    connection_id: int = Field(..., description="数据库连接ID")  # 新增
    llm_config_id: int = Field(..., description="LLM配置ID")    # 新增
    session_id: Optional[str] = Field(default="default", description="会话 ID")
    stream: bool = Field(default=False, description="是否使用流式响应")
    metadata: Optional[Dict[str, Any]] = Field(default=None, description="额外的元数据")
```

**验证**:
```bash
# 启动后端后测试
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"query":"测试","connection_id":1,"llm_config_id":1,"stream":false}'
```

---

### 任务 3: 统一 SSE 响应格式
**文件**: `backend/app.py` OR `frontend/hooks/useChatStream.ts`  
**问题**: 前后端 SSE 事件类型不一致  
**预计时间**: 1小时

**选项 A: 修改后端** (推荐)
```python
# 修改 backend/app.py:360-370
async def stream_agent_response(...):
    try:
        async for event in agent_instance.astream(query, session_id, metadata):
            # 根据 event 类型转换为前端期望格式
            event_type = event.get("type", "unknown")
            
            if event_type == "thought":
                sse_data = {
                    "type": "thought",
                    "content": event.get("content", "")
                }
            elif event_type == "sql_execution":
                sse_data = {
                    "type": "final_output",
                    "content": {
                        "sql": event.get("sql"),
                        "summary": event.get("summary"),
                        "chartOption": event.get("chart_option")
                    }
                }
            else:
                sse_data = {"type": "observation", "content": str(event)}
            
            yield f"data: {json.dumps(sse_data, ensure_ascii=False)}\n\n"
        
        # 发送结束事件
        yield f"data: {json.dumps({'type': 'end'}, ensure_ascii=False)}\n\n"
```

**选项 B: 修改前端** (如果后端无法快速修改)
```typescript
// 修改 frontend/hooks/useChatStream.ts:95-154
for (const line of lines) {
  if (line.startsWith('data: ')) {
    try {
      const envelope = JSON.parse(line.slice(6));
      
      // 检查是否是旧格式 {"type": "event", "data": {...}}
      const event = envelope.type === 'event' ? envelope.data : envelope;
      
      // 处理不同事件类型
      if (event.type === 'thought' || event.thought) {
        updateMessage(aiMessageId, {
          metadata: {
            thoughts: [...(aiMessage.metadata?.thoughts || []), event.content || event.thought]
          }
        });
      } 
      else if (event.type === 'final_output' || (event.sql && event.summary)) {
        const content = event.content || event;
        updateMessage(aiMessageId, {
          content: `**SQL:**\n\`\`\`sql\n${content.sql}\n\`\`\`\n\n**分析:**\n${content.summary}`,
          metadata: {
            sql_query: content.sql,
            chart_data: content.chartOption
          }
        });
      }
      // ... 其他类型
    } catch (parseError) {
      console.error('SSE解析失败:', parseError, line);
    }
  }
}
```

**验证**:
```bash
# 前端Console应该看到正确解析的消息
# 检查 Chrome DevTools > Network > query (EventStream)
```

---

## 🟡 P1 - 高优先级 (本周内完成)

### 任务 4: 实现认证 API 端点
**文件**: 新建 `backend/routes/auth.py`  
**预计时间**: 3-4小时

**步骤**:
1. 创建用户模型 (`backend/models/user.py`)
```python
from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    def verify_password(self, password: str) -> bool:
        return pwd_context.verify(password, self.hashed_password)
    
    @staticmethod
    def hash_password(password: str) -> str:
        return pwd_context.hash(password)
```

2. 创建 JWT 工具 (`backend/utils/jwt.py`)
```python
from datetime import datetime, timedelta
from jose import JWTError, jwt
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

SECRET_KEY = "your-secret-key-here"  # 从环境变量读取
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24小时

security = HTTPBearer()

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        # 从数据库查询用户
        return user_id  # 或返回完整 User 对象
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

3. 创建认证路由 (`backend/routes/auth.py`)
```python
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, EmailStr

router = APIRouter(prefix="/auth", tags=["Authentication"])

class LoginRequest(BaseModel):
    username: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    email: EmailStr
    password: str

@router.post("/login")
async def login(credentials: LoginRequest, db: AsyncSession = Depends(get_db)):
    # 查询用户
    user = await db.execute(select(User).where(User.username == credentials.username))
    user = user.scalar_one_or_none()
    
    if not user or not user.verify_password(credentials.password):
        raise HTTPException(status_code=401, detail="用户名或密码错误")
    
    # 生成 JWT
    token = create_access_token(data={"sub": user.id})
    
    return {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "token": token
    }

@router.post("/register")
async def register(user_data: RegisterRequest, db: AsyncSession = Depends(get_db)):
    # 检查用户名是否存在
    existing = await db.execute(select(User).where(User.username == user_data.username))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="用户名已存在")
    
    # 创建用户
    new_user = User(
        username=user_data.username,
        email=user_data.email,
        hashed_password=User.hash_password(user_data.password)
    )
    db.add(new_user)
    await db.commit()
    
    # 生成 JWT
    token = create_access_token(data={"sub": new_user.id})
    
    return {"id": new_user.id, "username": new_user.username, "token": token}

@router.get("/me")
async def get_current_user_info(user_id: int = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return {"id": user.id, "username": user.username, "email": user.email}
```

4. 注册路由到主应用 (`backend/app.py`)
```python
from routes.auth import router as auth_router

app.include_router(auth_router)
```

**安装依赖**:
```bash
cd backend
pip install python-jose[cryptography] passlib[bcrypt] python-multipart
```

**数据库迁移**:
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**验证**:
```bash
# 注册
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"password123"}'

# 登录
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"password123"}'
```

---

### 任务 5: 实现数据库连接 CRUD API
**文件**: 新建 `backend/routes/connections.py`  
**预计时间**: 2-3小时

**步骤**:
1. 创建数据库模型 (`backend/models/db_connection.py`)
```python
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

class DbConnection(Base):
    __tablename__ = "db_connections"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(20), nullable=False)  # mysql, postgresql, mssql
    host = Column(String(255), nullable=False)
    port = Column(Integer, nullable=False)
    username = Column(String(100), nullable=False)
    password = Column(String(255), nullable=False)  # 应该加密存储
    database_name = Column(String(100), nullable=False)
    
    user = relationship("User", back_populates="connections")
```

2. 创建路由 (`backend/routes/connections.py`)
```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel

router = APIRouter(prefix="/connections", tags=["Database Connections"])

class DbConnectionForm(BaseModel):
    name: str
    type: str  # mysql, postgresql, mssql
    host: str
    port: int
    username: str
    password: str
    database_name: str

class DbConnectionResponse(BaseModel):
    id: int
    name: str
    type: str
    host: str
    port: int
    username: str
    database_name: str
    # 注意: 不返回密码

@router.get("", response_model=list[DbConnectionResponse])
async def get_all_connections(
    current_user_id: int = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(DbConnection).where(DbConnection.user_id == current_user_id)
    )
    connections = result.scalars().all()
    return connections

@router.post("", response_model=DbConnectionResponse)
async def create_connection(
    data: DbConnectionForm,
    current_user_id: int = Depends(get_current_user),  # 从JWT提取
    db: AsyncSession = Depends(get_db)
):
    new_connection = DbConnection(
        user_id=current_user_id,  # ✅ 从JWT获取,不从请求体
        **data.dict()
    )
    db.add(new_connection)
    await db.commit()
    await db.refresh(new_connection)
    return new_connection

@router.post("/test")
async def test_connection(data: DbConnectionForm):
    """测试数据库连接"""
    try:
        if data.type == "mysql":
            import aiomysql
            conn = await aiomysql.connect(
                host=data.host,
                port=data.port,
                user=data.username,
                password=data.password,
                db=data.database_name
            )
            await conn.close()
        # ... 其他数据库类型
        
        return {"success": True, "message": "连接成功"}
    except Exception as e:
        return {"success": False, "message": str(e)}

@router.put("/{id}", response_model=DbConnectionResponse)
async def update_connection(
    id: int,
    data: DbConnectionForm,
    current_user_id: int = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    connection = await db.get(DbConnection, id)
    if not connection or connection.user_id != current_user_id:
        raise HTTPException(status_code=404, detail="连接不存在")
    
    for key, value in data.dict(exclude_unset=True).items():
        setattr(connection, key, value)
    
    await db.commit()
    await db.refresh(connection)
    return connection

@router.delete("/{id}")
async def delete_connection(
    id: int,
    current_user_id: int = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    connection = await db.get(DbConnection, id)
    if not connection or connection.user_id != current_user_id:
        raise HTTPException(status_code=404, detail="连接不存在")
    
    await db.delete(connection)
    await db.commit()
    return {"message": "删除成功"}
```

3. 注册路由
```python
# backend/app.py
from routes.connections import router as connections_router

app.include_router(connections_router)
```

**数据库迁移**:
```sql
CREATE TABLE db_connections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL,
    host VARCHAR(255) NOT NULL,
    port INT NOT NULL,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    database_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**验证**:
```bash
# 创建连接 (需要先登录获取token)
TOKEN="your-jwt-token"
curl -X POST http://localhost:8000/connections \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"生产数据库",
    "type":"mysql",
    "host":"localhost",
    "port":3306,
    "username":"root",
    "password":"password",
    "database_name":"test_db"
  }'

# 获取所有连接
curl http://localhost:8000/connections \
  -H "Authorization: Bearer $TOKEN"
```

---

### 任务 6: 实现 LLM 配置 CRUD API
**文件**: 新建 `backend/routes/llm_configs.py`  
**预计时间**: 1.5小时

**步骤**: 类似任务5,将 `DbConnection` 替换为 `LlmConfig`

**数据库模型**:
```python
class LlmConfig(Base):
    __tablename__ = "llm_configs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    provider = Column(String(50), nullable=False)  # openai, qwen, deepseek
    model_name = Column(String(100), nullable=False)
    api_key = Column(String(255), nullable=False)  # 应该加密存储
    base_url = Column(String(255), nullable=True)
    
    user = relationship("User", back_populates="llm_configs")
```

**路由**: 复制 `connections.py` 并修改端点为 `/llm-configs`

**验证**: 同任务5

---

## 🔵 P2 - 中优先级 (本月内完成)

### 任务 7: 添加表单验证
**文件**: `frontend/app/settings/page.tsx`  
**预计时间**: 2小时

**步骤**:
```bash
# 已安装依赖,只需集成
```

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const dbConnectionSchema = z.object({
  name: z.string().min(1, "名称不能为空").max(100, "名称过长"),
  type: z.enum(["mysql", "postgresql", "mssql"]),
  host: z.string().min(1, "主机名不能为空"),
  port: z.number().int().min(1).max(65535, "端口必须在1-65535之间"),
  username: z.string().min(1, "用户名不能为空"),
  password: z.string().min(1, "密码不能为空"),
  database_name: z.string().min(1, "数据库名不能为空"),
});

const { register, handleSubmit, formState: { errors } } = useForm<DbConnectionForm>({
  resolver: zodResolver(dbConnectionSchema),
  defaultValues: dbForm,
});

const onSubmit = async (data: DbConnectionForm) => {
  await handleSaveDbConnection();
};

// 在JSX中
<form onSubmit={handleSubmit(onSubmit)}>
  <Input {...register("name")} />
  {errors.name && <span className="text-sm text-destructive">{errors.name.message}</span>}
  {/* 其他字段 */}
</form>
```

---

### 任务 8: 添加 Toast 通知
**预计时间**: 1小时

```bash
cd frontend
npx shadcn-ui@latest add toast
```

```typescript
// app/layout.tsx
import { Toaster } from "@/components/ui/toaster"

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Toaster />  {/* 添加 */}
      </body>
    </html>
  )
}

// 使用
import { useToast } from "@/hooks/use-toast"

const { toast } = useToast()

toast({
  title: "成功",
  description: "数据库连接已创建",
})
```

---

### 任务 9: 添加路由保护
**预计时间**: 30分钟

创建 `frontend/middleware.ts` (见 CODE_REVIEW.md 问题6)

---

## ⚪ P3 - 低优先级 (有时间再做)

- [ ] 添加单元测试 (Jest + React Testing Library)
- [ ] 添加 E2E 测试 (Playwright)
- [ ] 优化 UI 组件库使用
- [ ] 添加国际化 (i18n)
- [ ] 性能优化 (React.memo, useMemo)
- [ ] 添加骨架屏加载状态

---

## 📅 每日检查点

### Day 1 (今天)
- [x] 阅读代码审查报告
- [ ] 完成任务 1-3 (P0)
- [ ] 测试基本聊天功能

### Day 2
- [ ] 完成任务 4 (认证API)
- [ ] 前端登录/注册功能测试

### Day 3
- [ ] 完成任务 5 (数据库连接API)
- [ ] Settings 页面数据库配置测试

### Day 4
- [ ] 完成任务 6 (LLM配置API)
- [ ] Settings 页面 LLM 配置测试

### Day 5
- [ ] 完成任务 7-9 (表单验证、Toast、路由保护)
- [ ] 整体功能测试

### Day 6-7
- [ ] Bug 修复
- [ ] 性能优化
- [ ] 文档补充

---

## 🔍 验收标准

完成所有 P0 和 P1 任务后,应该能够:

1. ✅ 用户可以注册/登录
2. ✅ 登录后自动跳转到聊天页面
3. ✅ 可以在 Settings 中添加数据库连接
4. ✅ 可以在 Settings 中添加 LLM 配置
5. ✅ 可以在聊天页面选择连接和模型
6. ✅ 发送查询后能收到流式响应
7. ✅ 错误时显示友好的 Toast 提示
8. ✅ 表单输入有验证反馈
9. ✅ 未登录时无法访问受保护页面

---

**最后更新**: 2026-01-20  
**负责人**: 开发团队  
**审查人**: AI Code Reviewer
