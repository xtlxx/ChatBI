import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { User, DbConnection, LlmConfig, Message } from '@/types';

interface AppState {
  // User Session
  user: User | null;
  setUser: (user: User | null) => void;
  
  // Database Connections
  connections: DbConnection[];
  setConnections: (connections: DbConnection[]) => void;
  addConnection: (connection: DbConnection) => void;
  updateConnection: (id: number, connection: Partial<DbConnection>) => void;
  removeConnection: (id: number) => void;
  
  // LLM Configurations
  llmConfigs: LlmConfig[];
  setLlmConfigs: (configs: LlmConfig[]) => void;
  addLlmConfig: (config: LlmConfig) => void;
  updateLlmConfig: (id: number, config: Partial<LlmConfig>) => void;
  removeLlmConfig: (id: number) => void;
  
  // Active Selections
  activeConnectionId: number | null;
  setActiveConnectionId: (id: number | null) => void;
  activeLlmConfigId: number | null;
  setActiveLlmConfigId: (id: number | null) => void;
  
  // Chat State
  messages: Message[];
  setMessages: (messages: Message[]) => void;
  addMessage: (message: Message) => void;
  updateMessage: (id: string, updates: Partial<Message>) => void;
  clearMessages: () => void;
  
  // Chat Sessions (History)
  chatSessions: Array<{ id: string; title: string; created_at: string }>;
  setChatSessions: (sessions: Array<{ id: string; title: string; created_at: string }>) => void;
  addChatSession: (session: { id: string; title: string; created_at: string }) => void;
  
  // UI State
  sidebarOpen: boolean;
  setSidebarOpen: (open: boolean) => void;
}

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // User Session
      user: null,
      setUser: (user) => set({ user }),
      
      // Database Connections
      connections: [],
      setConnections: (connections) => set({ connections }),
      addConnection: (connection) => 
        set((state) => ({ connections: [...state.connections, connection] })),
      updateConnection: (id, updates) =>
        set((state) => ({
          connections: state.connections.map((conn) =>
            conn.id === id ? { ...conn, ...updates } : conn
          ),
        })),
      removeConnection: (id) =>
        set((state) => ({
          connections: state.connections.filter((conn) => conn.id !== id),
        })),
      
      // LLM Configurations
      llmConfigs: [],
      setLlmConfigs: (configs) => set({ llmConfigs: configs }),
      addLlmConfig: (config) =>
        set((state) => ({ llmConfigs: [...state.llmConfigs, config] })),
      updateLlmConfig: (id, updates) =>
        set((state) => ({
          llmConfigs: state.llmConfigs.map((config) =>
            config.id === id ? { ...config, ...updates } : config
          ),
        })),
      removeLlmConfig: (id) =>
        set((state) => ({
          llmConfigs: state.llmConfigs.filter((config) => config.id !== id),
        })),
      
      // Active Selections
      activeConnectionId: null,
      setActiveConnectionId: (id) => set({ activeConnectionId: id }),
      activeLlmConfigId: null,
      setActiveLlmConfigId: (id) => set({ activeLlmConfigId: id }),
      
      // Chat State
      messages: [],
      setMessages: (messages) => set({ messages }),
      addMessage: (message) =>
        set((state) => ({ messages: [...state.messages, message] })),
      updateMessage: (id, updates) =>
        set((state) => ({
          messages: state.messages.map((msg) =>
            msg.id === id ? { ...msg, ...updates } : msg
          ),
        })),
      clearMessages: () => set({ messages: [] }),
      
      // Chat Sessions
      chatSessions: [],
      setChatSessions: (sessions) => set({ chatSessions: sessions }),
      addChatSession: (session) =>
        set((state) => ({ chatSessions: [...state.chatSessions, session] })),
      
      // UI State
      sidebarOpen: true,
      setSidebarOpen: (open) => set({ sidebarOpen: open }),
    }),
    {
      name: 'app-storage',
      partialize: (state) => ({
        user: state.user,
        activeConnectionId: state.activeConnectionId,
        activeLlmConfigId: state.activeLlmConfigId,
        sidebarOpen: state.sidebarOpen,
      }),
    }
  )
);

// Selectors for easier access
export const useUser = () => useAppStore((state) => state.user);
export const useConnections = () => useAppStore((state) => state.connections);
export const useLlmConfigs = () => useAppStore((state) => state.llmConfigs);
export const useActiveConnection = () => {
  const connections = useConnections();
  const activeId = useAppStore((state) => state.activeConnectionId);
  return connections.find((conn) => conn.id === activeId);
};
export const useActiveLlmConfig = () => {
  const configs = useLlmConfigs();
  const activeId = useAppStore((state) => state.activeLlmConfigId);
  return configs.find((config) => config.id === activeId);
};
export const useMessages = () => useAppStore((state) => state.messages);
export const useChatSessions = () => useAppStore((state) => state.chatSessions);
