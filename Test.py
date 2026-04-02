import secrets
import base64

# 生成加密密钥 (32字节)
encryption_key = base64.urlsafe_b64encode(secrets.token_bytes(32)).decode()
print(f"ENCRYPTION_KEY={encryption_key}")

# 生成盐值 (16字节)
salt = base64.urlsafe_b64encode(secrets.token_bytes(16)).decode()
print(f"ENCRYPTION_SALT={salt}")