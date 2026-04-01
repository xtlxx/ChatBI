# Contributing to KY Data Pilot Pro

首先，非常感谢您有兴趣为 **KY Data Pilot Pro (ChatBI)** 贡献代码！我们非常欢迎社区的力量来共同打造这个企业级 AI SQL 分析平台。

本指南将帮助您了解如何参与项目的开发、测试和提交代码。

## 🛠️ 本地开发环境设置

### 1. 后端 (Backend)

后端使用 Python 3.10+ 构建，基于 FastAPI 和 LangGraph。

```bash
cd backend
# 建议使用虚拟环境
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt

# 复制并配置环境变量
cp .env.example .env

# 启动开发服务器
uvicorn app:app --reload --port 8000
```

### 2. 前端 (Frontend)

前端使用 React 19 + TypeScript + Vite 构建。请确保使用 Node.js 20.19 或 22.12+。

```bash
cd frontend
# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

---

## 🏗️ 架构约定与开发规范

在提交 PR 之前，请确保您的代码遵循以下核心原则：

### 1. 安全第一 (Security First)
任何涉及数据库执行的操作都**必须**经过严格的校验：
- 新增的 SQL 操作必须通过 `sqlglot` 的 AST 验证，严禁直接拼接字符串执行。
- 必须确保 `LIMIT` 限制和敏感字段黑名单（如 `password`, `hash`）未被破坏。
- 涉及到密码或 API Key 的存储必须使用 `core/security.py` 中的加密模块。

### 2. 状态机纯洁性 (LangGraph State)
在修改 `agent/graph.py` 时：
- 请确保重试逻辑（Retry）能正确清理前一个节点的错误状态（如 `has_error = False`），避免状态污染。
- 使用 `add_messages` 聚合器管理消息历史，避免死循环导致 Token 爆炸。

### 3. 前端容错渲染 (Resilient UI)
- 任何可能抛出异常的复杂 UI 组件（特别是涉及动态渲染或第三方库，如 ECharts、Markdown 解析等），都应考虑包裹在 `ErrorBoundary` 中。
- 避免在 React 主线程中执行 CPU 密集型任务（如音频转码），请继续利用 `Web Worker`。

---

## 📝 提交代码 (Pull Request)

1. **Fork 本仓库** 并克隆到本地。
2. **创建一个新分支**，命名需具有描述性 (例如：`feature/add-rag-support` 或 `bugfix/fix-chart-resize`)。
3. **编写代码**，并确保通过了 Linter 和类型检查：
   ```bash
   cd frontend
   npm run lint
   npx tsc --noEmit
   ```
4. **提交 Commit**，请使用语义化的 Commit Message，例如：
   - `feat: 增加对 ClickHouse 数据库的支持`
   - `fix: 修复深色模式下图标颜色不可见的问题`
   - `docs: 更新 README 中的架构图`
5. **发起 Pull Request (PR)**，并在描述中清晰地说明您的更改内容、解决的问题以及如何进行测试。

---

## 🗺️ 当前重点需求 (Roadmap)

如果您不知道从哪里开始，可以参考我们在 `README.md` 中的 Roadmap，目前我们非常欢迎在以下方向的 PR：
1. **更低延迟的语音流转录**：将目前的分段录音替换为 WebSocket 实时 VAD 识别。
2. **企业知识库增强 (RAG)**：集成 ChromaDB/Milvus，支持用户上传数据字典以增强 LLM 提示词。
3. **更多的数据库方言支持**：目前已支持 MySQL/PG/SQLite，欢迎补充如 Snowflake, Redshift 等驱动的测试。

再次感谢您的支持！🚀
