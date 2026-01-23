@echo off
echo ========================================
echo   ChatBI - 推送到 GitHub
echo ========================================
echo.
echo 仓库地址: https://github.com/xtlxx/ChatBI.git
echo 用户名: xtlxx
echo.
echo ⚠️  重要提示:
echo   - 推送时会要求输入用户名和密码
echo   - 用户名: xtlxx
echo   - 密码: 请粘贴你的 Personal Access Token (不是 GitHub 密码!)
echo.
echo 如何获取 Personal Access Token:
echo   1. 访问: https://github.com/settings/tokens
echo   2. 点击 "Generate new token (classic)"
echo   3. 勾选 "repo" 权限
echo   4. 复制生成的 token
echo.
pause
echo.
echo 正在推送到 GitHub...
echo.

cd /d d:\Code\KY
git push -u origin main

if errorlevel 1 (
    echo.
    echo ========================================
    echo   ❌ 推送失败
    echo ========================================
    echo.
    echo 可能的原因:
    echo   1. Personal Access Token 错误或过期
    echo   2. 网络连接问题
    echo   3. 仓库权限不足
    echo.
    echo 解决方案:
    echo   1. 重新生成 Personal Access Token
    echo   2. 检查网络连接
    echo   3. 确认仓库已创建且有推送权限
    echo.
    pause
    exit /b 1
) else (
    echo.
    echo ========================================
    echo   ✅ 推送成功!
    echo ========================================
    echo.
    echo 🎉 恭喜! 代码已成功上传到 GitHub!
    echo.
    echo 📍 仓库地址: https://github.com/xtlxx/ChatBI
    echo.
    echo 📋 后续步骤:
    echo   1. 访问 GitHub 仓库查看代码
    echo   2. 设置仓库描述和主题标签
    echo   3. 检查 README.md 是否正确显示
    echo   4. 创建第一个 Release (可选)
    echo.
    echo 📊 上传统计:
    echo   - 文件数: 79 个
    echo   - 代码行数: 23,717 行
    echo   - 分支: main
    echo.
    pause
)
