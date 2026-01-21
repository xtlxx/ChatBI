#main.py
#使用langchain1.0 前的框架
import os
import asyncio
import json
import logging
import re
from contextlib import asynccontextmanager
from datetime import timedelta
from typing import List, Annotated, Optional, Dict, Any

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from langchain_community.utilities.sql_database import SQLDatabase
from langchain_community.agent_toolkits import SQLDatabaseToolkit
from langchain_community.chat_models.tongyi import ChatTongyi
from langchain.agents import AgentExecutor, create_openai_tools_agent
from langchain.agents.format_scratchpad.openai_tools import format_to_openai_tool_messages
from langchain.agents.output_parsers.openai_tools import OpenAIToolsAgentOutputParser
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.utils.function_calling import convert_to_openai_tool

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
    model_config = SettingsConfigDict(env_file='.env', env_file_encoding='utf-8', extra='ignore')
    DB_HOST: str
    DB_PORT: int
    DB_USER: str
    DB_PASSWORD: str
    DB_NAME: str
    QWEN_API_BASE: str = "https://api.modelscope.cn/v1"
    DASHSCOPE_API_KEY: str
    QWEN_MODEL_NAME: str
    LLM_TEMPERATURE: float = 0.1
    MAX_AGENT_ITERATIONS: int = 15


settings = AppSettings()

# --- 3. 全局资源管理 (Agent, DB) ---
db: SQLDatabase = None
agent_executor: AgentExecutor = None


# --- 4. Pydantic 模型 (包含结构化输出模型) ---
class QueryRequest(BaseModel):
    query: str


class FinalAnswer(BaseModel):
    """用于结构化Agent最终答案的模型。"""
    sql_query: str = Field(
        description="最终执行的、语法完全正确的MySQL查询语句。"
    )
    data_insight: str = Field(
        description="根据查询结果，用清晰、专业的中文自然语言对数据进行总结和洞察。"
    )
    echarts_option: Optional[Dict[str, Any]] = Field(
        default=None,
        description="如果用户的问题适合用图表展示，则提供完全符合Apache ECharts规范的JSON配置对象。否则为null。"
    )


class StructuredQueryResponse(BaseModel):
    """非流式查询的响应模型"""
    sql: Optional[str]
    summary: Optional[str]
    chartOption: Optional[Dict[str, Any]]


