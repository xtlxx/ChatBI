# KY Data Pilot Pro (ChatBI) — AI 驱动的数据库查询分析平台

> 🤖 通过自然语言对话，自动理解意图、生成 SQL、执行查询、并输出可视化数据分析报告

## 📖 项目简介

KY Data Pilot Pro (原 ChatBI) 是一个企业级 AI SQL 分析平台。用户只需通过自然语言提问（支持文本与语音输入），系统背后的 **LangGraph 状态机 Agent** 会自动完成数据库 Schema 检索、SQL 编写、安全性校验、数据执行以及最终的图表与总结生成。

### 🌟 核心能力与特色

- **智能 Agent 架构** — 基于 LangGraph 构建的“思考 → 检索 → 生成 → 校验 → 执行 → 报告”多步状态图，具备**自我纠错 (Self-Correction)** 与**智能降级 (Fallback)** 机制。
- **极致的安全性** — 
  - 采用黑名单机制，防止 SQL 执行泄露 `password`, `hash`, `token` 等敏感数据。
  - 完全消除 SQL 拼接注入风险，使用 `SQLAlchemy Inspector` 进行跨库安全的元数据探索。
  - 数据库密码和 API Key 采用非对称全量加密存储。
- **多数据库与多模型适配** — 
  - **DB**: 完美兼容 MySQL / PostgreSQL / MSSQL / Oracle / SQLite / ClickHouse。
  - **LLM**: 支持 OpenAI / DeepSeek / 通义千问 / 月之暗面 / Anthropic / Gemini / Ollama。
- **高性能前端体验** — 
  - 基于 React 19 + Vite 构建，引入 **Web Worker** 零拷贝处理录音数据，彻底告别主线程阻塞。
  - SSE 流式输出采用 `requestAnimationFrame` 防抖渲染，长篇报告与图表缩放 (ResizeObserver) 如丝般顺滑。
  - 修复了并发请求导致的状态竞态风暴，路由跳转更加稳定。

## 🏗️ 技术架构

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                            │
│               React 19 + TypeScript + Vite                  │
│    Zustand (持久化状态) + ECharts (响应式图表) + Web Worker │
├─────────────────────────────────────────────────────────────┤
│                         Backend                             │
│                  FastAPI + SQLAlchemy                       │
│ LangGraph (核心状态机) + LangChain (结构化输出 & Prompt)    │
├─────────────────────────────────────────────────────────────┤
│                        Database                             │
│          MySQL (系统状态库) + 用户目标业务数据库            │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 快速开始

### 前置依赖

- **Python** >= 3.10
- **Node.js** >= 20.19 或 22.12+ (注意: 不支持 18.x)
- **MySQL** >= 8.0 (用于存储系统数据)

### 1. 后端启动

```bash
cd backend

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 填入数据库信息

# 初始化数据库
mysql -u root -p chatbi < database_init.sql

# 启动服务
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

### 2. 前端启动

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

### 3. 访问应用

- **前端**: http://localhost:5173
- **后端 API 文档**: http://localhost:8000/docs
- **默认账号**: admin / 123456

## 📁 项目结构

```
ChatBI/
├── backend/                    # 后端服务
│   ├── agent/                  # AI Agent 核心
│   │   ├── graph.py            # LangGraph 状态图 (核心)
│   │   ├── state.py            # Agent 状态定义
│   │   ├── schemas.py          # 结构化输出 Schema
│   │   ├── prompts.py          # Prompt 模板
│   │   └── tools.py            # 数据库工具函数
│   ├── core/                   # 核心模块
│   │   ├── database.py         # 数据库连接管理
│   │   ├── db_adapter.py       # 多数据库方言适配器
│   │   ├── exceptions.py       # 自定义异常体系
│   │   └── security.py         # 安全认证
│   ├── models/                 # SQLAlchemy 数据模型
│   ├── routes/                 # API 路由
│   ├── utils/                  # 工具函数
│   ├── app.py                  # 应用入口
│   ├── config.py               # 配置管理
│   └── database_init.sql       # 数据库初始化脚本
├── frontend/                   # 前端应用
│   ├── src/
│   │   ├── components/         # React 组件
│   │   ├── services/           # API 服务层
│   │   ├── store/              # Zustand 状态管理
│   │   ├── hooks/              # 自定义 Hooks
│   │   ├── types/              # TypeScript 类型定义
│   │   └── locales/            # 国际化 (中/英)
│   └── vite.config.ts
├── docker-compose.yml          # Docker 编排
└── README.md
```

## 🔌 API 概览

| 模块 | 端点 | 说明 |
|------|------|------|
| 认证 | `POST /auth/login` | 用户登录 |
| 认证 | `POST /auth/register` | 用户注册 |
| 查询 | `POST /query` | 同步查询 |
| 查询 | `POST /query/stream` | 流式查询 (SSE) |
| 会话 | `GET /chat/sessions` | 获取会话列表 |
| 会话 | `GET /chat/sessions/{id}` | 获取会话详情 |
| 连接 | `CRUD /connections` | 数据库连接管理 |
| LLM | `CRUD /llm-configs` | LLM 配置管理 |
| 语音 | `POST /speech/recognize` | 语音转文字 |
| 监控 | `GET /health` | 健康检查 |

> 完整 API 文档请访问 `/docs` (Swagger UI)

## 🔧 环境变量

参见 [`backend/.env.example`](backend/.env.example) 和 [`frontend/.env.example`](frontend/.env.example)

## 📄 License

MIT
