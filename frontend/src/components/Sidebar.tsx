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
    <aside className="w-full h-full flex flex-col bg-zinc-50 dark:bg-zinc-950 text-zinc-500 dark:text-zinc-400 border-r border-black/5 dark:border-white/5 transition-colors">
      {/* Header: 极简主义 */} 
      <div className="h-16 px-6 flex items-center"> 
        <div className="flex items-center gap-2 font-bold text-zinc-900 dark:text-zinc-100 tracking-tight"> 
          <div className="w-6 h-6 ai-gradient-bg rounded-lg shadow-sm" /> {/* 统一品牌标识 */} 
          <span>KY Data Pilot</span> 
        </div> 
      </div> 

      {/* 导航区域 */}
      <div className="flex-1 overflow-y-auto px-3 space-y-6 pt-4 custom-scrollbar">
        {/* New Chat: 玻璃拟态按钮 */} 
        <button 
          onClick={handleNewChat} 
          className="flex items-center justify-between w-full px-4 py-2.5 text-sm font-medium text-zinc-900 dark:text-zinc-100 bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10 border border-black/5 dark:border-white/10 rounded-xl transition-all group" 
        > 
          <div className="flex items-center gap-2"> 
            <Plus size={16} /> 
            <span>{t('sidebar.newChat')}</span> 
          </div> 
          <kbd className="hidden group-hover:block text-[10px] bg-black/10 dark:bg-white/10 px-1.5 py-0.5 rounded opacity-50 text-zinc-600 dark:text-zinc-300">⌘ N</kbd> 
        </button> 

        {/* 最近会话：精细化的列表态 */} 
        <div className="space-y-1"> 
          <div className="px-3 mb-2 text-[10px] font-bold text-zinc-400 dark:text-zinc-600 uppercase tracking-widest"> 
            {t('sidebar.recent')} 
          </div> 
          
          {isLoading && sessions.length === 0 ? (
            <div className="flex items-center justify-center py-8 text-zinc-500 dark:text-zinc-600">
              <Loader2 className="animate-spin mr-2" size={16} />
              <span>Loading...</span>
            </div>
          ) : (
            <>
              {displayedSessions.map((session) => (
                <div key={session.id} className="relative group px-1"> 
                  <button 
                    onClick={() => handleSessionClick(session.id)} 
                    className={` 
                      flex items-center gap-3 w-full px-3 py-2 text-sm rounded-lg transition-all 
                      ${currentSessionId === session.id 
                        ? "bg-black/5 dark:bg-white/10 text-zinc-900 dark:text-white shadow-sm ring-1 ring-black/5 dark:ring-white/10" 
                        : "hover:bg-black/5 dark:hover:bg-white/5 hover:text-zinc-800 dark:hover:text-zinc-200"} 
                    `} 
                  > 
                    <MessageSquare size={14} className={currentSessionId === session.id ? "text-indigo-500 dark:text-indigo-400" : "opacity-50 dark:opacity-40"} /> 
                    <span className="truncate flex-1 text-left">{session.title || t('chat.newChat')}</span> 
                  </button> 
                  <button
                    onClick={(e) => handleDeleteSession(e, session.id)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 p-1.5 text-zinc-400 dark:text-zinc-500 hover:text-red-500 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-400/10 rounded-md opacity-0 group-hover:opacity-100 transition-all duration-200"
                    title={t('common.delete') || '删除'}
                  >
                    <Trash2 size={14} />
                  </button>
                </div> 
              ))} 

              {/* 查看所有/显示更少按钮：玻璃拟态 */}
              {sessions.length > 5 && (
                <button
                  onClick={() => setIsHistoryExpanded(!isHistoryExpanded)}
                  className="group flex items-center gap-3 w-full px-4 py-2 text-sm text-left rounded-lg transition-colors text-zinc-500 hover:bg-black/5 dark:hover:bg-white/5 hover:text-zinc-700 dark:hover:text-zinc-300 mt-2"
                >
                  <ArrowRight size={14} className={`shrink-0 opacity-70 transition-transform duration-200 ${isHistoryExpanded ? 'rotate-90' : ''}`} />
                  <span className="truncate flex-1 font-medium">
                    {isHistoryExpanded ? t('common.close') : t('sidebar.viewAllHistory')}
                  </span>
                </button>
              )}
            </>
          )}
        </div>
      </div>

      {/* 底部用户信息：悬浮卡片感 */} 
      <div className="p-4 mt-auto border-t border-black/5 dark:border-white/5 space-y-2"> 
        <button 
          ref={settingsButtonRef}
          onClick={() => setIsSettingsOpen(!isSettingsOpen)} 
          className="flex items-center gap-3 w-full px-3 py-2 text-sm text-zinc-500 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-200 hover:bg-black/5 dark:hover:bg-white/5 rounded-lg transition-colors" 
        > 
          <Settings size={16} className="opacity-60" /> 
          <span>{t('sidebar.settings')}</span> 
        </button> 
        
        <SettingsPopover
          isOpen={isSettingsOpen}
          onClose={() => setIsSettingsOpen(false)}
          triggerRef={settingsButtonRef}
          title={t('sidebar.settings')}
        >
          <SidebarSettings />
        </SettingsPopover>

        {userProfile && ( 
          <div className="flex items-center gap-3 px-3 py-3 bg-white dark:bg-white/5 rounded-2xl border border-black/5 dark:border-white/5 shadow-sm dark:shadow-none"> 
             <div className="w-8 h-8 rounded-full ai-gradient-bg flex items-center justify-center text-[10px] font-bold text-white shadow-inner"> 
                {userProfile.name?.charAt(0) || <User size={12} />} 
             </div> 
             <div className="flex-1 min-w-0"> 
                <p className="text-sm font-medium text-zinc-900 dark:text-zinc-200 truncate">{userProfile.name}</p> 
                <p className="text-[10px] text-zinc-500 truncate">Enterprise Pro</p> 
             </div> 
          </div> 
        )} 
      </div> 
    </aside>
  );
}
