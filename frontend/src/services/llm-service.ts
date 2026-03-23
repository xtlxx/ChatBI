import api from '@/lib/api';
import type { 
  LlmConfig, 
  LlmConfigCreate, 
  LlmConfigUpdate, 
  LlmConfigEditResponse,
  LlmTestRequest,
  LlmTestResponse
} from '@/types/api';

export const llmService = {
  getAll: async () => {
    const response = await api.get<LlmConfig[]>('/llm-configs');
    return response.data;
  },

  getOne: async (id: number) => {
    const response = await api.get<LlmConfig>(`/llm-configs/${id}`);
    return response.data;
  },

  getForEdit: async (id: number) => {
    const response = await api.get<LlmConfigEditResponse>(`/llm-configs/${id}/edit`);
    return response.data;
  },

  create: async (data: LlmConfigCreate) => {
    const response = await api.post<LlmConfig>('/llm-configs', data);
    return response.data;
  },

  update: async (id: number, data: LlmConfigUpdate) => {
    const response = await api.put<LlmConfig>(`/llm-configs/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    await api.delete(`/llm-configs/${id}`);
  },

  testConnection: async (data: LlmTestRequest) => {
    const response = await api.post<LlmTestResponse>('/llm-configs/test', data);
    return response.data;
  }
};
