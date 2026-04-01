import { useEffect, useState, useCallback, useRef } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { MessageSquare, Settings, Plus, Loader2, ArrowLeft, ArrowRight, User, Trash2 } from "lucide-react";
import { chatService } from "@/services/chat-service";
import { authService } from "@/services/auth-service";
import type { ChatSession, CustomerProfile } from "@/types/api";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { SidebarSettings } from "./SidebarSettings";
import { SettingsPopover } from "./SettingsPopover";

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
  const [userProfile, setUserProfile] = useState<CustomerProfile | null>(null);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [isHistoryExpanded, setIsHistoryExpanded] = useState(false);
  const settingsButtonRef = useRef<HTMLButtonElement>(null);

  const fetchProfile = useCallback(async () => {
    try {
      const profile = await authService.getProfile();
      setUserProfile(profile);
    } catch (error) {
      console.error("Failed to fetch profile", error);
    }
  }, []);

  const fetchSessions = useCallback(async () => {
    try {
      setIsLoading(true);
      // 获取 50 条会话数据，后续可根据需要过滤
      const data = await chatService.getSessions(50, 0);
      setSessions(data);
    } catch (error) {
      console.error("获取会话失败", error);
      toast.error(t('sidebar.loadHistoryError'));
    } finally {
      setIsLoading(false);
    }
  }, [t]);

  useEffect(() => {
    fetchSessions();
    fetchProfile();
  }, [fetchSessions, fetchProfile, currentSessionId]);

  const handleNewChat = () => {
    navigate("/chat/new");
    if (view === 'settings') onViewChange('nav');
  };

  const handleSessionClick = (id: string) => {
    navigate(`/chat/${id}`);
    if (view === 'settings') onViewChange('nav');
  };

  const handleDeleteSession = async (e: React.MouseEvent, id: string) => {
    e.stopPropagation();
    
    if (window.confirm(t('common.confirmDelete') || '确定要删除这个对话吗？')) {
      try {
        await chatService.deleteSession(id);
        toast.success(t('common.deleteSuccess') || '删除成功');
        
        // 更新本地列表
        setSessions(prev => prev.filter(s => s.id !== id));
        
        // 如果删除的是当前正在看的会话，跳回新建对话页
        if (currentSessionId === id) {
          navigate('/chat/new');
        }
      } catch (error) {
        console.error('Delete session failed:', error);
        toast.error(t('common.error') || '删除失败');
      }
    }
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

  const displayedSessions = isHistoryExpanded ? sessions : sessions.slice(0, 5);

  return (
    <aside className="w-full h-full flex flex-col bg-background/50 backdrop-blur-sm border-r border-border">
      {/* Top Header */}
      <div className="h-16 px-4 flex items-center gap-3">
        <span className="font-semibold text-xl tracking-tight text-foreground/90">
          KY Data Pilot
        </span>
      </div>

      {/* Navigation */}
      <div className="flex-1 overflow-y-auto px-3 space-y-1 custom-scrollbar">
        <button
          onClick={handleNewChat}
          className="flex items-center gap-3 w-full mt-2 px-4 py-3 text-sm font-medium text-primary-foreground bg-primary hover:bg-primary/90 rounded-full shadow-md hover:shadow-lg transition-all duration-200 mb-6 group"
        >
          <Plus size={18} className="group-hover:rotate-90 transition-transform duration-200" />
          <span>{t('sidebar.newChat')}</span>
        </button>

        <div className="px-2 pb-2 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
          {t('sidebar.recent')}
        </div>

        <div className="space-y-0.5">
          {isLoading && sessions.length === 0 ? (
            <div className="flex items-center justify-center py-8 text-muted-foreground">
              <Loader2 className="animate-spin mr-2" size={16} />
              <span>Loading...</span>
            </div>
          ) : (
            <>
              {displayedSessions.map((session) => (
                <div key={session.id} className="relative group">
                  <button
                    onClick={() => handleSessionClick(session.id)}
                    className={`
                              flex items-center gap-3 w-full px-3 py-2 text-sm text-left rounded-lg transition-colors pr-10
                              ${currentSessionId === session.id
                        ? "bg-accent text-accent-foreground font-medium"
                        : "text-muted-foreground hover:bg-muted hover:text-foreground"}
                          `}
                  >
                    <MessageSquare size={16} className="shrink-0 opacity-70" />
                    <span className="truncate flex-1">{session.title || t('chat.newChat')}</span>
                  </button>
                  <button
                    onClick={(e) => handleDeleteSession(e, session.id)}
                    className="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-md opacity-0 group-hover:opacity-100 transition-all duration-200"
                    title={t('common.delete') || '删除'}
                  >
                    <Trash2 size={14} />
                  </button>
                </div>
              ))}

              {/* View All / Show Less Button */}
              {sessions.length > 5 && (
                <button
                  onClick={() => setIsHistoryExpanded(!isHistoryExpanded)}
                  className="group flex items-center gap-3 w-full px-3 py-2 text-sm text-left rounded-lg transition-colors text-muted-foreground hover:bg-muted hover:text-foreground mt-2"
                >
                  {/* Show proper icon and text based on state, though standard AI studio just links to all. We toggle here for MVP UX */}
                  <ArrowRight size={16} className={`shrink-0 opacity-70 transition-transform duration-200 ${isHistoryExpanded ? 'rotate-90' : ''}`} />
                  <span className="truncate flex-1 font-medium">
                    {isHistoryExpanded ? t('common.close') : t('sidebar.viewAllHistory')}
                  </span>
                </button>
              )}
            </>
          )}
        </div>
      </div>

      {/* Bottom Actions - Google AI Studio Style */}
      <div className="mt-auto px-2 py-3 border-t border-border space-y-1">
        {/* Settings Button */}
        <button
          ref={settingsButtonRef}
          onClick={() => setIsSettingsOpen(!isSettingsOpen)}
          className={`flex items-center gap-3 w-full px-3 py-2 text-sm font-medium rounded-lg transition-colors ${isSettingsOpen ? 'bg-muted text-foreground' : 'text-muted-foreground hover:bg-muted hover:text-foreground'}`}
        >
          <Settings size={18} className="shrink-0" />
          <span className="truncate">{t('sidebar.settings')}</span>
        </button>

        <SettingsPopover
          isOpen={isSettingsOpen}
          onClose={() => setIsSettingsOpen(false)}
          triggerRef={settingsButtonRef}
          title={t('sidebar.settings')}
        >
          <SidebarSettings />
        </SettingsPopover>

        {/* User Profile - Clean Row Style */}
        {userProfile && (
          <div className="flex items-center gap-3 w-full px-3 py-2 text-sm font-medium text-muted-foreground hover:bg-muted hover:text-foreground rounded-lg transition-colors cursor-pointer group">
            <div className="w-5 h-5 rounded-full bg-primary/20 flex items-center justify-center text-primary text-xs font-bold shrink-0">
              {userProfile.name?.charAt(0) || <User size={12} />}
            </div>
            <div className="truncate flex-1 group-hover:text-foreground transition-colors">
              {userProfile.name}
            </div>
          </div>
        )}
      </div>
    </aside>
  );
}
