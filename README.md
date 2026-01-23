# ChatBI - 企业级 AI 数据分析平台

<div align="center">

**基于 LangChain 0.3+ 和 LangGraph 构建的生产级 Text-to-SQL 分析系统**

[![Python](https://img.shields.io/badge/Python-3.14.0-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115.0-009688.svg)](https://fastapi.tiangolo.com/)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black.svg)](https://nextjs.org/)
[![LangChain](https://img.shields.io/badge/LangChain-0.3.25-green.svg)](https://python.langchain.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## 📋 目录

- [项目简介](#-项目简介)
- [核心特性](#-核心特性)
- [技术栈](#-技术栈)
- [系统架构](#-系统架构)
- [快速开始](#-快速开始)
- [项目结构](#-项目结构)
- [配置说明](#-配置说明)
- [部署指南](#-部署指南)
- [开发指南](#-开发指南)
- [常见问题](#-常见问题)
- [贡献指南](#-贡献指南)
- [许可证](#-许可证)

---

## 🎯 项目简介

ChatBI 是一个企业级的 AI 数据分析平台,允许用户通过自然语言与数据库进行交互。系统支持多租户架构,用户可以配置多个数据库连接和 LLM 模型,实现智能化的数据查询和可视化分析。

### 核心价值

- **降低数据分析门槛** - 无需 SQL 知识,自然语言即可查询
- **提升分析效率** - AI 自动生成 SQL 和可视化图表
- **企业级安全** - 多租户隔离、JWT 认证、数据加密
- **灵活配置** - 支持多种数据库和 LLM 模型

---

## ✨ 核心特性

### 🤖 AI 能力

- **智能 SQL 生成** - 基于 LangGraph 的 Agent 架构,自动生成优化的 SQL 查询
- **上下文理解** - 多层次对话记忆(短期、摘要、实体)
- **流式响应** - Server-Sent Events (SSE) 实时输出思考过程
- **自动可视化** - 智能生成 ECharts 图表配置

### 🏢 企业特性

- **多租户架构** - 完整的用户认证和数据隔离
- **多数据源支持** - MySQL、PostgreSQL、MS SQL Server
- **多 LLM 支持** - Claude、OpenAI、Qwen、DeepSeek
- **配置管理** - 灵活的数据库连接和 LLM 配置

### 🔐 安全性

- **JWT 认证** - 基于 Token 的安全认证机制
- **数据加密** - 敏感信息加密存储(Fernet)
- **SQL 注入防护** - 只读查询限制和参数化查询
- **CORS 配置** - 可配置的跨域访问控制

### 📊 可观测性

- **LangSmith 追踪** - 完整的 Agent 执行轨迹
- **Prometheus 指标** - 性能监控和告警
- **结构化日志** - JSON 格式日志便于分析
- **健康检查** - 完善的服务健康监控

---

## 🛠️ 技术栈

### 后端 (Backend)

| 类别 | 技术 | 版本 | 说明 |
|------|------|------|------|
| **框架** | FastAPI | 0.115.0 | 高性能异步 Web 框架 |
| **AI/LLM** | LangChain | 0.3.25 | LLM 应用开发框架 |
| **Agent** | LangGraph | 0.2.45 | 状态图驱动的 Agent 架构 |
| **LLM** | Claude Sonnet 4.5 | - | Anthropic 最新旗舰模型 |
| **嵌入** | Voyage AI | 0.3.7 | Anthropic 官方推荐 |
| **数据库** | SQLAlchemy | 2.0.36 | 异步 ORM |
| **缓存** | Redis | 5.2.0 | 高性能缓存 |
| **监控** | LangSmith | 0.1.143 | LLM 应用追踪 |
| **指标** | Prometheus | 0.21.0 | 监控和告警 |

### 前端 (Frontend)

| 类别 | 技术 | 说明 |
|------|------|------|
| **框架** | Next.js 14+ | React 全栈框架(App Router) |
| **语言** | TypeScript | 类型安全 |
| **状态管理** | Zustand | 轻量级状态管理 |
| **UI 库** | Shadcn/UI | Radix UI + Tailwind CSS |
| **表单** | React Hook Form + Zod | 表单验证 |
| **可视化** | ECharts | 数据图表 |
| **Markdown** | react-markdown | Markdown 渲染 |

---

## 🏗️ 系统架构

### 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                         用户界面                              │
│                    (Next.js + TypeScript)                    │
└───────────────────────┬─────────────────────────────────────┘
                        │ HTTP/SSE
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      API 网关层                               │
│                    (FastAPI + CORS)                          │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  认证服务     │ │  连接管理     │ │  查询服务     │
│  (JWT Auth)  │ │ (Connections) │ │ (LangGraph)  │
└──────────────┘ └──────────────┘ └──────┬───────┘
                                          │
                        ┌─────────────────┼─────────────────┐
                        │                 │                 │
                        ▼                 ▼                 ▼
                ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
                │   LLM 服务    │  │  向量数据库   │  │  目标数据库   │
                │   (Claude)   │  │  (Pinecone)  │  │ (MySQL/PG)   │
                └──────────────┘  └──────────────┘  └──────────────┘
```

### LangGraph Agent 工作流

```
用户查询 → Agent 推理 → 工具调用 → 结果生成
              ↓           ↓           ↓
          Claude API   SQL执行    图表生成
              ↓           ↓           ↓
          记忆管理    数据库      ECharts配置
```

---

## 🚀 快速开始

### 环境要求

- **Node.js** 18+
- **Python** 3.14.0
- **MySQL** 5.7+ / **PostgreSQL** 12+ / **MS SQL Server** 2019+
- **Redis** 6.0+ (可选,用于缓存)

### 1. 克隆项目

```bash
git clone https://github.com/your-org/chatbi.git
cd chatbi
```

### 2. 后端设置

```bash
# 进入后端目录
cd backend

# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件,填入你的配置

# 初始化数据库
python -c "from models import Base; from config import settings; from sqlalchemy import create_engine; engine = create_engine(settings.database_url.replace('aiomysql', 'pymysql')); Base.metadata.create_all(engine)"

# 启动服务
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

### 3. 前端设置

```bash
# 进入前端目录
cd frontend

# 安装依赖
npm install

# 配置环境变量
cp .env.example .env.local
# 编辑 .env.local 文件

# 启动开发服务器
npm run dev
```

### 4. 访问应用

- **前端**: http://localhost:3000
- **后端 API 文档**: http://localhost:8000/docs
- **健康检查**: http://localhost:8000/health

---

## 📁 项目结构

```
chatbi/
├── backend/                    # 后端服务
│   ├── agent/                 # LangGraph Agent 核心
│   │   ├── graph.py          # 状态图定义
│   │   ├── state.py          # 状态结构
│   │   ├── tools.py          # Agent 工具
│   │   ├── prompts.py        # 提示词模板
│   │   └── memory.py         # 记忆管理
│   ├── models/               # 数据模型
│   │   ├── user.py          # 用户模型
│   │   ├── db_connection.py # 数据库连接模型
│   │   └── llm_config.py    # LLM 配置模型
│   ├── routes/              # API 路由
│   │   ├── auth.py         # 认证路由
│   │   ├── connections.py  # 连接管理路由
│   │   └── llm_configs.py  # LLM 配置路由
│   ├── utils/              # 工具函数
│   │   ├── jwt_auth.py    # JWT 认证
│   │   ├── encryption.py  # 数据加密
│   │   └── agent_factory.py # Agent 工厂
│   ├── app.py             # FastAPI 应用入口
│   ├── config.py          # 配置管理
│   ├── logging_config.py  # 日志配置
│   └── requirements.txt   # Python 依赖
│
├── frontend/                  # 前端应用
│   ├── app/                  # Next.js App Router
│   │   ├── chat/            # 聊天界面
│   │   ├── settings/        # 配置管理
│   │   ├── login/           # 登录页面
│   │   └── register/        # 注册页面
│   ├── components/          # React 组件
│   │   └── ui/             # UI 组件库
│   ├── hooks/              # 自定义 Hooks
│   │   └── useChatStream.ts # SSE 流式处理
│   ├── lib/                # 工具库
│   │   ├── api.ts         # API 客户端
│   │   └── api-services.ts # API 服务
│   ├── store/             # 状态管理
│   │   └── useAppStore.ts # Zustand Store
│   ├── types/             # TypeScript 类型
│   └── package.json       # npm 依赖
│
├── docs/                     # 文档
│   ├── API.md               # API 文档
│   ├── DEPLOYMENT.md        # 部署指南
│   └── DEVELOPMENT.md       # 开发指南
│
└── README.md                # 本文件
```

---

## ⚙️ 配置说明

### 后端环境变量 (.env)

```bash
# === 数据库配置 ===
DB_HOST=localhost
DB_PORT=3306
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=chatbi

# === LLM 配置 (Anthropic) ===
ANTHROPIC_API_KEY=sk-ant-xxx
ANTHROPIC_MODEL=claude-3-sonnet-20240229

# === LLM 配置 (OpenAI 兼容 - 如 Qwen/DeepSeek) ===
# OPENAI_API_KEY=sk-xxx
# OPENAI_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
# OPENAI_MODEL_NAME=qwen-turbo

LLM_TEMPERATURE=0.1
LLM_MAX_TOKENS=4096

# === 嵌入模型 ===
VOYAGE_API_KEY=pa-xxx
VOYAGE_MODEL=voyage-3-large

# === 向量数据库 (可选) ===
PINECOONE_API_KEY=xxx
PINECONE_ENVIRONMENT=us-east-1-aws
PINECONE_INDEX_NAME=chatbi-knowledge

# === Redis 缓存 (可选) ===
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# === LangSmith 追踪 (可选) ===
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=lsv2_xxx
LANGCHAIN_PROJECT=chatbi-production

# === 安全配置 ===
JWT_SECRET_KEY=your-secret-key-change-this
ENCRYPTION_KEY=your-32-byte-fernet-key
ALLOWED_ORIGINS=["http://localhost:3000"]

# === 监控配置 ===
ENABLE_METRICS=true
LOG_LEVEL=INFO
```

### 前端环境变量 (.env.local)

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

---

## 🚢 部署指南

### Docker 部署

#### 1. 构建镜像

```bash
# 后端
cd backend
docker build -t chatbi-backend .

# 前端
cd frontend
docker build -t chatbi-frontend .
```

#### 2. Docker Compose

```yaml
version: '3.8'

services:
  backend:
    image: chatbi-backend
    ports:
      - "8000:8000"
    env_file:
      - backend/.env
    depends_on:
      - mysql
      - redis

  frontend:
    image: chatbi-frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_BASE_URL=http://backend:8000

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: chatbi
    volumes:
      - mysql_data:/var/lib/mysql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  mysql_data:
```

#### 3. 启动服务

```bash
docker-compose up -d
```

### Kubernetes 部署

参考 `docs/DEPLOYMENT.md` 获取详细的 K8s 部署配置。

---

## 👨‍💻 开发指南

### 后端开发

```bash
# 运行测试
pytest tests/ -v

# 代码格式化
black .
ruff check --fix .

# 类型检查
mypy .

# 启动开发服务器
uvicorn app:app --reload
```

### 前端开发

```bash
# 运行测试
npm run test

# 代码检查
npm run lint

# 类型检查
npm run type-check

# 构建生产版本
npm run build
```

### API 测试

访问 http://localhost:8000/docs 使用 Swagger UI 进行交互式 API 测试。

---

## ❓ 常见问题

### 1. 如何添加新的数据库类型?

在 `backend/models/db_connection.py` 中添加新的数据库类型,并在 `backend/utils/agent_factory.py` 中实现连接逻辑。

### 2. 如何切换 LLM 模型?

在设置页面添加新的 LLM 配置，支持所有兼容 OpenAI 接口的模型（如 DeepSeek, Qwen 等）。或者在 `.env` 文件中配置默认模型。

### 3. 登录后一直重定向回登录页?

这通常是由于 Cookie 设置问题导致的。请确保：
1. 浏览器允许第三方 Cookie（如果在不同域名下开发）。
2. 后端 `.env` 中的 `ALLOWED_ORIGINS` 包含前端地址。
3. 系统时间准确（JWT Token 依赖时间）。

### 4. 图表无法显示?

系统使用智能正则匹配从 AI 回复中提取 ECharts 配置。如果图表未显示：
1. 检查 AI 回复中是否包含 `Analysis` 或 JSON 数据。
2. 尝试在提示词中明确要求："请生成 ECharts JSON 配置"。
3. 确保 LLM 模型具有较强的指令遵循能力（推荐 Claude 3.5 或 GPT-4）。

### 5. 如何启用 LangSmith 追踪?

设置环境变量:
```bash
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=your-langsmith-key
LANGCHAIN_PROJECT=your-project-name
```

### 6. 如何优化查询性能?

- 启用 Redis 缓存
- 配置合适的数据库连接池大小
- 使用 Pinecone 向量数据库加速语义搜索

---

## 🤝 贡献指南

我们欢迎所有形式的贡献!

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范

- 后端: 遵循 PEP 8,使用 Black 格式化
- 前端: 遵循 Airbnb JavaScript Style Guide
- 提交信息: 使用 Conventional Commits 规范

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- [LangChain](https://python.langchain.com/) - LLM 应用开发框架
- [Anthropic](https://www.anthropic.com/) - Claude AI 模型
- [FastAPI](https://fastapi.tiangolo.com/) - 现代 Python Web 框架
- [Next.js](https://nextjs.org/) - React 全栈框架

---

## 📞 联系我们

- **问题反馈**: [GitHub Issues](https://github.com/your-org/chatbi/issues)
- **功能建议**: [GitHub Discussions](https://github.com/your-org/chatbi/discussions)
- **邮件**: support@chatbi.example.com

---

<div align="center">

**⭐ 如果这个项目对你有帮助,请给我们一个 Star! ⭐**

构建时间: 2026-01-21 | 版本: 3.0.0 | 作者: ChatBI Team

</div>
