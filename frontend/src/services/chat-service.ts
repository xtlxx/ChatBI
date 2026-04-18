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
      let lastProcessedId = '';
      
      // 确保URL中不重复包含 /api
      let url = '/api/query/stream';
      if (api.defaults.baseURL && api.defaults.baseURL !== '/api') {
          url = `${api.defaults.baseURL}/query/stream`.replace(/\/\//g, '/');
      }

      await fetchEventSource(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          ...(lastProcessedId ? { 'Last-Event-ID': lastProcessedId } : {})
        },
        body: JSON.stringify(data),
        signal,
        async onopen(response: Response) {
          if (response.ok) {
            console.log('[ChatService] 连接成功');
            return; // 一切正常
          }
          if (response.status === 401) {
            // 直接抛出错误，交给外层的统一拦截器或顶层边界处理
            throw new Error('UNAUTHORIZED');
          }
          if (response.status >= 400 && response.status < 500 && response.status !== 429) {
            throw new Error(`请求错误: ${response.status} ${response.statusText}`);
          }
          throw new Error(`服务器错误: ${response.status} ${response.statusText}`);
        },
        onmessage(msg: { id?: string; event: string; data: string }) {
          try {
            // 处理不同的事件类型
            if (msg.event === 'ping') {
              // console.log('[ChatService] 收到 ping:', msg.data);
              return;
            }
            
            if (msg.event === 'error') {
              throw new Error(msg.data || '流处理错误');
            }
            
            // 忽略非数据消息或空消息
            if (!msg.data || msg.data === '[DONE]') {
              return;
            }

            // 防乱序：如果存在 id 且小于最后处理的 id，则跳过
            if (msg.id) {
               if (lastProcessedId && msg.id < lastProcessedId) {
                   console.warn(`[ChatService] 丢弃乱序或重复消息: ${msg.id}`);
                   return;
               }
               lastProcessedId = msg.id;
            }

            hasReceivedData = true;
            const parsedData = JSON.parse(msg.data) as StreamEvent;
            
            // 使用 requestAnimationFrame 简单的节流，防止高频触发 React 渲染
            requestAnimationFrame(() => {
                onChunk(parsedData);
            });
          } catch (e) {
            console.error('解析 SSE JSON 失败', e, msg.data);
          }
        },
        onclose() {
          onComplete();
        },
        onerror(err: unknown) {
          if (signal?.aborted) {
            // 如果是被手动 abort 取消的，直接抛出以触发 catch 块，但不要重试
            throw err;
          }
          // 浏览器原生的 fetch 被 abort 时，也会抛出 DOMException(name='AbortError')
          if (err instanceof DOMException && err.name === 'AbortError') {
             throw err; // 将被外层的 catch 捕获并静默处理
          }
          
          // @microsoft/fetch-event-source 在 abort 时有时会直接抛出包含 abort 关键字的 Error
          if (err instanceof Error && err.message.toLowerCase().includes('abort')) {
             throw err;
          }
          
          console.error("流读取错误:", err);
          if (hasReceivedData) {
             onChunk({
                 type: 'error',
                 content: '\n\n*(网络连接已中断，以上为部分生成内容)*',
                 done: true
             });
             throw err; // 抛出错误以终止，不进行重试尝试
          }
          
          // 网络级别的致命错误 (例如跨域、服务器拒绝连接)，不要重试，直接抛出
          if (err instanceof Error && (err.message.includes('服务器错误') || err.message.includes('请求错误'))) {
             throw err;
          }

          // 其他短暂网络抖动，允许重试
          return Math.min(1000 * Math.pow(2, 3), 15000); // 出现错误时，最多重试并以指数退避策略延迟，上限 15s
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
