#main_simplified.py
import os
import asyncio
import json
import logging
from datetime import timedelta
from typing import List, Annotated, Optional, Dict, Any

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict

# Import authentication module
from auth import (
    UserCreate, UserLogin, UserResponse, Token,
    authenticate_user, create_user, create_access_token, verify_token,
    ACCESS_TOKEN_EXPIRE_MINUTES
)

# --- 1. 生产级日志配置 ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

# --- 2. 使用 Pydantic 进行配置管理 ---
class AppSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env.test', env_file_encoding='utf-8', extra='ignore')
    # Minimal required fields for testing
    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = "password"
    DB_NAME: str = "testdb"
    # Optional LLM fields with defaults
    QWEN_API_BASE: str = "https://api.modelscope.cn/v1"
    DASHSCOPE_API_KEY: str = "test_key"
    QWEN_MODEL_NAME: str = "qwen-plus"
    LLM_TEMPERATURE: float = 0.1
    MAX_AGENT_ITERATIONS: int = 15

settings = AppSettings()

# --- 3. Pydantic 模型 ---
class QueryRequest(BaseModel):
    query: str

class FinalAnswer(BaseModel):
    sql_query: str = Field(description="最终执行的、语法完全正确的MySQL查询语句。")
    data_insight: str = Field(description="根据查询结果，用清晰、专业的中文自然语言对数据进行总结和洞察。")
    echarts_option: Optional[Dict[str, Any]] = Field(default=None, description="ECharts配置对象")

class StructuredQueryResponse(BaseModel):
    sql: Optional[str]
    summary: Optional[str]
    chartOption: Optional[Dict[str, Any]]

# --- 4. FastAPI 应用初始化 ---
app = FastAPI(
    title="AI Database Query Assistant API (Simplified)",
    description="A simplified API for authentication and basic queries.",
    version="1.0.0"
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 5. Authentication Security ---
security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Get current user from JWT token."""
    try:
        payload = verify_token(credentials.credentials)
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return username
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

# --- 6. Authentication Endpoints ---
@app.post("/auth/login", response_model=UserResponse)
async def login(user_credentials: UserLogin):
    """Authenticate user and return JWT token."""
    user = authenticate_user(user_credentials.username, user_credentials.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["username"]}, expires_delta=access_token_expires
    )
    
    return UserResponse(
        id=user["id"],
        username=user["username"],
        email=user["email"],
        token=access_token
    )

@app.post("/auth/register", response_model=UserResponse)
async def register(user_data: UserCreate):
    """Register a new user."""
    try:
        user = create_user(user_data)
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user["username"]}, expires_delta=access_token_expires
        )
        
        return UserResponse(
            id=user["id"],
            username=user["username"],
            email=user["email"],
            token=access_token
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Registration failed: {str(e)}"
        )

@app.post("/auth/logout")
async def logout(current_user: str = Depends(get_current_user)):
    """Logout user (client-side token removal)."""
    return {"message": "Successfully logged out"}

@app.get("/auth/me", response_model=UserResponse)
async def get_current_user_info(current_user: str = Depends(get_current_user)):
    """Get current user information."""
    from auth import users_db
    user = users_db.get(current_user)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return UserResponse(
        id=user["id"],
        username=user["username"],
        email=user["email"],
        token=""  # Empty token for /me endpoint
    )

# --- 7. Mock Query Endpoints (for testing) ---
@app.post("/query/stream")
async def query_database_stream(request: QueryRequest, current_user: str = Depends(get_current_user)):
    """Mock streaming endpoint for testing."""
    
    async def generate_mock_response():
        # Simulate thinking process
        yield f"data: {json.dumps({'type': 'thought', 'content': '正在分析您的查询...'})}\n\n"
        await asyncio.sleep(1)
        
        yield f"data: {json.dumps({'type': 'thought', 'content': '生成SQL查询语句...'})}\n\n"
        await asyncio.sleep(1)
        
        # Mock SQL
        mock_sql = "SELECT COUNT(*) as total_users FROM users;"
        yield f"data: {json.dumps({'type': 'final_output', 'content': {'sql': mock_sql, 'summary': '查询完成，这是一个示例响应。', 'chartOption': None}})}\n\n"
        await asyncio.sleep(0.5)
        
        # End signal
        yield f"data: {json.dumps({'type': 'end'})}\n\n"
    
    from fastapi.responses import StreamingResponse
    return StreamingResponse(
        generate_mock_response(),
        media_type="text/event-stream"
    )

@app.post("/query", response_model=StructuredQueryResponse)
async def query_database(request: QueryRequest, current_user: str = Depends(get_current_user)):
    """Mock non-streaming endpoint for testing."""
    mock_sql = "SELECT COUNT(*) as total_users FROM users;"
    return StructuredQueryResponse(
        sql=mock_sql,
        summary="查询完成，这是一个示例响应。",
        chartOption=None
    )

@app.get("/")
def read_root():
    return {
        "message": "AI Database Query Assistant (Simplified) is running.",
        "version": "1.0.0",
        "endpoints": {
            "auth": "/auth/login, /auth/register, /auth/logout, /auth/me",
            "query": "/query, /query/stream"
        }
    }

# --- 运行命令 ---
# uvicorn main_simplified:app --reload --host 0.0.0.0 --port 8000
