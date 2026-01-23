"""
重置 admin 用户密码
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from models.user import User, Base
from config import settings

def reset_admin_user():
    """重置 admin 用户"""
    
    # 创建同步数据库引擎
    sync_url = settings.database_url.replace('aiomysql', 'pymysql')
    engine = create_engine(sync_url, echo=False)
    
    # 创建所有表
    Base.metadata.create_all(engine)
    
    Session = sessionmaker(bind=engine)
    session = Session()
    
    try:
        # 删除所有现有用户
        session.query(User).delete()
        session.commit()
        print("✓ 已删除所有现有用户")
        
        # 创建新的 admin 用户
        admin = User(
            username="admin",
            email="admin@example.com",
            hashed_password=User.hash_password("admin123")
        )
        
        session.add(admin)
        session.commit()
        session.refresh(admin)
        
        print(f"✓ 创建新用户成功!")
        print(f"  ID: {admin.id}")
        print(f"  用户名: {admin.username}")
        print(f"  邮箱: {admin.email}")
        print(f"  密码哈希长度: {len(admin.hashed_password)}")
        
        # 验证密码
        if admin.verify_password("admin123"):
            print(f"✓ 密码验证成功!")
        else:
            print(f"✗ 密码验证失败!")
            
    except Exception as e:
        print(f"✗ 错误: {e}")
        import traceback
        traceback.print_exc()
        session.rollback()
    finally:
        session.close()
        engine.dispose()

if __name__ == "__main__":
    print("=" * 50)
    print("重置 admin 用户密码")
    print("=" * 50)
    print()
    
    reset_admin_user()
    
    print()
    print("=" * 50)
    print("测试账号:")
    print("  用户名: admin")
    print("  密码: admin123")
    print("=" * 50)
