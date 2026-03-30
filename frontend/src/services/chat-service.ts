import api from '@/lib/api';
import i18n from '@/lib/i18n';
import { fetchEventSource } from '@microsoft/fetch-event-source';
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

  deleteSession: async (sessionId: string) => {
    await api.delete(`/chat/sessions/${sessionId}`);
  },

  // Non-streaming query
  sendMessage: async (data: QueryRequest) => {
    const response = await api.post<QueryResponse>('/query', data);
    return response.data;
  },

  // 流式查询请求
  sendMessageStream: async (
    data: QueryRequest, 
    onChunk: (event: StreamEvent) => void,
    onError: (err: Error) => void,
    onComplete: () => void,
    signal?: AbortSignal
  ) => {
    try {
      const token = useAuthStore.getState().token;
      if (!token) {
        throw new Error(i18n.t('errors.unauthorized'));
      }
      
      console.log('[ChatService] 开始流请求: /api/query/stream');
      
      let hasReceivedData = false;
      
      // 确保URL中不重复包含 /api
      let url = '/api/query/stream';
      if (api.defaults.baseURL && api.defaults.baseURL !== '/api') {
          url = `${api.defaults.baseURL}/query/stream`.replace(/\/\//g, '/');
      }

      await fetchEventSource(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(data),
        signal,
        async onopen(response) {
          if (response.ok) {
            return; // 所有正常，继续处理
          }
          
          if (response.status === 401) {
            useAuthStore.getState().logout();
            window.dispatchEvent(new CustomEvent('unauthorized'));
            throw new Error(i18n.t('errors.unauthorized'));
          }

          const errorText = await response.text();
          console.error(`流请求失败: status=${response.status} statusText=${response.statusText} body=${errorText}`);
          let errorMsg = i18n.t('errors.streamFailed');
          try {
              const errorJson = JSON.parse(errorText);
              if (errorJson.detail) errorMsg = errorJson.detail;
          } catch (e) {
              console.error('解析错误响应失败::', errorText);
          }
          throw new Error(`流请求失败: (${response.status}): ${errorMsg}`);
        },
        onmessage(msg) {
          hasReceivedData = true;
          try {
            const event = JSON.parse(msg.data) as StreamEvent;
            onChunk(event);
            
            // explicit 处理显式done信号
            if (event.done) {
               // 库会在不抛出错误时自动关闭连接
            }
          } catch (e) {
            console.error('解析 SSE JSON 失败', e, msg.data);
          }
        },
        onclose() {
          onComplete();
        },
        onerror(err) {
          if (signal?.aborted) {
            return; // 用户取消，不处理错误信号
          }
          console.error("流取错误:", err);
          if (hasReceivedData) {
             onChunk({
                 type: 'error',
                 content: '\n\n*(网络连接已中断，以上为部分生成内容)*',
                 done: true
             } as any);
             return; // 不抛出错误，停止重试尝试
          }
          throw err; // 触发 onError处理
        }
      });
      
    } catch (err: any) {
      if (err.name === 'AbortError') {
        console.log('用户取消流');
        onComplete();
        return;
      }
      onError(err instanceof Error ? err : new Error(String(err)));
    }
  }
};
