import api from '@/lib/api';
import type { 
  DbConnection, 
  DbConnectionCreate, 
  DbConnectionUpdate, 
  DbConnectionEditResponse,
  ConnectionTestResponse 
} from '@/types/api';

export const connectionService = {
  getAll: async () => {
    const response = await api.get<DbConnection[]>('/connections');
    return response.data;
  },

  getOne: async (id: number) => {
    const response = await api.get<DbConnection>(`/connections/${id}`);
    return response.data;
  },

  getForEdit: async (id: number) => {
    const response = await api.get<DbConnectionEditResponse>(`/connections/${id}/edit`);
    return response.data;
  },

  create: async (data: DbConnectionCreate) => {
    const response = await api.post<DbConnection>('/connections', data);
    return response.data;
  },

  update: async (id: number, data: DbConnectionUpdate) => {
    const response = await api.put<DbConnection>(`/connections/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    await api.delete(`/connections/${id}`);
  },

  testConnection: async (data: DbConnectionCreate) => {
    const response = await api.post<ConnectionTestResponse>('/connections/test', data);
    return response.data;
  },

  refreshSchema: async (id: number) => {
    const response = await api.post<{success: boolean; message: string}>(`/connections/${id}/refresh-schema`);
    return response.data;
  }
};
