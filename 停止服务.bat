@echo off
REM ========================================
REM ChatBI - 停止服务脚本
REM ========================================

echo.
echo ========================================
echo   ChatBI 停止服务工具
echo ========================================
echo.

echo [1/2] 停止后端服务 (端口 8000)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000 ^| findstr LISTENING') do (
    echo 发现进程 %%a 占用端口 8000
    taskkill /F /PID %%a >nul 2>&1
    if errorlevel 1 (
        echo   - 停止失败或进程不存在
    ) else (
        echo   - ✓ 已停止
    )
)

echo.
echo [2/2] 停止前端服务 (端口 3000)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000 ^| findstr LISTENING') do (
    echo 发现进程 %%a 占用端口 3000
    taskkill /F /PID %%a >nul 2>&1
    if errorlevel 1 (
        echo   - 停止失败或进程不存在
    ) else (
        echo   - ✓ 已停止
    )
)

echo.
echo ========================================
echo   ✓ 服务停止完成!
echo ========================================
echo.
pause
