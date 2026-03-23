# 前后端集成与前端重构方案

## 1. 现状分析

### 后端架构 (Backend)
- **核心框架**: FastAPI + LangChain/LangGraph + SQLAlchemy (Async).
- **API 模块**:
  - **Auth**: `/auth/login`, `/auth/register` (JWT认证).
  - **Chat**: `/chat/sessions`, `/chat/messages` (会话管理).
  - **Connections**: `/connections` (数据库连接管理, 自动加密).
  - **LLM Configs**: `/llm-configs` (模型配置管理, 自动加密).
  - **Query**: `/query` (核心问答接口, 支持 SSE 流式响应).
  - **Vis**: `/vis` (可视化生成).

### 前端现状 (Frontend)
- **技术栈**: Vite + React 19 + TypeScript + Tailwind CSS.
- **组件库**: Radix UI (Primitives).
- **缺失模块**: 路由管理, 全局状态管理, 统一请求层, 完整业务页面.

## 2. 架构设计方案

### 2.1 目录结构重构
```
src/
├── assets/
├── components/           # 通用 UI 组件
│   ├── ui/               # 基础组件 (Button, Input, etc.)
│   ├── layout/           # 布局组件 (Sidebar, Header)
│   └── business/         # 业务组件 (ChatBox, ConfigForm)
├── hooks/                # 自定义 Hooks (useAuth, useStream)
├── lib/                  # 工具库
│   ├── api.ts            # Axios 封装 (拦截器, 错误处理)
│   ├── utils.ts          # 通用工具
│   └── events.ts         # 事件总线 (可选)
├── pages/                # 页面级组件
│   ├── auth/             # 登录/注册
│   ├── chat/             # 聊天主页
│   ├── settings/         # 设置页 (连接, LLM)
│   └── dashboard/        # 仪表盘 (可选)
├── store/                # 全局状态 (Zustand)
│   ├── auth-store.ts
│   ├── chat-store.ts
│   └── config-store.ts
├── types/                # TypeScript 类型定义
│   ├── api.ts
│   └── models.ts
└── routes/               # 路由配置
```

### 2.2 技术栈补充
需安装以下依赖:
- `react-router-dom`: 路由管理.
- `axios`: HTTP 请求客户端.
- `zustand`: 轻量级全局状态管理.
- `react-markdown` & `remark-gfm`: 渲染 AI Markdown 响应.
- `echarts-for-react`: 图表渲染.
- `react-hot-toast` or `sonner`: 全局 Toast 通知.
- `date-fns`: 日期格式化.

### 2.3 核心模块集成策略

#### A. 统一请求层 (lib/api.ts)
- **Base URL**: `/api` (通过 Vite proxy 转发到后端).
- **拦截器**:
  - Request: 自动附加 `Authorization: Bearer {token}`.
  - Response: 统一处理 401 (跳转登录), 403 (权限不足), 500 (系统错误).
- **Loading**: 结合 Global Loading 状态.

#### B. 认证模块 (Auth)
- **状态**: `useAuthStore` 存储 `user`, `token`, `isAuthenticated`.
- **持久化**: Token 存入 `localStorage`.
- **路由守卫**: `RequireAuth` 组件保护私有路由.

#### C. 聊天模块 (Chat)
- **SSE 流式处理**: 使用 `fetch` 或 `EventSource` 对接 `/query` 接口.
- **状态管理**: 乐观更新 UI (Optimistic UI), 实时追加流式内容.
- **会话管理**: 侧边栏加载 `/chat/sessions`, 自动同步当前会话.

#### D. 配置管理 (Settings)
- **CRUD**: 对接 `/connections` 和 `/llm-configs`.
- **安全性**: 密码/Key 字段仅在编辑模式通过特定接口获取 (后端已支持).
- **测试**: 调用 `/test` 接口验证连接有效性.

## 3. 实施步骤 (Roadmap)

1.  **基础建设**:
    - 安装依赖.
    - 配置 Vite Proxy (解决跨域).
    - 建立目录结构.
    - 封装 `api.ts`.

2.  **认证系统**:
    - 实现 `Login`, `Register` 页面.
    - 实现 `AuthStore`.
    - 配置路由和守卫.

3.  **核心业务 - 设置**:
    - 数据库连接管理 (列表, 新增, 编辑, 测试).
    - LLM 配置管理 (列表, 新增, 编辑, 测试).

4.  **核心业务 - 聊天**:
    - 重构 `MainPlayground` 为 `ChatPage`.
    - 实现 SSE 流式解析器.
    - 集成 Markdown 和 ECharts 渲染.
    - 历史会话侧边栏.

5.  **优化与测试**:
    - 错误边界 (Error Boundary).
    - 性能优化 (Lazy load routes).
    - 端到端测试 (核心流程).

## 4. 接口清单 (API Manifest)

| 模块 | 方法 | 路径 | 描述 |
|------|------|------|------|
| Auth | POST | /auth/login | 用户登录 |
| Auth | POST | /auth/register | 用户注册 |
| Chat | POST | /query | AI 问答 (Stream) |
| Chat | GET | /chat/sessions | 会话列表 |
| Chat | GET | /chat/sessions/{id}/messages | 消息历史 |
| Conn | GET | /connections | 连接列表 |
| Conn | POST | /connections | 创建连接 |
| LLM | GET | /llm-configs | 配置列表 |
| LLM | POST | /llm-configs/test | 连接测试 |
