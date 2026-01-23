# CORS 问题解决方案

**错误**: Network Error / CORS policy blocked

**最后更新**: 2026-01-21 12:23

---

## ✅ 已完成的修复

### 1. 添加 `expose_headers`

修改了 `backend/app.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],  # 新增
)
```

### 2. 添加健康检查端点

添加了 `/health` 端点用于测试 CORS

---

## 🔄 需要重启服务

后端代码已更新,但需要确认服务已重新加载:

### 检查后端日志

查看后端终端,应该看到:
```
INFO:     Detected file change in 'app.py'
INFO:     Reloading...
INFO:     Application startup complete.
```

### 如果没有自动重载

手动重启后端:
1. 在后端终端按 `Ctrl+C` 停止
2. 重新运行:
   ```bash
   cd backend
   ..\.venv\Scripts\uvicorn.exe app:app --reload --host 0.0.0.0 --port 8000
   ```

---

## 🧪 测试 CORS

### 1. 测试健康检查

在浏览器控制台执行:
```javascript
fetch('http://localhost:8000/health')
  .then(res => res.json())
  .then(data => console.log('健康检查:', data))
  .catch(err => console.error('错误:', err));
```

**期望输出**:
```javascript
健康检查: {
  status: "healthy",
  database: "connected",
  agent: "initialized",
  memory: "initialized",
  version: "3.0.0"
}
```

### 2. 测试登录 API

```javascript
fetch('http://localhost:8000/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    username: 'admin',
    password: 'admin123'
  })
})
.then(res => {
  console.log('状态码:', res.status);
  console.log('响应头:', res.headers);
  return res.json();
})
.then(data => console.log('登录成功:', data))
.catch(err => console.error('登录失败:', err));
```

---

## 🔍 如果仍然失败

### 检查 1: 确认 ALLOWED_ORIGINS

查看 `backend/.env`:
```bash
ALLOWED_ORIGINS=["http://localhost:3000","http://127.0.0.1:3000"]
```

### 检查 2: 确认前端地址

前端运行在哪个地址?
- http://localhost:3000 ✅
- http://127.0.0.1:3000 ✅
- 其他地址? 需要添加到 ALLOWED_ORIGINS

### 检查 3: 浏览器缓存

清除浏览器缓存:
```javascript
// 在控制台执行
localStorage.clear();
sessionStorage.clear();
location.reload(true);
```

### 检查 4: 防火墙/代理

- 检查是否有防火墙阻止
- 检查是否使用了代理
- 尝试关闭 VPN

---

## 🛠️ 临时解决方案

如果 CORS 仍然有问题,可以临时使用代理:

### 方式 1: Next.js 代理 (已配置)

`frontend/next.config.js` 已配置代理:
```javascript
async rewrites() {
  return [
    {
      source: '/api/:path*',
      destination: 'http://localhost:8000/:path*',
    },
  ]
}
```

**使用方式**:
修改前端 API 调用,使用 `/api` 前缀:
```typescript
// 原来
fetch('http://localhost:8000/auth/login', ...)

// 改为
fetch('/api/auth/login', ...)
```

### 方式 2: 开发模式禁用 CORS 检查

**Chrome**:
```bash
chrome.exe --disable-web-security --user-data-dir="C:/temp/chrome"
```

**注意**: 仅用于开发,不要在生产环境使用!

---

## 📝 完整的 CORS 配置

### backend/app.py

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,  # 允许的源
    allow_credentials=True,                   # 允许携带凭证
    allow_methods=["*"],                      # 允许所有方法
    allow_headers=["*"],                      # 允许所有请求头
    expose_headers=["*"],                     # 暴露所有响应头
)
```

### backend/.env

```bash
ALLOWED_ORIGINS=["http://localhost:3000","http://127.0.0.1:3000","http://localhost:5173","http://127.0.0.1:5173"]
```

---

## 🎯 下一步

1. **确认后端已重启** - 查看终端日志
2. **刷新前端页面** - Ctrl+F5 强制刷新
3. **清除浏览器缓存** - localStorage.clear()
4. **重新尝试登录** - 使用 admin/admin123
5. **查看控制台** - 检查是否还有 CORS 错误

---

**如果还是不行,请告诉我:**
1. 后端终端的完整日志
2. 浏览器控制台的完整错误
3. Network 标签中 login 请求的详细信息

**我会继续帮你解决! 🔧**