# --- 5. FastAPI 应用生命周期管理 (重构核心) ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    global db, agent_executor
    logger.info("应用启动，开始初始化资源...")

    # 数据库初始化
    try:
        db_uri = f"mysql+mysqlconnector://{settings.DB_USER}:{settings.DB_PASSWORD}@{settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_NAME}"
        db = SQLDatabase.from_uri(db_uri, sample_rows_in_table_info=5)
        logger.info("数据库连接成功!")
        logger.info(f"Agent 可用表: {db.get_usable_table_names()}")
    except Exception as e:
        logger.error(f"数据库连接失败: {e}", exc_info=True)
        raise RuntimeError(f"数据库初始化失败: {e}") from e

    # LLM 初始化
    llm = ChatTongyi(
        model_name=settings.QWEN_MODEL_NAME,
        dashscope_api_key=settings.DASHSCOPE_API_KEY,
        temperature=settings.LLM_TEMPERATURE,
        streaming=True,
    )

    # --- Prompt 定义 (已更新为工具调用指令) ---
    SQL_AGENT_PROMPT_SYSTEM = """### 数据库表关系说明
**核心业务表关系**：
1. **订单相关**：
   - od_order_doc (订单主表) ← od_order_doc_article (订单明细)
   - od_order_doc.seq = od_order_doc_article.order_seq
   - od_product_order_doc (生产订单) ← od_product_order_order_position (生产订单明细)

2. **产品相关**：
   - om_article (产品主表，核心表)
   - om_art_position_material (产品物料清单BOM)
   - om_article.seq 被多个表的 art_id 或相关字段引用

3. **出货对账相关**：
   - acc_product_shipment (成品出库表)
   - acc_product_shipment.order_seq → od_order_doc.seq (关联订单)
   - acc_reconciliation (对账主表) ← acc_reconciliation_detail (对账明细)
   - acc_reconciliation ← acc_reconciliation_deduction (扣款明细)
   - acc_reconciliation.seq = acc_reconciliation_deduction.acc_reconciliation_seq

4. **采购相关**：
   - proc_material_procurement (采购主表) ← proc_material_procurement_info (采购明细)
   - proc_material_list (物料清单) ← proc_material_list_info (物料清单明细)
   - proc_material_warehousing (物料入库)
   - proc_material_temporarily_receiving (临时收货)

5. **库存相关**：
   - store (库存主表)
   - store_in_list (入库单)
   - store_out_list (出库单)
   - store_detail_list (库存明细)
   - storehouse (仓库) ← storage (库位)

6. **基础数据**：
   - bas_supplier (供应商)
   - mx_material_info (物料信息) ← mx_material_category (物料分类)
   - t_material_ledger (物料台账)

7. **生产工艺**：
   - sop_manufacturing_process (制造工艺)
   - sop_workshop_section (车间工段)
   - sop_working_procedure (工序)
   - working_procedure (工序定义)

8. **成本报价**：
   - t_standard_cost_budget (标准成本预算)
   - t_material_cost (物料成本)
   - t_mold_cost (模具成本)
   - t_customer_quotation (客户报价)

9. **设备相关**：
   - mac_oee (设备OEE)
   - ods_mac (设备数据)
   - equip_parameter (设备参数)

10. **质量相关**：
   - po_report_yie_id (良率报告)
   - po_defective_product (不良品)
   - po_wms_info_data (仓储信息)

**常用字段说明**：
# 主键
- seq/id: 主键ID（大多数表使用 seq）

# 客户供应商
- customer_id/customer_seq/customer_code/customer_name: 客户相关字段
- supplier_id/supplier_seq/supplier_code/supplier_name: 供应商相关字段

# 产品订单
- art_id/art_seq/art_code/art_name: 产品型体相关字段
- order_seq/order_code/po_no: 订单相关字段
- prou_order_seq: 生产指令号
- od_product_order_code: ERP生产单号

# 物料样品
- material_code/material_name: 物料编码/名称
- sample_order_code/sample_order_seq: 样品单号
- sku/basic_size_code: SKU/尺码

# 数量金额
- quantity/amount: 数量
- actual_amount: 实际数量（注意：actual_num 在部分表中可能有格式问题）
- price/unit_price: 单价
- settlement_quantity/settlement_price/settlement_amount: 结算相关
- currency_type: 币种

# 单据编号
- bill_no: 单据号/对账单号
- shipment_code: 出库单号
- delivery_code: 送货单号

# 时间人员
- created_at/created_by: 创建时间/创建人
- update_at/update_by (或 updated_at/updated_by): 修改时间/修改人
- delete_at/delete_by: 删除时间/删除人

# 状态标记
- del_flag: 删除标记 (0-未删除, 1-已删除)
- is_delete: 是否删除 (0-否, 1-是)
- is_available: 是否可用 (0-可用, 1-不可用)
- status: 状态码

# 其他
- remark: 备注
- brand_name/season: 品牌/季节

**JOIN 查询建议**：

# 订单业务链
- 订单主表→订单明细：od_order_doc JOIN od_order_doc_article ON od_order_doc.seq = od_order_doc_article.order_seq
- 订单→出货：od_order_doc JOIN acc_product_shipment ON od_order_doc.seq = acc_product_shipment.order_seq
- 订单→产品：od_order_doc JOIN om_article ON od_order_doc.art_id = om_article.seq
- 生产订单→生产订单明细：od_product_order_doc JOIN od_product_order_order_position ON od_product_order_doc.seq = od_product_order_order_position.parent_seq

# 产品物料链
- 产品→物料清单(BOM)：om_article JOIN om_art_position_material ON om_article.seq = om_art_position_material.art_id
- 物料信息→物料分类：mx_material_info JOIN mx_material_category ON mx_material_info.category_id = mx_material_category.seq

# 对账业务链
- 对账主表→对账明细：acc_reconciliation JOIN acc_reconciliation_detail ON acc_reconciliation.seq = acc_reconciliation_detail.acc_reconciliation_seq
- 对账主表→扣款明细：acc_reconciliation JOIN acc_reconciliation_deduction ON acc_reconciliation.seq = acc_reconciliation_deduction.acc_reconciliation_seq
- 对账明细→出货记录：acc_reconciliation_detail JOIN acc_product_shipment ON acc_reconciliation_detail.acc_product_shipment_seq = acc_product_shipment.seq

# 采购业务链
- 采购主表→采购明细：proc_material_procurement JOIN proc_material_procurement_info ON proc_material_procurement.seq = proc_material_procurement_info.parent_seq
- 物料清单→物料清单明细：proc_material_list JOIN proc_material_list_info ON proc_material_list.seq = proc_material_list_info.parent_seq
- 采购→供应商：proc_material_procurement JOIN bas_supplier ON proc_material_procurement.supplier_id = bas_supplier.seq
- 物料入库：proc_material_warehousing JOIN mx_material_info ON proc_material_warehousing.material_id = mx_material_info.seq

# 库存业务链
- 库存主表→入库单：store JOIN store_in_list ON store.seq = store_in_list.store_seq
- 库存主表→出库单：store JOIN store_out_list ON store.seq = store_out_list.store_seq
- 库存→库存明细：store JOIN store_detail_list ON store.seq = store_detail_list.store_seq
- 仓库→库位：storehouse JOIN storage ON storehouse.seq = storage.storehouse_id

# 生产工艺链
- 制造工艺→工序：sop_manufacturing_process JOIN sop_working_procedure ON sop_manufacturing_process.seq = sop_working_procedure.process_id
- 车间工段→工序：sop_workshop_section JOIN sop_working_procedure ON sop_workshop_section.seq = sop_working_procedure.section_id

# 成本报价链
- 产品→标准成本：om_article JOIN t_standard_cost_budget ON om_article.seq = t_standard_cost_budget.art_id
- 产品→物料成本：om_article JOIN t_material_cost ON om_article.seq = t_material_cost.art_id
- 产品→模具成本：om_article JOIN t_mold_cost ON om_article.seq = t_mold_cost.art_id
- 产品→客户报价：om_article JOIN t_customer_quotation ON om_article.seq = t_customer_quotation.art_id

# 设备质量链
- 设备OEE→设备数据：mac_oee JOIN ods_mac ON mac_oee.equipment_id = ods_mac.equipment_id
- 设备→设备参数：ods_mac JOIN equip_parameter ON ods_mac.equipment_id = equip_parameter.equipment_id
- 产品→良率报告：om_article JOIN po_report_yie_id ON om_article.seq = po_report_yie_id.art_id
- 产品→不良品记录：om_article JOIN po_defective_product ON om_article.seq = po_defective_product.art_id

# 常用多表关联示例
- 订单完整信息（订单+产品+客户+出货）：
  od_order_doc o 
  JOIN om_article a ON o.art_id = a.seq 
  JOIN acc_product_shipment s ON o.seq = s.order_seq

- 对账完整信息（对账+明细+出货+订单）：
  acc_reconciliation r 
  JOIN acc_reconciliation_detail d ON r.seq = d.acc_reconciliation_seq 
  JOIN acc_product_shipment s ON d.acc_product_shipment_seq = s.seq 
  JOIN od_order_doc o ON s.order_seq = o.seq

- 采购完整信息（采购+明细+供应商+物料）：
  proc_material_procurement p 
  JOIN proc_material_procurement_info i ON p.seq = i.parent_seq 
  JOIN bas_supplier s ON p.supplier_id = s.seq 
  JOIN mx_material_info m ON i.material_id = m.seq

**JOIN 注意事项**：
- 大多数表使用 seq 作为主键
- 关联字段通常命名为 {{表名}}_seq 或 {{表名}}_id
- 注意区分 del_flag=0（未删除）和 is_available=0（可用）的记录
- 多表关联时建议使用表别名（如 o, a, s）提高可读性

### 角色和约束
- **你的角色**: 你是一位融合了资深MySQL数据分析专家与数据可视化专家双重身份的AI助手。
- **核心任务**: 根据用户的问题，安全、准确地生成并执行SQL查询，然后以清晰的“数据洞察”和“可视化图表配置”来呈现结果。
- **安全第一**: 你的查询必须以 `SELECT` 开头。严禁生成任何修改性或定义性语句。
- **基于事实**: 只能查询提供给你的表和字段，不允许猜测或虚构。
- **主动沟通**: 如果用户问题模糊，必须主动提问以获取明确信息。

### 工作流程指南
你必须严格按照 "Thought -> Action -> Action Input -> Observation" 的循环进行思考和行动。

### 图表生成规则
1. **触发条件**: 当用户的提问中明确包含“图”、“表”、“趋势”、“分布”、“占比”等词语时，你**必须**在最终答案中生成图表配置。
2. **图表类型选择**: 根据数据特点选择最合适的图表（折线图、柱状图、饼图等）。

### 最终答案指南 (Final Answer Guide)
当你收集到足够的信息，能够完整回答用户的问题时，你**必须调用 `FinalAnswer` 这个工具**来格式化你的最终输出。
- 将最终执行的SQL语句放入 `sql_query` 字段。
- 将对数据的分析和总结放入 `data_insight` 字段。
- 如果需要图表，请生成 ECharts 的 JSON 配置并放入 `echarts_option` 字段，否则将此字段留空。
**绝对不要**自己编造Markdown或其他格式，**必须**通过调用 `FinalAnswer` 工具来提交最终答案。
"""

    # --- 使用 LCEL 构建 Agent (重构核心) ---
    toolkit = SQLDatabaseToolkit(db=db, llm=llm)
    tools = toolkit.get_tools()

    # 1. 将我们的 Pydantic 模型转换为 LLM 可以调用的 "Tool"
    final_answer_tool = convert_to_openai_tool(FinalAnswer)

    # 2. 将所有工具 (数据库工具 + 最终答案格式化工具) 绑定到 LLM
    #    这样 LLM 就知道它有哪些可用的工具
    llm_with_tools = llm.bind_tools(tools + [final_answer_tool])

    # 3. 创建新的 Prompt 模板
    prompt = ChatPromptTemplate.from_messages([
        ("system", SQL_AGENT_PROMPT_SYSTEM),
        ("user", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ])

    # 4. 构建 Agent 核心逻辑链
    agent = (
            {
                "input": lambda x: x["input"],
                "agent_scratchpad": lambda x: format_to_openai_tool_messages(x["intermediate_steps"]),
            }
            | prompt
            | llm_with_tools
            | OpenAIToolsAgentOutputParser()
    )

    # 5. 创建 Agent Executor
    agent_executor = AgentExecutor(
        agent=agent,
        tools=tools,
        verbose=True,
        handle_parsing_errors="抱歉，我似乎生成了有问题的思考步骤，正在尝试修正。如果问题持续，请尝试换一种方式提问。",
        max_iterations=settings.MAX_AGENT_ITERATIONS,
    )

    logger.info("AI Agent (LCEL with Tool Calling) 初始化完成。")
    yield
    logger.info("应用关闭。")


# --- 6. FastAPI 应用初始化 ---
app = FastAPI(
    title="AI Database Query Assistant API (Refactored)",
    description="一个使用AI Agent查询数据库的API，采用LCEL和工具调用实现结构化输出，支持流式响应和图表生成。",
    version="3.0.0",
    lifespan=lifespan
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- 7. 依赖注入 ---
def get_agent_executor() -> AgentExecutor:
    if agent_executor is None:
        raise HTTPException(status_code=503, detail="AI Agent尚未初始化，请稍后再试。")
    return agent_executor

# --- 8. Authentication Security ---
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


# --- 8. 响应解析 (新版本，极其简单) ---
def extract_final_answer_from_tool_call(agent_response: dict) -> dict:
    """从 Agent 的最终输出中提取 FinalAnswer 工具调用的参数。"""
    final_tool_calls = agent_response.get("tool_calls", [])
    for tool_call in final_tool_calls:
        if tool_call.get("name") == "FinalAnswer":
            args = tool_call.get("args", {})
            return {
                "sql": args.get("sql_query"),
                "summary": args.get("data_insight"),
                "chartOption": args.get("echarts_option"),
            }
    # 如果没有找到 FinalAnswer 工具调用，提供一个降级方案
    return {"summary": agent_response.get("output", "未能解析最终答案，请检查Agent日志。")}


# --- 9. 流式响应处理 (已更新) ---
async def stream_agent_response(query: str, agent: AgentExecutor):
    """
    一个异步生成器，流式传输 Agent 的思考过程，并在最后发送结构化的最终响应。
    """
    try:
        logger.info(f"收到流式查询请求: {query}")
        final_response_chunk = None
        async for chunk in agent.astream({"input": query}):
            if "actions" in chunk:
                for action in chunk["actions"]:
                    sse_data = {"type": "thought", "content": action.log}
                    yield f"data: {json.dumps(sse_data, ensure_ascii=False)}\n\n"
            elif "steps" in chunk:
                for step in chunk["steps"]:
                    sse_data = {"type": "observation", "content": str(step.observation)}
                    yield f"data: {json.dumps(sse_data, ensure_ascii=False)}\n\n"
            elif "output" in chunk:
                # 暂存最后一个包含 output 的块，这通常是最终结果
                final_response_chunk = chunk

        if final_response_chunk:
            parsed_data = extract_final_answer_from_tool_call(final_response_chunk)
            sse_data = {"type": "final_output", "content": parsed_data}
            yield f"data: {json.dumps(sse_data, ensure_ascii=False)}\n\n"

    except Exception as e:
        logger.error(f"流式查询处理失败: {e}", exc_info=True)
        error_message = f"抱歉，处理您的请求时发生了一个内部错误: {e}"
        sse_error = {"type": "error", "content": error_message}
        yield f"data: {json.dumps(sse_error, ensure_ascii=False)}\n\n"
    finally:
        sse_end = {"type": "end"}
        yield f"data: {json.dumps(sse_end, ensure_ascii=False)}\n\n"


# --- 10. API 端点 (已更新) ---

# --- Authentication Endpoints ---
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
    
    # Return user info without creating new token
    return UserResponse(
        id=user["id"],
        username=user["username"],
        email=user["email"],
        token=""  # Empty token for /me endpoint
    )

# --- Query Endpoints ---
@app.post("/query/stream")
async def query_database_stream(request: QueryRequest, agent: Annotated[AgentExecutor, Depends(get_agent_executor)], current_user: str = Depends(get_current_user)):
    return StreamingResponse(stream_agent_response(request.query, agent), media_type="text/event-stream")


@app.post("/query", response_model=StructuredQueryResponse)
async def query_database(request: QueryRequest, agent: Annotated[AgentExecutor, Depends(get_agent_executor)], current_user: str = Depends(get_current_user)):
    try:
        logger.info(f"收到查询请求: {request.query}")
        response_dict = await agent.ainvoke({"input": request.query})
        result = extract_final_answer_from_tool_call(response_dict)
        return result
    except Exception as e:
        logger.error(f"非流式查询处理失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"查询失败: {str(e)}")


@app.get("/")
def read_root():
    return {
        "message": "AI Database Query Assistant is running. Use /query/stream for streaming responses with chart support."}

# --- 运行命令 ---
# uvicorn main_refactored:app --reload

