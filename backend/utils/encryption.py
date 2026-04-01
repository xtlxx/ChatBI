# utils/encryption.py
# 加密工具类
# 使用 Fernet (对称加密) 加密敏感数据
# 基于 AES-128 CBC 模式,简单安全且性能良好
import base64

from cryptography.fernet import Fernet
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC  # 修复导入

from config import settings


class EncryptionManager:
    """
    加密管理器

    使用 config.settings.ENCRYPTION_KEY 作为主密钥
    如果未设置,将使用默认密钥 (仅用于开发,生产环境必须设置)
    """

    def __init__(self):
        """初始化加密管理器"""
        # 从配置获取加密密钥
        encryption_key = settings.ENCRYPTION_KEY

        # 强校验：强制要求必须配置密钥，不区分环境
        if not encryption_key or encryption_key == "default-encryption-key-change-this-in-production":
            raise ValueError(
                    "严重安全错误：未设置 ENCRYPTION_KEY 或正在使用默认值！"
                    "请在环境变量 或 .env 文件中设置强 ENCRYPTION_KEY。"
            )

        # 使用 PBKDF2HMAC 从密鑰派生 Fernet 密鑰
        salt = getattr(settings, "ENCRYPTION_SALT", None)
        if not salt or salt == "chatbi-salt-dev-only":
            raise ValueError(
                    "严重安全错误：未设置 ENCRYPTION_SALT 或正在使用默认值！"
                    "请在环境变量 或 .env 文件中设置强 ENCRYPTION_SALT。"
            )
        
        salt_bytes = salt.encode("utf-8")
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt_bytes,
            iterations=100000,
            backend=default_backend(),
        )
        key = base64.urlsafe_b64encode(kdf.derive(encryption_key.encode()))

        self.cipher = Fernet(key)

    def encrypt(self, plaintext: str) -> bytes:
        """
        加密明文字符串

        Args:
            plaintext: 明文字符串

        Returns:
            加密后的字节数据
        """
        if not plaintext:
            raise ValueError("明文不能为空")

        return self.cipher.encrypt(plaintext.encode("utf-8"))

    def decrypt(self, ciphertext: bytes) -> str:
        """
        解密密文

        Args:
            ciphertext: 加密后的字节数据

        Returns:
            解密后的明文字符串
        """
        if not ciphertext:
            raise ValueError("密文不能为空")

        try:
            decrypted = self.cipher.decrypt(ciphertext)
            return decrypted.decode("utf-8")
        except Exception as e:
            raise ValueError(f"解密失败: {str(e)}") from e


# 创建全局加密管理器实例
encryption_manager = EncryptionManager()


def encrypt_password(password: str) -> bytes:
    """
    加密数据库密码

    Args:
        password: 明文密码

    Returns:
        加密后的密码 (bytes)
    """
    return encryption_manager.encrypt(password)


def decrypt_password(encrypted_password: bytes) -> str:
    """
    解密数据库密码

    Args:
        encrypted_password: 加密后的密码

    Returns:
        明文密码
    """
    return encryption_manager.decrypt(encrypted_password)


def encrypt_api_key(api_key: str) -> bytes:
    """
    加密 API 密钥

    Args:
        api_key: 明文 API 密钥

    Returns:
        加密后的 API 密钥 (bytes)
    """
    return encryption_manager.encrypt(api_key)


def decrypt_api_key(encrypted_api_key: bytes) -> str:
    """
    解密 API 密钥

    Args:
        encrypted_api_key: 加密后的 API 密钥

    Returns:
        明文 API 密钥
    """
    return encryption_manager.decrypt(encrypted_api_key)
