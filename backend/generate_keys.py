"""
安全密钥生成工具
用于生成 JWT_SECRET_KEY 和 ENCRYPTION_KEY
"""
import secrets

print("🔐 生成安全密钥...\n")
print("="*60)

# 生成 JWT 密钥
jwt_key = secrets.token_urlsafe(32)
print("JWT_SECRET_KEY (复制到 .env):")
print(f"JWT_SECRET_KEY={jwt_key}")
print()

# 生成加密密钥
encryption_key = secrets.token_urlsafe(32)
print("ENCRYPTION_KEY (复制到 .env):")
print(f"ENCRYPTION_KEY={encryption_key}")
print()

print("="*60)
print("\n⚠️  重要提醒:")
print("1. 将以上两行复制到 backend/.env 文件")
print("2. 务必备份这些密钥!")
print("3. 加密密钥丢失将导致无法解密数据")
print("4. 生产环境禁止使用示例密钥")
print("\n✅ 密钥生成完成!")
