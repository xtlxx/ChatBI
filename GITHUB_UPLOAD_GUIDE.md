# GitHub 上传指南

**项目**: ChatBI  
**仓库地址**: https://github.com/xtlxx/ChatBI.git  
**创建时间**: 2026-01-21

---

## 🎯 上传步骤

### 方式一: 使用 Personal Access Token (推荐)

#### 1. 创建 GitHub Personal Access Token

1. 访问 GitHub: https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 设置:
   - **Note**: `ChatBI Project`
   - **Expiration**: 选择过期时间 (建议 90 days)
   - **Scopes**: 勾选 `repo` (完整仓库访问权限)
4. 点击 "Generate token"
5. **重要**: 复制生成的 token (只显示一次!)

#### 2. 配置 Git 用户信息

```bash
# 设置你的 GitHub 用户名
git config --global user.name "xtlxx"

# 设置你的 GitHub 邮箱 (替换为你的真实邮箱)
git config --global user.email "your-email@example.com"
```

#### 3. 初始化 Git 仓库

```bash
cd d:\Code\KY

# 初始化 Git 仓库
git init

# 添加远程仓库
git remote add origin https://github.com/xtlxx/ChatBI.git

# 验证远程仓库
git remote -v
```

#### 4. 添加文件并提交

```bash
# 查看文件状态
git status

# 添加所有文件 (.gitignore 会自动排除敏感文件)
git add .

# 查看将要提交的文件
git status

# 提交更改
git commit -m "Initial commit: ChatBI - 企业级 AI 数据分析平台

- 基于 LangChain 0.3+ 和 LangGraph 的生产级 Text-to-SQL 系统
- 支持多租户架构和多数据源
- 完整的前后端实现
- 包含详细的文档和配置说明"
```

#### 5. 推送到 GitHub

```bash
# 推送到 main 分支
git branch -M main
git push -u origin main
```

**注意**: 推送时会要求输入用户名和密码:
- **Username**: `xtlxx`
- **Password**: 粘贴你的 Personal Access Token (不是 GitHub 密码!)

---

### 方式二: 使用 SSH Key

#### 1. 生成 SSH Key

```bash
# 生成 SSH 密钥对
ssh-keygen -t ed25519 -C "your-email@example.com"

# 按提示操作:
# - 文件位置: 直接回车 (使用默认位置)
# - 密码: 可以设置或留空

# 查看公钥
cat ~/.ssh/id_ed25519.pub
```

#### 2. 添加 SSH Key 到 GitHub

1. 复制公钥内容
2. 访问 GitHub: https://github.com/settings/keys
3. 点击 "New SSH key"
4. 粘贴公钥,设置标题 (如 "ChatBI Development")
5. 点击 "Add SSH key"

#### 3. 使用 SSH URL

```bash
cd d:\Code\KY

# 初始化并添加远程仓库 (使用 SSH URL)
git init
git remote add origin git@github.com:xtlxx/ChatBI.git

# 添加文件并提交
git add .
git commit -m "Initial commit: ChatBI 企业级 AI 数据分析平台"

# 推送
git branch -M main
git push -u origin main
```

---

### 方式三: 使用 GitHub CLI (最简单)

#### 1. 安装 GitHub CLI

下载并安装: https://cli.github.com/

#### 2. 登录 GitHub

```bash
gh auth login
```

按提示选择:
- GitHub.com
- HTTPS
- 使用浏览器登录

#### 3. 推送代码

```bash
cd d:\Code\KY

# 初始化仓库
git init
git add .
git commit -m "Initial commit: ChatBI 企业级 AI 数据分析平台"

# 创建并推送到 GitHub (自动创建仓库)
gh repo create xtlxx/ChatBI --public --source=. --remote=origin --push
```

---

## ⚠️ 上传前检查清单

### 必须检查的事项:

- [ ] ✅ `.gitignore` 已创建 (已完成)
- [ ] ⚠️ 确认 `.env` 文件已被排除 (包含敏感信息)
- [ ] ⚠️ 确认 `venv/` 目录已被排除 (太大且不需要)
- [ ] ⚠️ 检查是否有其他敏感信息 (API Keys, 密码等)
- [ ] ✅ `README.md` 已创建 (已完成)
- [ ] ✅ `requirements.txt` 已更新 (已完成)

