import api from '@/lib/api';

export const speechService = {
  recognizeSpeech: async (audioBlob: Blob): Promise<{ success: boolean; text: string }> => {
    const formData = new FormData();
    // 后端要求 PCM, 16k采样率, 16位, 单声道
    formData.append('audio', audioBlob, 'audio.pcm');
    
    const response = await api.post<{ success: boolean; text: string }>('/speech/recognize', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  }
};
