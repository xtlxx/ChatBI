@echo off
REM ========================================
REM ChatBI - 启动脚本
REM ========================================

echo.
echo ========================================
echo   ChatBI 启动工具
echo ========================================
echo.

REM 检查虚拟环境
if not exist ".venv\Scripts\activate.bat" (
    echo [错误] 虚拟环境不存在!
    echo 请先运行: python -m venv .venv
    pause
    exit /b 1
)

echo [1/3] 激活虚拟环境...
call .venv\Scripts\activate.bat

echo [2/3] 启动后端服务 (端口 8000)...
echo.
echo 后端服务将在新窗口启动...
start "ChatBI Backend" cmd /k "cd /d %~dp0backend && ..\\.venv\\Scripts\\uvicorn.exe app:app --reload --host 0.0.0.0 --port 8000"

timeout /t 3 /nobreak >nul

echo [3/3] 启动前端服务 (端口 3000)...
echo.
echo 前端服务将在新窗口启动...
start "ChatBI Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"

echo.
echo ========================================
echo   ✓ 服务启动完成!
echo ========================================
echo.
echo 访问地址:
echo   - 前端: http://localhost:3000
echo   - 后端 API: http://localhost:8000
echo   - API 文档: http://localhost:8000/docs
echo.
echo 提示:
echo   - 后端和前端在独立窗口运行
echo   - 关闭窗口即可停止服务
echo   - 或按 Ctrl+C 停止服务
echo.
pause
