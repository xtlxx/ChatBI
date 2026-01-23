# routes/chat.py
"""
聊天历史管理API
提供聊天会话和消息的CRUD操作
"""
import logging
import uuid
from typing import List, Annotated, Optional
from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, ConfigDict, Field

from core.database import get_db
from models.chat import ChatSession, ChatMessage
from utils.jwt_auth import get_current_user_id

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/chat",
    tags=["Chat History"]
)

# === 依赖注入定义 ===
DbSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUserId = Annotated[int, Depends(get_current_user_id)]

# === Pydantic 模型 ===

class MessageCreate(BaseModel):
    """创建消息"""
    role: str = Field(..., pattern="^(user|ai|system)$")  # 必须是这三个之一
    content: str = Field(..., min_length=1)
    message_metadata: Optional[dict] = None

class MessageResponse(BaseModel):
    """消息响应"""
    id: int
    session_id: str
    role: str
    content: str
    message_metadata: Optional[dict]
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class SessionCreate(BaseModel):
    """创建会话"""
    title: str = Field(..., min_length=1, max_length=200)

class SessionUpdate(BaseModel):
    """更新会话"""
    title: Optional[str] = Field(None, min_length=1, max_length=200)

class SessionResponse(BaseModel):
    """会话响应"""
    id: str
    title: str
    created_at: datetime
    updated_at: datetime
    message_count: Optional[int] = None  # 消息数量（可选）

    model_config = ConfigDict(from_attributes=True)

class SessionWithMessagesResponse(SessionResponse):
    """带消息的会话响应"""
    messages: List[MessageResponse]

# === API 端点 ===

@router.get("/sessions", response_model=List[SessionResponse])
async def get_sessions(
    user_id: CurrentUserId,
    db: DbSession,
    limit: int = 50,
    offset: int = 0
):
    """
    获取用户的所有聊天会话
    按更新时间倒序排列（最新的在前）
    """
    stmt = (
        select(ChatSession)
        .where(ChatSession.user_id == user_id)
        .order_by(ChatSession.updated_at.desc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    sessions = result.scalars().all()
    
    # 计算每个会话的消息数量
    session_list = []
    for session in sessions:
        # 懒加载消息数量
        msg_count_stmt = select(ChatMessage).where(
            ChatMessage.session_id == session.id
        )
        msg_result = await db.execute(msg_count_stmt)
        message_count = len(msg_result.scalars().all())
        
        session_dict = {
            "id": session.id,
            "title": session.title,
            "created_at": session.created_at,
            "updated_at": session.updated_at,
            "message_count": message_count
        }
        session_list.append(session_dict)
    
    return session_list

@router.post("/sessions", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
async def create_session(
    data: SessionCreate,
    user_id: CurrentUserId,
    db: DbSession
):
    """创建新的聊天会话"""
    new_session = ChatSession(
        id=str(uuid.uuid4()),
        user_id=user_id,
        title=data.title
    )
    
    db.add(new_session)
    await db.commit()
    await db.refresh(new_session)
    
    logger.info(f"User {user_id} created session: {new_session.id}")
    return new_session

@router.get("/sessions/{session_id}", response_model=SessionWithMessagesResponse)
async def get_session_with_messages(
    session_id: str,
    user_id: CurrentUserId,
    db: DbSession
):
    """获取会话及其所有消息"""
    # 验证权限
    stmt = select(ChatSession).where(
        ChatSession.id == session_id,
        ChatSession.user_id == user_id
    )
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="会话不存在或无权访问"
        )
    
    # 获取消息
    msg_stmt = (
        select(ChatMessage)
        .where(ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at.asc())
    )
    msg_result = await db.execute(msg_stmt)
    messages = msg_result.scalars().all()
    
    return {
        "id": session.id,
        "title": session.title,
        "created_at": session.created_at,
        "updated_at": session.updated_at,
        "messages": messages
    }

@router.put("/sessions/{session_id}", response_model=SessionResponse)
async def update_session(
    session_id: str,
    data: SessionUpdate,
    user_id: CurrentUserId,
    db: DbSession
):
    """更新会话（如修改标题）"""
    stmt = select(ChatSession).where(
        ChatSession.id == session_id,
        ChatSession.user_id == user_id
    )
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    
    if not session:
        raise HTTPException(status_code=404, detail="会话不存在")
    
    if data.title:
        session.title = data.title
    
    await db.commit()
    await db.refresh(session)
    return session

@router.delete("/sessions/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_session(
    session_id: str,
    user_id: CurrentUserId,
    db: DbSession
):
    """删除会话及其所有消息"""
    stmt = select(ChatSession).where(
        ChatSession.id == session_id,
        ChatSession.user_id == user_id
    )
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    
    if not session:
        raise HTTPException(status_code=404, detail="会话不存在")
    
    await db.delete(session)
    await db.commit()
    logger.info(f"User {user_id} deleted session: {session_id}")
    return None

@router.post("/sessions/{session_id}/messages", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
async def add_message(
    session_id: str,
    data: MessageCreate,
    user_id: CurrentUserId,
    db: DbSession
):
    """向会话添加消息"""
    # 验证会话存在且属于当前用户
    stmt = select(ChatSession).where(
        ChatSession.id == session_id,
        ChatSession.user_id == user_id
    )
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    
    if not session:
        raise HTTPException(status_code=404, detail="会话不存在")
    
    # 创建消息
    new_message = ChatMessage(
        session_id=session_id,
        role=data.role,
        content=data.content,
        message_metadata=data.message_metadata
    )
    
    db.add(new_message)
    
    # 更新会话的updated_at
    session.updated_at = datetime.utcnow()
    
    await db.commit()
    await db.refresh(new_message)
    
    return new_message

@router.get("/sessions/{session_id}/messages", response_model=List[MessageResponse])
async def get_messages(
    session_id: str,
    user_id: CurrentUserId,
    db: DbSession,
    limit: int = 100,
    offset: int = 0
):
    """获取会话的消息历史"""
    # 验证权限
    stmt = select(ChatSession).where(
        ChatSession.id == session_id,
        ChatSession.user_id == user_id
    )
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    
    if not session:
        raise HTTPException(status_code=404, detail="会话不存在")
    
    # 获取消息
    msg_stmt = (
        select(ChatMessage)
        .where(ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at.asc())
        .limit(limit)
        .offset(offset)
    )
    msg_result = await db.execute(msg_stmt)
    return msg_result.scalars().all()
