import os
import subprocess

def check_ag_env():
    print("🔍 --- Antigravity 环境诊断 ---")
    
    # 1. 检查最直接的环境变量
    vars_to_check = ['PROJECT_ID', 'GOOGLE_CLOUD_PROJECT', 'GCP_PROJECT', 'AG_PROJECT']
    found_any = False
    for var in vars_to_check:
        val = os.environ.get(var)
        print(f"📌 {var}: {'✅ ' + val if val else '❌ 未设置'}")
        if val: found_any = True

    # 2. 检查 gcloud CLI 配置
    print("\n🛰️ --- gcloud 默认项目检查 ---")
    try:
        result = subprocess.run(['gcloud', 'config', 'get-value', 'project'], 
                                capture_output=True, text=True, check=False)
        gcloud_project = result.stdout.strip()
        if gcloud_project:
            print(f"✅ gcloud current project: {gcloud_project}")
        else:
            print("❌ gcloud 未设置默认项目 (可能导致 Antigravity 找不到 fallback)")
    except FileNotFoundError:
        print("⚠️ 未找到 gcloud 命令行工具")

    # 3. 诊断结论
    print("\n💡 --- 诊断建议 ---")
    if not found_any and not gcloud_project:
        print("🚩 结论：你的环境完全没有定义 Project ID。")
        print("👉 请在终端运行: gcloud config set project [你的项目ID]")
    elif "projects/" in "projects/": # 模拟报错逻辑
        print("🚩 结论：变量存在但未被 Antigravity 正确注入。")
        print("👉 请尝试：点击 IDE 左下角头像 'Sign Out'，重启 IDE 后重新登录。")

if __name__ == "__main__":
    check_ag_env()