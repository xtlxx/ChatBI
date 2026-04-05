export interface User {
  id: number;
  username: string;
  email: string;
  role: string;
  token?: string;
}

export interface LoginResponse extends User {
  token: string;
}

export interface OrderSummary {
  order_month: string;
  total_quantity: number;
}

export interface CustomerProfile {
  id: number;
  name: string;
  code?: string;
  email?: string;
  contact_person?: string;
  phone?: string;
  address?: string;
  business_state?: string;
  payment_type?: string;
  total_orders?: number;
  recent_orders: OrderSummary[];
  cached: boolean;
  query_time_ms: number;
}

// === Database Connections ===

export type DbType = 'mysql' | 'postgresql' | 'sqlite';

export interface DbConnection {
  id: number;
  name: string;
  type: DbType;
  host: string;
  port: number;
  username: string;
  database_name: string;
  // password is never returned in the standard list/get response
}

export interface DbConnectionCreate {
  name: string;
  type: DbType;
  host: string;
  port: number;
  username: string;
  database_name: string;
  password: string;
}

export interface DbConnectionUpdate {
  name?: string;
  type?: DbType;
  host?: string;
  port?: number;
  username?: string;
  database_name?: string;
  password?: string;
}

export interface DbConnectionEditResponse extends DbConnection {
  password: string; // Returned only when specifically requesting for edit
}

export interface ConnectionTestResponse {
  success: boolean;
  message: string;
  duration_ms: number;
  error_detail: string | null;
  timestamp: string | null;
}

export interface StreamEventBase {
  type: string;
  content: unknown;
  done?: boolean;
}

export interface StartEvent extends StreamEventBase {
  type: 'start';
  content: string;
}

export interface ThinkingEvent extends StreamEventBase {
  type: 'thinking';
  content: string;
}

export interface SqlGeneratedEvent extends StreamEventBase {
  type: 'sql_generated';
  content: string; // SQL
  thought?: string;
}

export interface StatusEvent extends StreamEventBase {
  type: 'status';
  content: string;
}

export interface ExecutionResultEvent extends StreamEventBase {
  type: 'execution_result';
  content: string;
  data?: any; // 新增：用于存放原始查询结果
}

export interface ChartOption {
  title?: Record<string, unknown>;
  tooltip?: Record<string, unknown>;
  legend?: Record<string, unknown>;
  grid?: Record<string, unknown>;
  xAxis?: Record<string, unknown> | Record<string, unknown>[];
  yAxis?: Record<string, unknown> | Record<string, unknown>[];
  series: Record<string, unknown>[];
  color?: string[];
  [key: string]: unknown;
}

export interface FinalAnswerEvent extends StreamEventBase {
  type: 'final_answer';
  content: string;
  thinking?: string;
  sql?: string;
  chartOption?: any;
}

export interface AnswerChunkEvent extends StreamEventBase {
  type: 'answer_chunk';
  content: string;
}

export interface ErrorEvent extends StreamEventBase {
  type: 'error';
  content: string;
}

export interface ChartParseErrorEvent extends StreamEventBase {
  type: 'chart_parse_error';
  content: string;
  error_detail?: string;
}

export interface EndEvent extends StreamEventBase {
  type: 'end';
  content: string;
}

export interface ExecutionTimeEvent extends StreamEventBase {
  type: 'execution_time';
  content: string; // 如 "3.45秒"
  seconds: number;
}

export type StreamEvent =
  | StartEvent
  | ThinkingEvent
  | SqlGeneratedEvent
  | StatusEvent
  | ExecutionResultEvent
  | FinalAnswerEvent
  | AnswerChunkEvent
  | ErrorEvent
  | ChartParseErrorEvent
  | EndEvent
  | ExecutionTimeEvent;

// === LLM Configurations ===

export type LlmProvider = 'openai' | 'anthropic' | 'gemini' | 'deepseek' | 'qwen' | 'moonshot' | 'ollama' | 'other';

export interface LlmConfig {
  id: number;
  provider: LlmProvider;
  model_name: string;
  base_url?: string;
  temperature: number;
  // api_key is never returned in the standard list/get response
}

export interface LlmConfigCreate {
  provider: LlmProvider;
  model_name: string;
  base_url?: string;
  temperature?: number;
  api_key: string;
}

export interface LlmConfigUpdate {
  provider?: LlmProvider;
  model_name?: string;
  base_url?: string;
  temperature?: number;
  api_key?: string;
}

export interface LlmConfigEditResponse extends LlmConfig {
  api_key: string; // Returned only when specifically requesting for edit
}

// eslint-disable-next-line @typescript-eslint/no-empty-object-type
export interface LlmTestRequest extends LlmConfigCreate { }

export interface LlmTestResponse {
  success: boolean;
  message: string;
  duration_ms?: number;
  status_code?: number;
  error_detail?: string;
  timestamp?: string;
}

// === Chat & Messages ===

export interface ChatSession {
  id: string;
  title: string | null;
  created_at: string | null;
  updated_at: string | null;
  message_count?: number;
}

export interface SessionCreate {
  title: string;
}

export interface SessionUpdate {
  title?: string;
}

export type MessageRole = 'user' | 'ai' | 'system';
export type FeedbackType = 'like' | 'dislike' | 'none';

export interface ChatMessage {
  id: number;
  session_id: string;
  role: MessageRole;
  content: string | null;
  message_metadata?: {
    sql_query?: string;
    chartOption?: ChartOption;
    chart_data?: unknown;
    data?: unknown;
    thinking?: string;
    [key: string]: unknown;
  };
  feedback?: FeedbackType;
  feedback_text?: string;
  created_at: string | null;
}



export interface SessionWithMessages extends ChatSession {
  messages: ChatMessage[];
}

// === Query/Execution ===

export interface QueryRequest {
  query: string;
  connection_id: number;
  llm_config_id: number;
  session_id?: string;
  stream?: boolean;
  metadata?: Record<string, unknown>;
}

export interface QueryResponse {
  summary?: string;
  sql?: string;
  chartOption?: ChartOption;
  data?: unknown;
  thinking?: string;
  error?: string;
  session_id: string;
}
