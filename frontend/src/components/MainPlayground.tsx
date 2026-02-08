import { useState, useRef, useEffect } from "react";
import { Share2, MoreVertical, Play, ChevronDown, ChevronRight, Search, Box, PanelLeftClose, PanelLeftOpen, Loader2, AlertCircle } from "lucide-react";
import * as Collapsible from "@radix-ui/react-collapsible";
import { useOutletContext, useParams, useNavigate } from "react-router-dom";
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { useChatSettingsStore } from "@/store/chat-settings-store";
import { chatService } from "@/services/chat-service";
import { ChartRenderer } from "@/components/ChartRenderer";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";

interface LayoutContext {
    isLeftSidebarOpen: boolean;
    setIsLeftSidebarOpen: (v: boolean) => void;
    sidebarView: 'nav' | 'settings';
    setSidebarView: (v: 'nav' | 'settings') => void;
}

interface Message {
    id: string | number;
    role: 'user' | 'ai';
    content: string;
    thoughts: string[];
    sql?: string;
    chartOption?: any;
    isLoading?: boolean;
    isError?: boolean;
    timestamp: number;
}

export function MainPlayground() {
  const { t } = useTranslation();
  const { 
      isLeftSidebarOpen, 
      setIsLeftSidebarOpen,
      sidebarView,
      setSidebarView
  } = useOutletContext<LayoutContext>();
  
  const { sessionId: routeSessionId } = useParams();
  const navigate = useNavigate();

  const onToggleLeftSidebar = () => setIsLeftSidebarOpen(!isLeftSidebarOpen);

  const { selectedConnectionId, selectedLlmConfigId } = useChatSettingsStore();
  
  const [sessionId, setSessionId] = useState<string>("");
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState<Message[]>([]);
  const [isStreaming, setIsStreaming] = useState(false);
  const [isLoadingHistory, setIsLoadingHistory] = useState(false);
  
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Initialize Session
  useEffect(() => {
    if (!routeSessionId || routeSessionId === 'new') {
        setSessionId(crypto.randomUUID());
        setMessages([]);
    } else {
        setSessionId(routeSessionId);
        loadSessionHistory(routeSessionId);
    }
  }, [routeSessionId]);

  const loadSessionHistory = async (id: string) => {
    try {
        setIsLoadingHistory(true);
        const session = await chatService.getSession(id);
        
        // Map backend messages to frontend format
        const mappedMessages: Message[] = session.messages.map(msg => ({
            id: msg.id,
            role: msg.role === 'system' ? 'ai' : msg.role, // Treat system as AI for now or hide it
            content: msg.content,
            thoughts: [], // Thoughts might not be persisted in simple message history yet, or stored in metadata
            sql: msg.message_metadata?.sql_query,
            chartOption: msg.message_metadata?.chart_data,
            timestamp: new Date(msg.created_at).getTime()
        }));
        
        setMessages(mappedMessages);
    } catch (error) {
        console.error("Failed to load session", error);
        toast.error(t('chat.loadHistoryError'));
        // Fallback to new session if not found?
        // navigate('/chat/new'); 
    } finally {
        setIsLoadingHistory(false);
    }
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, messages.length]); 

  const handleSendMessage = async () => {
    if (!input.trim() || isStreaming) return;

    if (!selectedConnectionId || !selectedLlmConfigId) {
        toast.error("Please select a Database Connection and Model in settings.");
        setSidebarView('settings');
        if (!isLeftSidebarOpen) setIsLeftSidebarOpen(true);
        return;
    }

    const currentInput = input;
    const userMsg: Message = {
        id: crypto.randomUUID(),
        role: 'user',
        content: currentInput,
        thoughts: [],
        timestamp: Date.now()
    };

    const aiMsgId = crypto.randomUUID();
    const aiMsg: Message = {
        id: aiMsgId,
        role: 'ai',
        content: '',
        thoughts: [],
        isLoading: true,
        timestamp: Date.now()
    };

    setMessages(prev => [...prev, userMsg, aiMsg]);
    setInput("");
    setIsStreaming(true);

    // Reset textarea height
    if (textareaRef.current) {
        textareaRef.current.style.height = 'auto';
    }

    try {
        await chatService.sendMessageStream(
            {
                query: currentInput,
                connection_id: selectedConnectionId,
                llm_config_id: selectedLlmConfigId,
                session_id: sessionId,
                stream: true
            },
            (event) => {
                // Handle SSE Chunk
                setMessages(prev => {
                    const newMessages = [...prev];
                    const msgIndex = newMessages.findIndex(m => String(m.id) === String(aiMsgId));
                    if (msgIndex === -1) return prev;

                    const msg = { ...newMessages[msgIndex] };
                    
                    switch (event.type) {
                        case 'thought':
                            msg.thoughts = [...msg.thoughts, event.content];
                            break;
                        case 'final_output':
                            msg.content = event.content.summary || "";
                            msg.sql = event.content.sql;
                            msg.chartOption = event.content.chartOption;
                            break;
                        case 'error':
                            msg.content += `\n\n**Error:** ${event.content}`;
                            msg.isError = true;
                            break;
                        case 'end':
                            msg.isLoading = false;
                            break;
                    }
                    
                    newMessages[msgIndex] = msg;
                    return newMessages;
                });
            },
            (err) => {
                console.error("Stream error", err);
                toast.error("Failed to send message");
                setMessages(prev => {
                    const newMessages = [...prev];
                    const msgIndex = newMessages.findIndex(m => String(m.id) === String(aiMsgId));
                    if (msgIndex !== -1) {
                        newMessages[msgIndex] = {
                            ...newMessages[msgIndex],
                            isLoading: false,
                            isError: true,
                            content: newMessages[msgIndex].content + `\n\n*(Error: ${err.message})*`
                        };
                    }
                    return newMessages;
                });
                setIsStreaming(false);
            },
            () => {
                setIsStreaming(false);
                // If we were on "new" route, update to the actual session ID
                if (!routeSessionId || routeSessionId === 'new') {
                    navigate(`/chat/${sessionId}`, { replace: true });
                }
            }
        );
    } catch (error) {
        console.error("Failed to start stream", error);
        setIsStreaming(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          handleSendMessage();
      }
  };

  // Auto-resize textarea
  const handleInput = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
      setInput(e.target.value);
      e.target.style.height = 'auto';
      e.target.style.height = `${Math.min(e.target.scrollHeight, 200)}px`;
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-muted/10 min-w-0 relative">
      {/* Top Bar */}
      <div className="h-16 border-b border-border bg-background flex justify-between items-center px-4 md:px-6 flex-shrink-0 z-10 shadow-sm/50">
         <div className="flex items-center gap-4">
             <button 
                onClick={onToggleLeftSidebar}
                className="p-2 hover:bg-accent hover:text-accent-foreground rounded-md text-muted-foreground transition-colors"
                title={isLeftSidebarOpen ? "Close Sidebar" : "Open Sidebar"}
                aria-label={isLeftSidebarOpen ? t('sidebar.close') : t('sidebar.open')}
             >
                {isLeftSidebarOpen ? <PanelLeftClose size={20} /> : <PanelLeftOpen size={20} />}
             </button>

             <div className="h-6 w-px bg-border mx-1 hidden md:block"></div>

             <div className="flex flex-col">
                <h1 className="font-semibold text-sm text-foreground">{t('chat.session')}</h1>
                <span className="text-xs text-muted-foreground font-mono">{sessionId.slice(0, 8)}...</span>
             </div>
         </div>
         <div className="flex items-center gap-1">
             <button className="p-2 hover:bg-accent hover:text-accent-foreground rounded-md text-muted-foreground transition-colors" aria-label="Share">
                <Share2 size={18} />
             </button>
             <button className="p-2 hover:bg-accent hover:text-accent-foreground rounded-md text-muted-foreground transition-colors" aria-label="More options">
                <MoreVertical size={18} />
             </button>
         </div>
      </div>

      {/* Chat Area */}
      <div className="flex-1 overflow-y-auto p-6 md:p-12 space-y-10 pb-40">
        {isLoadingHistory ? (
            <div className="flex flex-col items-center justify-center h-full text-muted-foreground gap-3">
                <Loader2 className="animate-spin text-primary" size={32} />
                <p className="text-sm font-medium animate-pulse">{t('chat.loadingHistory')}</p>
            </div>
        ) : (
            <>
                {messages.length === 0 && (
            <div className="flex flex-col items-center justify-center h-full text-muted-foreground space-y-4">
                <div className="w-16 h-16 bg-accent rounded-full flex items-center justify-center">
                    <Box size={32} />
                </div>
                <p>{t('chat.startPrompt')}</p>
                {(!selectedConnectionId || !selectedLlmConfigId) && (
                    <div className="flex items-center gap-2 text-yellow-600 bg-yellow-50 px-3 py-2 rounded-md text-sm border border-yellow-200">
                        <AlertCircle size={16} />
                        {t('chat.configurePrompt')}
                    </div>
                )}
            </div>
        )}

        {messages.map((msg) => (
            <div key={msg.id} className="flex flex-col gap-3 max-w-4xl mx-auto group">
                <div className="flex items-center justify-between">
                    <div className={`font-semibold text-sm ${msg.role === 'user' ? 'text-foreground' : 'text-primary flex items-center gap-2'}`}>
                        {msg.role === 'user' ? t('chat.user') : (
                            <>
                                <div className="w-5 h-5 rounded-full bg-primary flex items-center justify-center shadow-sm text-primary-foreground">
                                    <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                                        <path d="M12 2L14.5 9.5L22 12L14.5 14.5L12 22L9.5 14.5L2 12L9.5 9.5L12 2Z" />
                                    </svg>
                                </div>
                                {t('chat.ai')}
                            </>
                        )}
                    </div>
                    <div className="text-xs text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity">
                        {new Date(msg.timestamp).toLocaleTimeString()}
                    </div>
                </div>

                <div className={`text-sm leading-relaxed ${msg.role === 'user' ? 'bg-card border border-border p-4 rounded-lg shadow-sm text-card-foreground' : 'text-foreground'}`}>
                    {msg.thoughts && msg.thoughts.length > 0 && (
                        <div className="mb-4">
                            <Collapsible.Root>
                                <Collapsible.Trigger className="flex items-center gap-2 text-xs font-medium text-muted-foreground hover:text-foreground transition-colors w-full text-left p-2 bg-muted/50 rounded border border-transparent hover:border-border">
                                    <ChevronRight size={14} className="transition-transform duration-200 data-[state=open]:rotate-90" />
                                    {t('chat.thoughts')} ({msg.thoughts.length})
                                </Collapsible.Trigger>
                                <Collapsible.Content className="mt-2 space-y-2 pl-6 border-l-2 border-border">
                                    {msg.thoughts.map((thought, idx) => (
                                        <div key={idx} className="text-xs text-muted-foreground italic bg-muted/30 p-2 rounded">
                                            {thought}
                                        </div>
                                    ))}
                                </Collapsible.Content>
                            </Collapsible.Root>
                        </div>
                    )}
                    
                    {msg.role === 'ai' ? (
                        <>
                             {msg.isLoading && !msg.content && !msg.sql && (
                                <div className="flex items-center gap-2 text-muted-foreground italic">
                                    <Loader2 size={14} className="animate-spin" />
                                    {t('chat.thinking')}
                                </div>
                            )}
                            {msg.content && (
                                <div className="prose prose-sm max-w-none prose-slate dark:prose-invert">
                                    <ReactMarkdown remarkPlugins={[remarkGfm]}>{msg.content}</ReactMarkdown>
                                </div>
                            )}
                            {msg.sql && (
                                <div className="mt-4 border border-border rounded-md overflow-hidden bg-muted">
                                    <div className="bg-muted px-3 py-1.5 text-xs font-mono text-muted-foreground border-b border-border flex justify-between items-center">
                                        <span>SQL Generated</span>
                                        <button className="hover:text-primary transition-colors">Copy</button>
                                    </div>
                                    <pre className="p-3 overflow-x-auto text-xs font-mono text-foreground">
                                        {msg.sql}
                                    </pre>
                                </div>
                            )}
                            {msg.chartOption && (
                                <div className="mt-4 h-64 border border-border rounded-md bg-card p-2">
                                    <ChartRenderer option={msg.chartOption} />
                                </div>
                            )}
                            {msg.isError && (
                                <div className="flex items-center gap-2 text-destructive text-xs mt-2 bg-destructive/10 p-2 rounded border border-destructive/20">
                                    <AlertCircle size={14} />
                                    <span>Error processing request</span>
                                </div>
                            )}
                        </>
                    ) : (
                        msg.content
                    )}
                </div>
            </div>
        ))}
        <div ref={messagesEndRef} />
      </>
        )}
      </div>

      {/* Input Area */}
      <div className="flex-shrink-0 p-4 md:p-6 bg-background border-t border-border z-20">
        <div className="max-w-4xl mx-auto relative">
            <div className="absolute left-3 top-3 text-muted-foreground">
                <Search size={20} />
            </div>
            <textarea 
                ref={textareaRef}
                value={input}
                onChange={handleInput}
                onKeyDown={handleKeyDown}
                placeholder={t('chat.inputPlaceholder')}
                className="w-full pl-10 pr-12 py-3 bg-muted/30 border border-input rounded-xl focus:outline-none focus:ring-2 focus:ring-ring/20 focus:border-ring transition-all resize-none min-h-[50px] max-h-[200px] shadow-sm text-sm text-foreground placeholder:text-muted-foreground"
                rows={1}
                aria-label="Chat input"
            />
            <button 
                onClick={handleSendMessage}
                disabled={!input.trim() || isStreaming}
                aria-label="Send message"
                className={`absolute right-2 top-2 p-1.5 rounded-lg transition-all ${
                    input.trim() && !isStreaming 
                        ? "bg-primary text-primary-foreground hover:bg-primary/90 shadow-md hover:shadow-lg transform hover:-translate-y-0.5" 
                        : "bg-muted text-muted-foreground cursor-not-allowed"
                }`}
            >
                {isStreaming ? <Loader2 size={20} className="animate-spin" /> : <Play size={20} fill="currentColor" />}
            </button>
        </div>
        <div className="max-w-4xl mx-auto mt-2 text-center">
            <p className="text-[10px] text-muted-foreground">
                {t('chat.footer')}
            </p>
        </div>
      </div>
    </div>
  );
}
