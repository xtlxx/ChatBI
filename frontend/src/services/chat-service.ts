import api from '@/lib/api';
import i18n from '@/lib/i18n';
import type { 
  ChatSession, 
  SessionCreate, 
  SessionUpdate, 
  SessionWithMessages, 
  QueryRequest,
  QueryResponse,
  StreamEvent
} from '@/types/api';
import { useAuthStore } from '@/store/auth-store';

export const chatService = {
  getSessions: async (limit = 50, offset = 0) => {
    const response = await api.get<ChatSession[]>('/chat/sessions', {
      params: { limit, offset }
    });
    return response.data;
  },

  createSession: async (data: SessionCreate) => {
    const response = await api.post<ChatSession>('/chat/sessions', data);
    return response.data;
  },

  getSession: async (sessionId: string) => {
    const response = await api.get<SessionWithMessages>(`/chat/sessions/${sessionId}`);
    return response.data;
  },

  updateSession: async (sessionId: string, data: SessionUpdate) => {
    const response = await api.put<ChatSession>(`/chat/sessions/${sessionId}`, data);
    return response.data;
  },

  // Non-streaming query
  sendMessage: async (data: QueryRequest) => {
    const response = await api.post<QueryResponse>('/query', data);
    return response.data;
  },

  // Streaming query
  sendMessageStream: async (
    data: QueryRequest, 
    onChunk: (event: StreamEvent) => void,
    onError: (err: Error) => void,
    onComplete: () => void
  ) => {
    try {
      const token = useAuthStore.getState().token;
      if (!token) {
        throw new Error(i18n.t('errors.unauthorized'));
      }
      
      console.log('[ChatService] Starting stream request to /api/query/stream');
      
      // Use the dedicated streaming endpoint for better feature support (e.g. few-shot)
      const response = await fetch('/api/query/stream', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        if (response.status === 401) {
            useAuthStore.getState().logout();
            window.location.href = '/login';
            throw new Error(i18n.t('errors.unauthorized'));
        }

        const errorText = await response.text();
        console.error(`Stream request failed: status=${response.status} statusText=${response.statusText} body=${errorText}`);
        let errorMsg = i18n.t('errors.streamFailed');
        try {
            const errorJson = JSON.parse(errorText);
            if (errorJson.detail) errorMsg = errorJson.detail;
        } catch (e) {
            console.error('Failed to parse error response:', errorText);
        }
        throw new Error(`Stream request failed (${response.status}): ${errorMsg}`);
      }

      const reader = response.body?.getReader();
      const decoder = new TextDecoder();
      let buffer = '';

      if (!reader) throw new Error(i18n.t('errors.noResponseBody'));

      // 增加一个标记，用于检测是否真的收到了数据
      let hasReceivedData = false;

      try {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          
          hasReceivedData = true;
          const chunk = decoder.decode(value, { stream: true });
          buffer += chunk;
          
          const lines = buffer.split('\n\n');
          // Keep the last part if it's incomplete
          buffer = lines.pop() || ''; 
          
          for (const line of lines) {
             if (line.trim().startsWith('data: ')) {
                 const jsonStr = line.trim().substring(6);
                 try {
                     const event = JSON.parse(jsonStr) as StreamEvent;
                     onChunk(event);
                     
                     // Handle explicit done signal from backend
                     if (event.done) {
                         return onComplete();
                     }
                 } catch (e) {
                     console.error('Failed to parse SSE JSON', e);
                 }
             }
          }
        }
        
        // Process any remaining buffer
        if (buffer.trim()) {
          const lines = buffer.split('\n\n');
          for (const line of lines) {
              if (line.trim().startsWith('data: ')) {
                  const jsonStr = line.trim().substring(6);
                  try {
                      const event = JSON.parse(jsonStr) as StreamEvent;
                      onChunk(event);
                  } catch (e) {
                      console.error('Failed to parse SSE JSON from remaining buffer', e);
                  }
              }
          }
        }
        
        onComplete();
      } catch (error: any) {
         console.error("Stream reading error:", error);
         // 如果已经收到了数据，但中途断开，可能是一个不完整的流
         // 这种情况下，我们抛出一个特定的错误，或者只是让前端显示"网络中断"
         if (hasReceivedData) {
             // 尝试通知 UI 流被中断了，但保留已有的内容
             onChunk({
                 type: 'error',
                 content: '\n\n*(网络连接已中断，以上为部分生成内容)*',
                 done: true
             } as any);
         } else {
             throw error;
         }
      }
    } catch (err) {
      onError(err instanceof Error ? err : new Error(String(err)));
    }
  }
};
