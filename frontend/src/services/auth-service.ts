import api from '@/lib/api';
import type { LoginResponse, User, CustomerProfile } from '@/types/api';

export const authService = {
  login: async (data: { username: string; password: string }) => {
    const response = await api.post<LoginResponse>('/auth/login', data);
    return response.data;
  },
  
  register: async (data: { username: string; password: string; email: string }) => {
    const response = await api.post<User>('/auth/register', data);
    return response.data;
  },

  getProfile: async () => {
    const response = await api.get<CustomerProfile>('/profile');
    return response.data;
  }
};
