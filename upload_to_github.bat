@echo off
REM ========================================
REM ChatBI - GitHub 自动上传脚本
REM ========================================

echo.
echo ========================================
echo   ChatBI GitHub 上传工具
echo ========================================
echo.

REM 检查是否已初始化 Git
if not exist .git (
    echo [1/6] 初始化 Git 仓库...
    git init
    echo ✓ Git 仓库初始化完成
    echo.
) else (
    echo [1/6] Git 仓库已存在
    echo.
)

REM 检查远程仓库
git remote -v | findstr "origin" >nul 2>&1
if errorlevel 1 (
    echo [2/6] 添加远程仓库...
    echo.
    echo 请选择认证方式:
    echo   1. HTTPS (使用 Personal Access Token)
    echo   2. SSH (使用 SSH Key)
    echo.
    set /p auth_method="请输入选项 (1 或 2): "
    
    if "%auth_method%"=="1" (
        git remote add origin https://github.com/xtlxx/ChatBI.git
        echo ✓ 已添加 HTTPS 远程仓库
    ) else if "%auth_method%"=="2" (
        git remote add origin git@github.com:xtlxx/ChatBI.git
        echo ✓ 已添加 SSH 远程仓库
    ) else (
        echo ✗ 无效选项，使用默认 HTTPS
        git remote add origin https://github.com/xtlxx/ChatBI.git
    )
    echo.
) else (
    echo [2/6] 远程仓库已配置
    git remote -v
    echo.
)

REM 检查 Git 用户配置
git config user.name >nul 2>&1
if errorlevel 1 (
    echo [3/6] 配置 Git 用户信息...
    echo.
    set /p git_username="请输入你的 GitHub 用户名 (默认: xtlxx): "
    if "%git_username%"=="" set git_username=xtlxx
    
    set /p git_email="请输入你的 GitHub 邮箱: "
    
    git config --global user.name "%git_username%"
    git config --global user.email "%git_email%"
    echo ✓ Git 用户信息配置完成
    echo.
) else (
    echo [3/6] Git 用户信息已配置
    echo   用户名: 
    git config user.name
    echo   邮箱: 
    git config user.email
    echo.
)

REM 检查文件状态
echo [4/6] 检查文件状态...
echo.
echo 将要提交的文件:
git status --short
echo.

REM 确认是否继续
set /p confirm="是否继续提交? (y/n): "
if /i not "%confirm%"=="y" (
    echo 已取消上传
    pause
    exit /b
)

REM 添加文件
echo [5/6] 添加文件到暂存区...
git add .
echo ✓ 文件已添加
echo.

REM 提交
echo [6/6] 提交更改...
echo.
set /p commit_msg="请输入提交信息 (留空使用默认): "
if "%commit_msg%"=="" (
    git commit -m "Initial commit: ChatBI - 企业级 AI 数据分析平台" -m "- 基于 LangChain 0.3+ 和 LangGraph 的生产级 Text-to-SQL 系统" -m "- 支持多租户架构和多数据源" -m "- 完整的前后端实现"
) else (
    git commit -m "%commit_msg%"
)
echo ✓ 提交完成
echo.

REM 推送到 GitHub
echo ========================================
echo   准备推送到 GitHub
echo ========================================
echo.
echo 注意: 如果使用 HTTPS，需要输入:
echo   - 用户名: xtlxx
echo   - 密码: 你的 Personal Access Token (不是 GitHub 密码!)
echo.
set /p push_confirm="是否立即推送? (y/n): "
if /i not "%push_confirm%"=="y" (
    echo.
    echo 提交已完成，但未推送到 GitHub
    echo 你可以稍后手动执行: git push -u origin main
    pause
    exit /b
)

echo.
echo 正在推送...
git branch -M main
git push -u origin main

if errorlevel 1 (
    echo.
    echo ✗ 推送失败！
    echo.
    echo 可能的原因:
    echo   1. 认证失败 - 检查 Personal Access Token 或 SSH Key
    echo   2. 仓库不存在 - 需要先在 GitHub 创建仓库
    echo   3. 网络问题 - 检查网络连接
    echo.
    echo 请查看错误信息并参考 GITHUB_UPLOAD_GUIDE.md
    pause
    exit /b 1
) else (
    echo.
    echo ========================================
    echo   ✓ 成功推送到 GitHub!
    echo ========================================
    echo.
    echo 仓库地址: https://github.com/xtlxx/ChatBI
    echo.
    echo 后续步骤:
    echo   1. 访问 GitHub 仓库查看代码
    echo   2. 设置仓库描述和主题标签
    echo   3. 创建 Release (可选)
    echo.
    pause
)