### 验证排除的文件:

```bash
# 查看将要提交的文件
git status

# 查看被忽略的文件
git status --ignored
```

**重要**: 如果看到以下文件,说明 `.gitignore` 工作正常:
- ❌ `.env` (不应该出现)
- ❌ `venv/` (不应该出现)
- ❌ `__pycache__/` (不应该出现)
- ❌ `node_modules/` (不应该出现)

---

## 🔐 安全建议

### 1. 检查敏感文件

在推送前,确保以下文件**不会**被上传:

```bash
# 后端敏感文件
backend/.env
backend/.env.backup
backend/.env.optimized
backend/.env.test

# 前端敏感文件
frontend/.env.local
frontend/.env.production.local
```

### 2. 如果不小心提交了敏感文件

```bash
# 从 Git 历史中移除文件 (但保留本地文件)
git rm --cached backend/.env
git commit -m "Remove sensitive .env file"

# 推送更改
git push origin main --force
```

### 3. 创建 .env.example

为了让其他开发者知道需要哪些环境变量,创建示例文件:

```bash
# 复制 .env 并移除敏感值
cp backend/.env backend/.env.example

# 编辑 .env.example,将真实值替换为占位符
# 例如: ANTHROPIC_API_KEY=your-api-key-here
```

---

## 📝 提交信息规范

建议使用 Conventional Commits 规范:

```bash
# 功能添加
git commit -m "feat: 添加用户认证功能"

# Bug 修复
git commit -m "fix: 修复数据库连接超时问题"

# 文档更新
git commit -m "docs: 更新 README 和 API 文档"

# 代码重构
git commit -m "refactor: 重构 Agent 工作流逻辑"

# 性能优化
git commit -m "perf: 优化 SQL 查询性能"

# 测试
git commit -m "test: 添加单元测试"

# 构建/依赖
git commit -m "build: 更新依赖版本"
```

---

## 🎯 后续操作

### 1. 设置仓库描述

在 GitHub 仓库页面:
1. 点击 "About" 旁边的设置图标
2. 添加描述: `企业级 AI 数据分析平台 - 基于 LangChain 0.3+ 和 LangGraph 的生产级 Text-to-SQL 系统`
3. 添加主题标签: `ai`, `langchain`, `langgraph`, `text-to-sql`, `fastapi`, `nextjs`
4. 设置网站 (如果有部署)

### 2. 创建 Release

```bash
# 创建标签
git tag -a v3.0.0 -m "Release v3.0.0: 初始发布版本"

# 推送标签
git push origin v3.0.0
```

然后在 GitHub 上创建 Release,添加更新日志。

### 3. 启用 GitHub Actions (可选)

创建 `.github/workflows/ci.yml` 实现自动化测试和部署。

---

## 🆘 常见问题

### Q1: 推送时提示 "remote: Repository not found"

**原因**: 仓库不存在或没有访问权限

**解决**:
1. 确认仓库已在 GitHub 创建
2. 检查仓库 URL 是否正确
3. 确认你有推送权限

### Q2: 推送时提示 "Authentication failed"

**原因**: 认证信息错误

**解决**:
- HTTPS: 确认 Personal Access Token 正确
- SSH: 确认 SSH Key 已添加到 GitHub

### Q3: 文件太大无法推送

**原因**: Git 默认限制单文件 100MB

**解决**:
1. 检查是否误提交了大文件 (如 `venv/`, `node_modules/`)
2. 使用 Git LFS 管理大文件
3. 将大文件添加到 `.gitignore`

### Q4: 推送速度很慢

**原因**: 网络问题或文件太多

**解决**:
1. 使用国内 Git 镜像
2. 配置 Git 代理
3. 分批提交文件

---

## 📞 需要帮助?

如果遇到问题,请提供:
1. 执行的命令
2. 完整的错误信息
3. Git 版本 (`git --version`)

我会帮你解决!

---

**准备好了吗? 让我们开始上传代码! 🚀**
