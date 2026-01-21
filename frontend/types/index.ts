// Database Connection
export interface DbConnection {
  id: number;
  name: string;
  type: 'mysql' | 'postgresql' | 'mssql';
  host: string;
  port: number;
  username: string;
  database_name: string;
  // Note: 'password' is never returned in the list for security
}

// LLM Configuration
export interface LlmConfig {
  id: number;
  provider: string;
  model_name: string;
  base_url?: string;
  // Note: 'api_key' is never returned in the list
}

// Chat Payload (Sent to Backend)
export interface ChatRequestPayload {
  query: string;
  connection_id: number; // ID from the Header Selector
  llm_config_id: number; // ID from the Header Selector
  // No user_id here!
}

// Chat Message Structure
export interface Message {
  id: string;
  role: 'user' | 'ai';
  content: string;
  metadata?: {
    thoughts?: string[];
    sql_query?: string;
    chart_data?: any;
    execution_time?: number;
  };
  isError?: boolean;
}

// User Session
export interface User {
  id: number;
  username: string;
  email: string;
  token: string;
}

// API Response Types
export interface ApiResponse<T> {
  data: T;
  message?: string;
  error?: string;
}

// SSE Stream Types
export interface SSEChunk {
  type: 'thought' | 'observation' | 'final_output' | 'error' | 'end';
  content: any;
}

// Form Types
export interface DbConnectionForm {
  name: string;
  type: 'mysql' | 'postgresql' | 'mssql';
  host: string;
  port: number;
  username: string;
  password: string;
  database_name: string;
}

export interface LlmConfigForm {
  provider: string;
  model_name: string;
  api_key: string;
  base_url?: string;
}

export interface LoginForm {
  username: string;
  password: string;
}

export interface RegisterForm {
  username: string;
  email: string;
  password: string;
  confirm_password: string;
}
