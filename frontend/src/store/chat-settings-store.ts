import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

interface ChatSettingsState {
  selectedConnectionId: number | null;
  selectedLlmConfigId: number | null;
  setSelectedConnectionId: (id: number | null) => void;
  setSelectedLlmConfigId: (id: number | null) => void;
}

export const useChatSettingsStore = create<ChatSettingsState>()(
  persist(
    (set) => ({
      selectedConnectionId: null,
      selectedLlmConfigId: null,
      setSelectedConnectionId: (id) => set({ selectedConnectionId: id }),
      setSelectedLlmConfigId: (id) => set({ selectedLlmConfigId: id }),
    }),
    {
      name: 'chat-settings-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
);
