import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Home, MessageSquare, Edit2, Key, Settings, Plus, Book, Loader2, ArrowLeft } from "lucide-react";
import { chatService } from "@/services/chat-service";
import type { ChatSession } from "@/types/api";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { SidebarSettings } from "./SidebarSettings";

interface SidebarProps {
    view: 'nav' | 'settings';
    onViewChange: (view: 'nav' | 'settings') => void;
}

export function Sidebar({ view, onViewChange }: SidebarProps) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const params = useParams();
  const currentSessionId = params.sessionId;
  
  const [sessions, setSessions] = useState<ChatSession[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  const fetchSessions = async () => {
    try {
      setIsLoading(true);
      const data = await chatService.getSessions(50, 0);
      setSessions(data);
    } catch (error) {
      console.error("Failed to fetch sessions", error);
      toast.error(t('sidebar.loadHistoryError'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSessions();
  }, [currentSessionId]); // Refresh list when session changes (in case title updated) or on mount

  const handleNewChat = () => {
    navigate("/chat/new");
    if (view === 'settings') onViewChange('nav');
  };

  const handleSessionClick = (id: string) => {
    navigate(`/chat/${id}`);
    if (view === 'settings') onViewChange('nav');
  };

  if (view === 'settings') {
      return (
          <div className="w-full h-full flex flex-col bg-background">
              {/* Settings Header */}
              <div className="h-14 px-4 border-b border-border flex items-center gap-2">
                  <button 
                    onClick={() => onViewChange('nav')}
                    className="p-1 -ml-1 text-muted-foreground hover:bg-accent hover:text-accent-foreground rounded-md transition-colors"
                    aria-label={t('sidebar.back')}
                  >
                      <ArrowLeft size={20} />
                  </button>
                  <span className="font-semibold text-lg tracking-tight text-foreground">{t('sidebar.settings')}</span>
              </div>
              <div className="flex-1 overflow-y-auto">
                  <SidebarSettings />
              </div>
          </div>
      );
  }

  return (
    <div className="w-full h-full flex flex-col bg-background">
      {/* Top Header */}
      <div className="h-14 px-4 border-b border-border flex items-center gap-2">
        <div className="w-6 h-6 bg-gradient-to-tr from-primary to-secondary rounded-md"></div>
        <span className="font-semibold text-lg tracking-tight text-foreground">{t('sidebar.title')}</span>
      </div>

      {/* Navigation */}
      <div className="p-2 space-y-1">
        <button 
          onClick={handleNewChat}
          className="flex items-center gap-2 w-full mt-1 px-3 py-2 text-sm text-primary hover:bg-primary/10 rounded-md border border-dashed border-primary/20 justify-center transition-colors mb-2"
        >
            <Plus size={16} />
            {t('sidebar.newChat')}
        </button>
        <button className="flex items-center gap-3 w-full px-3 py-2 text-sm font-medium text-muted-foreground rounded-md hover:bg-accent hover:text-accent-foreground transition-colors">
          <Home size={18} />
          {t('sidebar.home')}
        </button>
         <button className="flex items-center gap-3 w-full px-3 py-2 text-sm font-medium text-muted-foreground rounded-md hover:bg-accent hover:text-accent-foreground transition-colors">
          <Book size={18} />
          {t('sidebar.library')}
        </button>
      </div>

       {/* History List */}
      <div className="flex-1 overflow-y-auto px-2 py-2">
        <div className="px-3 py-2 text-xs font-semibold text-muted-foreground/60 uppercase tracking-wider flex justify-between items-center">
            <span>{t('sidebar.recent')}</span>
            {isLoading && <Loader2 size={12} className="animate-spin text-muted-foreground" />}
        </div>
        <div className="space-y-0.5 mt-1">
            {sessions.map((item) => (
            <div 
                key={item.id} 
                onClick={() => handleSessionClick(item.id)}
                className={`group flex items-center justify-between px-3 py-2 text-sm rounded-md cursor-pointer transition-colors ${
                    currentSessionId === item.id 
                        ? "bg-primary/10 text-primary font-medium" 
                        : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
                }`}
            >
                <div className="flex items-center gap-3 truncate">
                    <MessageSquare size={16} className={currentSessionId === item.id ? "text-primary" : "text-muted-foreground"} />
                    <span className="truncate max-w-[120px]">{item.title}</span>
                </div>
                <Edit2 size={14} className="text-muted-foreground/60 opacity-0 group-hover:opacity-100 hover:text-foreground transition-opacity" />
            </div>
            ))}
            
            {!isLoading && sessions.length === 0 && (
                <div className="px-3 py-4 text-center text-xs text-muted-foreground">
                    {t('sidebar.noHistory')}
                </div>
            )}
        </div>
      </div>

      {/* Bottom Footer */}
      <div className="p-2 border-t border-border mt-auto space-y-1 bg-background">
        <button className="flex items-center gap-3 w-full px-3 py-2 text-sm font-medium text-muted-foreground rounded-md hover:bg-accent hover:text-accent-foreground transition-colors">
          <Key size={18} />
          {t('sidebar.getApiKey')}
        </button>
        <button 
            onClick={() => onViewChange('settings')}
            className="flex items-center gap-3 w-full px-3 py-2 text-sm font-medium text-muted-foreground rounded-md hover:bg-accent hover:text-accent-foreground transition-colors"
        >
          <Settings size={18} />
          {t('sidebar.settings')}
        </button>
        <div className="flex items-center gap-3 w-full px-3 py-2 mt-2 border-t border-border pt-3 cursor-pointer hover:bg-accent/50 rounded-md transition-colors">
             <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-primary-foreground text-sm font-medium">U</div>
             <div className="flex flex-col">
                <span className="text-sm font-medium text-foreground">{t('sidebar.userAccount')}</span>
                <span className="text-xs text-muted-foreground">{t('sidebar.freeTier')}</span>
             </div>
        </div>
      </div>
    </div>
  );
}
