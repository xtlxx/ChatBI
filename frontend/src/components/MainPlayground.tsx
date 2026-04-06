import { useState, useRef, useEffect, useCallback } from "react";
import { Share2, MoreVertical, PanelLeftClose, PanelLeftOpen, Loader2, Mic, Send, BarChart3, Database, TrendingUp, Package } from "lucide-react";
import { useOutletContext, useParams, useNavigate } from "react-router-dom";
import { useChatSettingsStore } from "@/store/chat-settings-store";
import { chatService } from "@/services/chat-service";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { ChatMessage } from "@/components/ChatMessage";
import { ModelSelector } from "@/components/ModelSelector";
import type { Message } from "@/types/chat";
import type { ChartOption } from "@/types/api";
import type { LayoutContext } from "@/types/layout";

import { speechService } from "@/services/speech-service";

const CONTAINER_CLASS = "w-full max-w-[min(95vw,1400px)] mx-auto transition-all duration-300 ease-in-out";

export function MainPlayground() {
    const { t } = useTranslation();
    const currentYear = new Date().getFullYear(); // 动态获取当前年份
    const {
        isLeftSidebarOpen,
        setIsLeftSidebarOpen,
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
    const shouldAutoScroll = useRef(true);

    const [isListening, setIsListening] = useState(false);
    const mediaRecorderRef = useRef<MediaRecorder | null>(null);
    const audioChunksRef = useRef<Blob[]>([]);
    
    // 用于管理流式请求的 AbortController
    const abortControllerRef = useRef<AbortController | null>(null);

    const toggleListening = async () => {
        if (isListening) {
            // Stop recording
            if (mediaRecorderRef.current && mediaRecorderRef.current.state !== 'inactive') {
                mediaRecorderRef.current.stop();
            }
            return;
        }

        // Start recording
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            const mediaRecorder = new MediaRecorder(stream);
            mediaRecorderRef.current = mediaRecorder;
            audioChunksRef.current = [];

            mediaRecorder.ondataavailable = (e) => {
                if (e.data.size > 0) {
                    audioChunksRef.current.push(e.data);
                }
            };

            mediaRecorder.onstart = () => {
                setIsListening(true);
                toast.success(t('chat.listening') || 'Listening...', { icon: '🎙️', duration: 2000 });
            };

            mediaRecorder.onstop = async () => {
                setIsListening(false);
                stream.getTracks().forEach(track => track.stop()); // Clean up tracks
                
                if (audioChunksRef.current.length === 0) return;

                const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' }); 
                
                // --- Conversion to 16kHz PCM using Web Worker to avoid blocking UI ---
                try {
                    toast.loading(t('chat.recognizing') || 'Recognizing speech...', { id: 'speech-recognition' });
                    
                    const arrayBuffer = await audioBlob.arrayBuffer();
                    
                    // 兼容性与静默失败处理：检查 AudioContext
                    const AudioContextClass = window.AudioContext || (window as any).webkitAudioContext;
                    if (!AudioContextClass) {
                        throw new Error('Your browser does not support AudioContext');
                    }
                    
                    const audioContext = new AudioContextClass({ sampleRate: 16000 });
                    
                    let audioBufferDecoded;
                    try {
                        audioBufferDecoded = await audioContext.decodeAudioData(arrayBuffer);
                    } catch (decodeErr) {
                        console.error('Audio decode error:', decodeErr);
                        throw new Error('Failed to decode audio data');
                    }

                    const channelData = audioBufferDecoded.getChannelData(0);
                    
                    // Create worker and send data
                    const worker = new Worker(new URL('../workers/audio-worker.ts', import.meta.url), { type: 'module' });
                    
                    // 设置超时机制 (例如 15 秒)
                    const timeoutId = setTimeout(() => {
                        worker.terminate();
                        toast.error(t('chat.recognizeTimeout') || 'Speech recognition timed out', { id: 'speech-recognition' });
                    }, 15000);

                    worker.onmessage = async (e) => {
                        clearTimeout(timeoutId);
                        worker.terminate(); // Clean up worker
                        
                        if (e.data.success) {
                            const pcmBlob = e.data.blob;
                            // Send to backend
                            try {
                                const result = await speechService.recognizeSpeech(pcmBlob);
                                
                                if (result.success && result.text) {
                                    setInput(prev => prev + (prev ? ' ' : '') + result.text);
                                    toast.success(t('chat.recognizeSuccess') || 'Recognized', { id: 'speech-recognition' });
                                } else {
                                    toast.error(t('chat.recognizeEmpty') || 'No speech recognized', { id: 'speech-recognition' });
                                }
                            } catch (apiErr) {
                                console.error('Speech API error:', apiErr);
                                toast.error(t('chat.micError') || 'Recognition API failed', { id: 'speech-recognition' });
                            }
                        } else {
                            console.error('Worker error:', e.data.error);
                            toast.error(t('chat.micError') || 'Microphone error', { id: 'speech-recognition' });
                        }
                    };
                    
                    worker.onerror = (err) => {
                        clearTimeout(timeoutId);
                        console.error('Worker thread error:', err);
                        toast.error(t('chat.micError') || 'Microphone error', { id: 'speech-recognition' });
                        worker.terminate();
                    };
                    
                    // Pass ArrayBuffer directly to avoid copying cost
                    worker.postMessage({ 
                        audioBuffer: channelData.buffer,
                        sampleRate: 16000
                    }, [channelData.buffer]);
                    
                } catch (error) {
                    console.error('Speech recognition setup error', error);
                    toast.error(t('chat.micError') || 'Microphone error', { id: 'speech-recognition' });
                }
            };

            mediaRecorder.start();
        } catch (error) {
            console.error('Microphone access error:', error);
            toast.error(t('chat.micPermissionDenied') || 'Microphone access denied');
        }
    };

    // Initialize Session
    const loadSessionHistory = useCallback(async (id: string) => {
        try {
            setIsLoadingHistory(true);
            const session = await chatService.getSession(id);

            // Map backend messages to frontend format
            const mappedMessages: Message[] = session.messages.map(msg => ({
                id: msg.id,
                role: msg.role === 'system' ? 'ai' : (msg.role as 'user' | 'ai'), // Treat system as AI for now or hide it
                content: msg.content,
                thinking: msg.message_metadata?.thinking,
                thinkingStatus: msg.message_metadata?.thinking ? 'completed' : undefined,
                sql: msg.message_metadata?.sql_query,
                data: (msg.message_metadata?.execution_result as any)?.data || msg.message_metadata?.data, // 兼容不同的数据保存路径
                chartOption: (msg.message_metadata?.chartOption || msg.message_metadata?.chart_data) as ChartOption, // 兼容旧数据 chart_data
                executionTime: msg.message_metadata?.execution_time ? `${msg.message_metadata.execution_time}秒` : undefined,
                executionSeconds: msg.message_metadata?.execution_time ? Number(msg.message_metadata.execution_time) : undefined,
                timestamp: msg.created_at ? new Date(msg.created_at).getTime() : Date.now(),
                isHistory: true // 标记为历史记录
            }));

            setMessages(mappedMessages);
            shouldAutoScroll.current = true;
        } catch (error) {
            console.error("Failed to load session", error);
            toast.error(t('chat.loadHistoryError'));
        } finally {
            setIsLoadingHistory(false);
        }
    }, [t]);

    useEffect(() => {
        if (!routeSessionId || routeSessionId === 'new') {
            setSessionId(crypto.randomUUID());
            setMessages([]);
        } else {
            setSessionId(routeSessionId);
            loadSessionHistory(routeSessionId);
        }
    }, [routeSessionId, loadSessionHistory]);

    const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
        const { scrollTop, scrollHeight, clientHeight } = e.currentTarget;
        const isAtBottom = scrollHeight - scrollTop - clientHeight < 50;
        shouldAutoScroll.current = isAtBottom;
    };

    const scrollToBottom = useCallback((instant = false) => {
        if (messagesEndRef.current) {
            messagesEndRef.current.scrollIntoView({
                behavior: instant ? "auto" : "smooth",
                block: "end"
            });
        }
    }, []);

    // Scroll on new message
    useEffect(() => {
        if (messages.length > 0) {
            scrollToBottom(false);
            shouldAutoScroll.current = true;
        }
    }, [messages.length, scrollToBottom]);

    // Scroll on streaming updates
    useEffect(() => {
        if (isStreaming && shouldAutoScroll.current) {
            requestAnimationFrame(() => {
                if (messagesEndRef.current) {
                    messagesEndRef.current.scrollIntoView({ behavior: "auto", block: "end" });
                }
            });
        }
    }, [messages, isStreaming]);

    // 清理副作用
    useEffect(() => {
        return () => {
            if (abortControllerRef.current) {
                abortControllerRef.current.abort();
            }
        };
    }, []);

    const handleSendMessage = async () => {
        if (!input.trim() || isStreaming) return;

        if (!selectedConnectionId || !selectedLlmConfigId) {
            toast.error(t('chat.selectConnectionError'));
            setSidebarView('settings');
            if (!isLeftSidebarOpen) setIsLeftSidebarOpen(true);
            return;
        }

        const currentInput = input;
        const userMsg: Message = {
            id: crypto.randomUUID(),
            role: 'user',
            content: currentInput,
            timestamp: Date.now()
        };

        const aiMsgId = crypto.randomUUID();
        const aiMsg: Message = {
            id: aiMsgId,
            role: 'ai',
            content: '',
            thinking: '',
            thinkingStatus: 'idle',
            isLoading: true,
            timestamp: Date.now()
        };

        setMessages(prev => [...prev, userMsg, aiMsg]);
        setInput("");
        setIsStreaming(true);

        if (textareaRef.current) {
            textareaRef.current.style.height = 'auto';
        }

        // 创建新的 AbortController
        abortControllerRef.current = new AbortController();

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
                    setMessages(prev => {
                        const newMessages = [...prev];
                        const msgIndex = newMessages.findIndex(m => String(m.id) === String(aiMsgId));
                        if (msgIndex === -1) return prev;

                        const msg = { ...newMessages[msgIndex] };

                        if (event.type === 'thinking') {
                            msg.thinking = (msg.thinking || '') + event.content;
                            // Only set to thinking if not already completed or error to prevent status reversion
                            if (msg.thinkingStatus !== 'completed' && msg.thinkingStatus !== 'error') {
                                msg.thinkingStatus = 'thinking';
                                msg.status = t('chat.status.thinking');
                            }
                        } else if (event.type === 'sql_generated') {
                            msg.sql = event.content;
                            msg.status = t('chat.status.sqlGenerated');
                            if (msg.thinkingStatus === 'thinking') {
                                msg.thinkingStatus = 'completed';
                            }
                            if (event.thought) {
                                const separator = msg.sqlThought ? '\n\n---\n\n' : '';
                                msg.sqlThought = (msg.sqlThought || '') + separator + event.thought;
                            }
                        } else if (event.type === 'status') {
                            msg.status = event.content;
                        } else if (event.type === 'execution_result') {
                            msg.executionResult = event.content;
                            msg.data = event.data; // Capture raw data for data preview
                            msg.status = t('chat.status.querying');
                        } else if (event.type === 'answer_chunk') {
                            msg.content = (msg.content || '') + event.content;
                            msg.status = undefined; // 清除状态，开始显示内容
                            if (msg.thinkingStatus === 'thinking' || msg.thinkingStatus === 'idle') {
                                msg.thinkingStatus = 'completed';
                            }
                        } else if (event.type === 'chart_parse_error') {
                            // 图表解析失败降级处理
                            msg.chartOption = undefined;
                            msg.content = (msg.content || '') + '\n\n⚠️ ' + event.content;
                            msg.status = t('chat.status.chartError');
                            toast.error(event.content);
                        } else if (event.type === 'final_answer') {
                            // 收到最终回答时，替换（而不是追加）content，清除之前的错误
                            msg.content = event.content;
                            if (event.sql) msg.sql = event.sql;
                            if (event.thinking) msg.thinking = event.thinking;
                            msg.chartOption = event.chartOption;
                            msg.status = undefined;
                            msg.isLoading = false;        // ✅ 关键修复：结束加载状态
                            msg.isError = false;          // 清除错误状态
                            msg.retryErrors = undefined;  // 清除重试错误
                            if (msg.thinkingStatus === 'thinking' || msg.thinkingStatus === 'idle') {
                                msg.thinkingStatus = 'completed';
                            }
                        } else if (event.type === 'error') {
                            let errorMsg = event.content;
                            if (errorMsg === 'Global Processing Error') {
                                errorMsg = t('errors.globalException');
                            } else if (errorMsg.startsWith('Global Processing Error:')) {
                                errorMsg = t('errors.globalException') + errorMsg.substring('Global Processing Error'.length);
                            }
                            if (event.done) {
                                // done=true 的 error 是终态错误，直接显示
                                msg.isLoading = false;
                                msg.isError = true;
                                msg.thinkingStatus = 'error';
                                msg.content = errorMsg;
                                msg.status = undefined;
                            } else {
                                // done=false 的 error 是中间重试错误，收集到 retryErrors
                                if (!msg.retryErrors) msg.retryErrors = [];
                                msg.retryErrors.push(errorMsg);
                                msg.status = t('chat.status.retrying');
                            }
                        } else if (event.type === 'end') {
                            msg.isLoading = false;
                            msg.status = undefined;

                            // Ensure thinking stops when stream ends
                            if (msg.thinkingStatus === 'thinking') {
                                msg.thinkingStatus = 'completed';
                            }

                            // 如果有重试错误但没有正常内容，标记为最终错误
                            if (msg.retryErrors?.length && !msg.content) {
                                msg.isError = true;
                                msg.thinkingStatus = 'error';
                                msg.content = msg.retryErrors[msg.retryErrors.length - 1];
                            }
                        } else if (event.type === 'execution_time') {
                            // 处理执行时间
                            msg.executionTime = event.content as string;
                            msg.executionSeconds = event.seconds;
                        }

                        newMessages[msgIndex] = msg;
                        return newMessages;
                    });
                },
                (err) => {
                    // 忽略 AbortError，这是因为组件卸载导致的取消
                    if (err.name === 'AbortError') {
                        console.log('Stream aborted correctly');
                        return;
                    }
                    console.error("Stream error", err);
                    toast.error(t('chat.sendMessageError'));

                    let displayError = err.message;
                    if (displayError.includes('Error processing request') || displayError.includes('Failed to fetch') || displayError === 'Global Processing Error') {
                        displayError = t('errors.globalException');
                    }

                    setMessages(prev => {
                        const newMessages = [...prev];
                        const msgIndex = newMessages.findIndex(m => String(m.id) === String(aiMsgId));
                        if (msgIndex !== -1) {
                            newMessages[msgIndex] = {
                                ...newMessages[msgIndex],
                                isLoading: false,
                                isError: true,
                                thinkingStatus: 'error',
                                content: newMessages[msgIndex].content + `\n\n*(系统提示: ${displayError})*`
                            };
                        }
                        return newMessages;
                    });
                    setIsStreaming(false);
                },
                () => {
                    setIsStreaming(false);
                    setMessages(prev => {
                        const newMessages = [...prev];
                        const msgIndex = newMessages.findIndex(m => String(m.id) === String(aiMsgId));
                        if (msgIndex !== -1) {
                            const msg = newMessages[msgIndex];
                            if (msg.isLoading) {
                                newMessages[msgIndex] = {
                                    ...msg,
                                    isLoading: false,
                                    status: undefined
                                };
                            }
                        }
                        return newMessages;
                    });

                    if (!routeSessionId || routeSessionId === 'new') {
                        navigate(`/chat/${sessionId}`, { replace: true });
                    }
                },
                abortControllerRef.current.signal
            );
        } catch (error: any) {
            if (error.name === 'AbortError') {
                console.log('Fetch aborted');
                return;
            }
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

    const handleInput = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
        setInput(e.target.value);
        e.target.style.height = 'auto';
        e.target.style.height = `${Math.min(e.target.scrollHeight, 200)}px`;
    };

    return (
        <div className="flex-1 flex flex-col h-full bg-muted/10 min-w-0 relative">
            <div className="h-16 flex justify-between items-center px-4 md:px-6 flex-shrink-0 z-10 bg-background/80 backdrop-blur-md sticky top-0">
                <div className="flex items-center gap-2">
                    <button
                        onClick={onToggleLeftSidebar}
                        className="p-2 hover:bg-muted rounded-full text-muted-foreground transition-colors"
                        title={isLeftSidebarOpen ? "Close Sidebar" : "Open Sidebar"}
                        aria-label={isLeftSidebarOpen ? t('sidebar.close') : t('sidebar.open')}
                    >
                        {isLeftSidebarOpen ? <PanelLeftClose size={20} /> : <PanelLeftOpen size={20} />}
                    </button>

                    <div className="flex items-center gap-2 px-2">
                        <span className="font-medium text-lg text-foreground flex items-center gap-2">
                            KY Data Pilot <span className="text-muted-foreground text-sm font-normal opacity-50">Pro</span>
                        </span>
                    </div>
                </div>
                <div className="flex items-center gap-1">
                    <div className="hidden md:block">
                        <ModelSelector onOpenSettings={() => {
                            setSidebarView('settings');
                            if (!isLeftSidebarOpen) setIsLeftSidebarOpen(true);
                        }} />
                    </div>
                    <button className="p-2 hover:bg-muted rounded-full text-muted-foreground transition-colors" aria-label="Share">
                        <Share2 size={18} />
                    </button>
                    <button className="p-2 hover:bg-muted rounded-full text-muted-foreground transition-colors" aria-label="More options">
                        <MoreVertical size={18} />
                    </button>
                </div>
            </div>

            <div
                className="flex-1 overflow-y-auto p-4 md:p-8 space-y-8 pb-40 scroll-smooth"
                onScroll={handleScroll}
            >
                {isLoadingHistory ? (
                    <div className="flex flex-col items-center justify-center h-full text-muted-foreground gap-3">
                        <Loader2 className="animate-spin text-primary" size={32} />
                        <p className="text-sm font-medium animate-pulse">{t('chat.loadingHistory')}</p>
                    </div>
                ) : (
                    <>
                        {messages.length === 0 && (
                            <div className={`flex flex-col items-center justify-center h-full ${CONTAINER_CLASS}`}>
                                <div className="text-left w-full mb-10 animate-fade-in-up">
                                    <h1 className="text-4xl md:text-5xl font-semibold tracking-tight text-transparent bg-clip-text bg-gradient-to-r from-blue-600 via-purple-500 to-pink-500 mb-3">
                                        {t('intro.title')}
                                    </h1>
                                    <p className="text-lg text-muted-foreground/60">
                                        {t('intro.subtitle')}
                                    </p>
                                </div>

                                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3 w-full animate-fade-in-up delay-100">
                                    {[
                                        { key: 'sales', icon: TrendingUp, color: "from-blue-500/10 to-blue-600/5 hover:border-blue-300 dark:hover:border-blue-700" },
                                        { key: 'customer', icon: BarChart3, color: "from-purple-500/10 to-purple-600/5 hover:border-purple-300 dark:hover:border-purple-700" },
                                        { key: 'material', icon: Package, color: "from-emerald-500/10 to-emerald-600/5 hover:border-emerald-300 dark:hover:border-emerald-700" },
                                        { key: 'inventory', icon: Database, color: "from-amber-500/10 to-amber-600/5 hover:border-amber-300 dark:hover:border-amber-700" }
                                    ].map((item) => (
                                        <button
                                            key={item.key}
                                            onClick={() => setInput(t(`intro.examples.${item.key}.desc`, { year: currentYear }))}
                                            className={`flex flex-col gap-3 p-4 rounded-xl bg-gradient-to-br ${item.color} border border-border/50 transition-all text-left group hover:shadow-md hover:-translate-y-0.5 duration-200`}
                                        >
                                            <div className="p-2.5 bg-background/80 w-fit rounded-xl shadow-sm">
                                                <item.icon size={18} className="text-primary" />
                                            </div>
                                            <div>
                                                <p className="font-semibold text-foreground text-sm mb-0.5">{t(`intro.examples.${item.key}.label`)}</p>
                                                <p className="text-xs text-muted-foreground leading-relaxed">{t(`intro.examples.${item.key}.desc`, { year: currentYear })}</p>
                                            </div>
                                        </button>
                                    ))}
                                </div>
                            </div>
                        )}

                        {messages.map((msg) => (
                            <ChatMessage key={msg.id} message={msg} containerClass={CONTAINER_CLASS} />
                        ))}
                        <div ref={messagesEndRef} />
                    </>
                )}
            </div>

            <div className={`flex-shrink-0 p-4 bg-background z-20 ${CONTAINER_CLASS}`}>
                <div className="relative flex items-end gap-2 bg-muted/50 hover:bg-muted/80 focus-within:bg-muted transition-colors rounded-[28px] p-2 pl-4 border border-transparent focus-within:border-border/50 focus-within:shadow-md ring-offset-2 focus-within:ring-2 ring-primary/10">
                    <textarea
                        ref={textareaRef}
                        value={input}
                        onChange={handleInput}
                        onKeyDown={handleKeyDown}
                        placeholder={t('chat.inputPlaceholder')}
                        className="w-full py-3 bg-transparent border-none focus:outline-none focus:ring-0 resize-none min-h-[48px] max-h-[200px] text-base text-foreground placeholder:text-muted-foreground/70"
                        rows={1}
                        aria-label="Chat input"
                    />

                    <div className="flex items-center gap-1 pb-1.5 pr-2">
                        {!input.trim() && (
                            <>
                                <button 
                                    className={`p-2 rounded-full transition-all ${isListening ? 'text-red-500 bg-red-100 dark:bg-red-900/30 animate-pulse' : 'text-muted-foreground hover:text-primary hover:bg-background'}`}
                                    aria-label="Voice input"
                                    onClick={toggleListening}
                                >
                                    <Mic size={20} />
                                </button>
                            </>
                        )}

                        {input.trim() ? (
                            <button
                                onClick={handleSendMessage}
                                disabled={isStreaming}
                                aria-label="Send message"
                                className="p-2 bg-primary text-primary-foreground rounded-full shadow-md hover:shadow-lg transition-all hover:scale-105 active:scale-95 flex items-center justify-center w-10 h-10"
                            >
                                {isStreaming ? <Loader2 size={18} className="animate-spin" /> : <Send size={18} className="ml-0.5" />}
                            </button>
                        ) : (
                            <button
                                disabled
                                className="p-2 text-muted-foreground/60 cursor-not-allowed rounded-full w-10 h-10 flex items-center justify-center"
                            >
                                <Send size={18} className="ml-0.5" />
                            </button>
                        )}
                    </div>
                </div>
                <div className="mt-3 text-center">
                    <p className="text-[11px] text-muted-foreground/70">
                        {t('chat.footer')}
                    </p>
                </div>
            </div>
        </div>
    );
}
