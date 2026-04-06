import { memo, useState, useEffect, useRef, Suspense, lazy, useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { AlertCircle, CheckCircle2, Sparkles, ChevronDown, ChevronRight, RefreshCw, Database, Table, Copy, Check, Loader2 } from 'lucide-react';
import ReactMarkdown, { type Components } from 'react-markdown';
import remarkGfm from 'remark-gfm';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import 'katex/dist/katex.min.css';
import * as Dialog from '@radix-ui/react-dialog';

// 引入成熟的语法高亮库
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { vscDarkPlus, vs } from 'react-syntax-highlighter/dist/esm/styles/prism';
import { useThemeStore } from '@/store/theme-store';

import { ThinkingState } from './ThinkingState';
import { ErrorBoundary } from '@/components/ui/ErrorBoundary';
import { SqlBlock } from '@/components/ui/SqlBlock';
import { MermaidDiagram } from '@/components/ui/MermaidDiagram';
import { cleanMarkdownContent } from '@/lib/utils';
import type { Message } from '@/types/chat';
import { useSmoothStream } from '@/hooks/useSmoothStream';

const ChartRenderer = lazy(() => import('@/components/ChartRenderer').then(module => ({ default: module.ChartRenderer })));

const MemoizedMarkdown = memo(({ content, components }: { content: string, components: Components }) => (
    <ReactMarkdown 
        remarkPlugins={[remarkGfm, remarkMath]}
        rehypePlugins={[rehypeKatex]}
        components={components}
    >
        {content}
    </ReactMarkdown>
), (prevProps, nextProps) => prevProps.content === nextProps.content);

interface ChatMessageProps {
    message: Message;
    containerClass?: string;
}

export const ChatMessage = memo(({ message: msg, containerClass }: ChatMessageProps) => {
    const { t } = useTranslation();
    const { theme } = useThemeStore();
    
    // 判断当前是否为暗黑模式，用于代码高亮主题
    const isDark = theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);

    const [showRetryDetails, setShowRetryDetails] = useState(false);
    const [showTypewriter, setShowTypewriter] = useState(true);

    // 修复原因一：不再在拦截入口处直接清洗。因为清洗会导致 `newContent` 频繁发生结构性改变
    // 我们将其拆分为两步：
    // 1. `rawContent` 作为平滑流处理的原始数据源，不进行清理
    const rawContent = msg.content;

    const [displayedText, setDisplayedText] = useState('');
    const [throttledDisplayedText, setThrottledDisplayedText] = useState(''); // 用于实际渲染的节流文本
    const prevContentRef = useRef('');
    
    // 是否需要流式效果：仅对 AI 消息且有内容、非错误时，且不是历史记录时才开启打字机效果
    const shouldStream = showTypewriter && msg.role === 'ai' && !msg.isError && !msg.isHistory;
    // 判断流是否结束：非 loading 即为结束
    const streamDone = !msg.isLoading;

    // 修复原因三：增加 Throttle 层。避免每次 setState 都触发 ReactMarkdown 的全量 AST 重解析
    const lastRenderTimeRef = useRef<number>(0);
    const throttleDelay = 50; // 最快 50ms 渲染一次

    useEffect(() => {
        const now = performance.now();
        if (now - lastRenderTimeRef.current >= throttleDelay || streamDone) {
            setThrottledDisplayedText(displayedText);
            lastRenderTimeRef.current = now;
        } else {
            // 兜底：确保最后一点文本一定会被渲染出来
            const timer = setTimeout(() => {
                setThrottledDisplayedText(displayedText);
                lastRenderTimeRef.current = performance.now();
            }, throttleDelay);
            return () => clearTimeout(timer);
        }
    }, [displayedText, streamDone]);

    const { addChunk, reset } = useSmoothStream({
        onUpdate: setDisplayedText,
        streamDone: streamDone,
        minDelay: 10
    });

    // 计算打字机状态
    const isTyping = shouldStream && displayedText.length < (rawContent || '').length;
    const progress = rawContent && rawContent.length > 0 ? displayedText.length / rawContent.length : 1;

    // 监听 rawContent 变化
    useEffect(() => {
        const newContent = rawContent || '';
        const oldContent = prevContentRef.current;

        // 如果内容没变，不做任何事
        if (newContent === oldContent) return;

        if (shouldStream) {
            if (newContent.startsWith(oldContent)) {
                const delta = newContent.slice(oldContent.length);
                addChunk(delta);
            } else {
                reset(newContent);
            }
        }
        prevContentRef.current = newContent;
    }, [rawContent, shouldStream, addChunk, reset]);

    // 当新消息到达或从流式切换到非流式时重置状态
    useEffect(() => {
        prevContentRef.current = '';
        reset('');
        setThrottledDisplayedText('');
    }, [msg.id, reset, shouldStream]);

    // 不流式时，直接显示内容（使用 derived state）
    // 修复原因一：在实际渲染的最末端，再去调用 `cleanMarkdownContent`，确保流状态不会被其干扰
    const finalDisplayedText = shouldStream 
        ? cleanMarkdownContent(throttledDisplayedText) 
        : cleanMarkdownContent(rawContent || '');

    // 打字完成后允许跳过效果
    const handleSkipTyping = () => {
        setShowTypewriter(false);
    };

    const [isCopied, setIsCopied] = useState(false);
    const handleCopyAll = () => {
        if (!finalDisplayedText) return;
        navigator.clipboard.writeText(finalDisplayedText).then(() => {
            setIsCopied(true);
            setTimeout(() => setIsCopied(false), 2000);
        });
    };

    // 自定义 Markdown 组件，特别是代码块的语法高亮
    const markdownComponents: Components = useMemo(() => ({
        code(props) {
            const { children, className, node, ...rest } = props;
            const match = /language-(\w+)/.exec(className || '');
            const isInline = !match && !className;
            
            if (!isInline && match) {
                const language = match[1].toLowerCase();
                const codeString = String(children).replace(/\n$/, '');

                if (language === 'sql') {
                    return <SqlBlock sql={codeString} />;
                }
                
                if (language === 'mermaid') {
                    return <MermaidDiagram chart={codeString} />;
                }

                return (
                    <div className="relative group rounded-md overflow-hidden bg-[#1e1e1e] border border-zinc-800/50 mt-3 mb-4">
                        <div className="flex items-center justify-between px-3 py-1.5 bg-zinc-900 border-b border-zinc-800">
                            <span className="text-xs font-mono text-zinc-400 select-none">
                                {language}
                            </span>
                            <button
                                onClick={() => {
                                    navigator.clipboard.writeText(codeString);
                                }}
                                className="p-1.5 text-zinc-400 hover:text-zinc-100 hover:bg-zinc-800 rounded-md transition-colors opacity-0 group-hover:opacity-100"
                                aria-label="Copy code"
                            >
                                <Copy size={14} />
                            </button>
                        </div>
                        <div className="text-[13px] leading-relaxed [&>pre]:!m-0 [&>pre]:!p-4 [&>pre]:!bg-transparent">
                            <SyntaxHighlighter
                                {...(rest as any)}
                                PreTag="div"
                                children={codeString}
                                language={language}
                                style={isDark ? vscDarkPlus : vs}
                                customStyle={{
                                    margin: 0,
                                    padding: '1rem',
                                    background: 'transparent',
                                    fontSize: '13px',
                                    lineHeight: '1.5'
                                }}
                                wrapLongLines={false}
                            />
                        </div>
                    </div>
                );
            }
            return (
                <code {...rest} className={`bg-muted/50 rounded-md px-1.5 py-0.5 text-sm font-mono text-foreground border border-border/50 ${className || ''}`}>
                    {children}
                </code>
            );
        },
        table(props) {
            const { children, className, node, ...rest } = props;
            return (
                <div className="w-full overflow-x-auto my-4 rounded-lg border border-border">
                    <table {...rest} className={`w-full text-sm text-left border-collapse ${className || ''}`}>
                        {children}
                    </table>
                </div>
            );
        }
    }), [isDark, t]);

    return (
        <div className={`flex gap-3 md:gap-4 group ${containerClass || ''} ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>

            {msg.role === 'ai' && (
                <div className="flex-shrink-0 mt-1">
                    <div className={`w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 flex items-center justify-center shadow-lg shadow-blue-500/20 ${msg.isLoading ? 'animate-[spin_3s_linear_infinite]' : ''}`}>
                        <Sparkles size={14} className="text-white" />
                    </div>
                </div>
            )}

            <div className={`flex flex-col ${msg.role === 'user' ? 'max-w-[85%] md:max-w-[70%] items-end' : 'max-w-full flex-1 items-start'}`}>
                <div className={`text-base leading-7 rounded-2xl shadow-sm ${msg.role === 'user'
                    ? 'bg-blue-50 dark:bg-blue-900/20 text-foreground px-6 py-4 rounded-br-sm border border-blue-100 dark:border-blue-800/50'
                    : 'bg-transparent text-foreground w-full'
                    }`}>
                    {/* === 思考状态 === */}
                    {msg.role === 'ai' && (msg.thinking || msg.sqlThought) && (
                        <div className="mb-4">
                            <ThinkingState
                                status={msg.thinkingStatus}
                                content={msg.thinking || (msg.sqlThought ? `**技术思考 (SQL Strategy):**\n${msg.sqlThought}` : '')}
                                currentStep={msg.status}
                            />
                        </div>
                    )}

                    {msg.role === 'ai' ? (
                        <>
                            {/* === 加载骨架屏 === */}
                            {msg.isLoading && !msg.content && (!msg.thinking || msg.thinking.trim().length === 0) && (
                                <div className="space-y-3 animate-pulse">
                                    <div className="flex items-center gap-3">
                                        <div className="relative">
                                            <div className="w-5 h-5 rounded-full border-2 border-blue-300 border-t-blue-600 animate-spin" />
                                        </div>
                                        <span className="text-sm text-muted-foreground">
                                            {msg.status || t('chat.status.connecting')}
                                        </span>
                                    </div>
                                </div>
                            )}

                            {/* === 状态标签 === */}
                            {msg.isLoading && (msg.content || msg.thinking) && msg.status && !msg.status.includes('Thinking') && (
                                <div className="flex items-center gap-2 text-xs text-blue-600 dark:text-blue-400 mb-3 py-1.5 px-3 bg-blue-500/5 rounded-lg border border-blue-200/30 dark:border-blue-800/30 w-fit">
                                    <div className="w-3.5 h-3.5 rounded-full border-[1.5px] border-blue-400 border-t-blue-600 animate-spin" />
                                    <span className="font-medium">{msg.status}</span>
                                </div>
                            )}

                            {/* === 重试错误（折叠显示） === */}
                            {msg.retryErrors && msg.retryErrors.length > 0 && !msg.isError && (
                                <div className="mb-3">
                                    <button
                                        onClick={() => setShowRetryDetails(!showRetryDetails)}
                                        className="flex items-center gap-1.5 text-xs text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 transition-colors py-1.5 px-3 bg-amber-50/80 dark:bg-amber-950/20 rounded-lg border border-amber-200/50 dark:border-amber-800/30"
                                    >
                                        <RefreshCw size={12} />
                                        <span>{t('chat.status.retrySuccess', { count: msg.retryErrors.length })}</span>
                                        {showRetryDetails ? <ChevronDown size={12} /> : <ChevronRight size={12} />}
                                    </button>
                                    {showRetryDetails && (
                                        <div className="mt-2 text-xs text-muted-foreground space-y-1 pl-3 border-l-2 border-amber-200 dark:border-amber-800">
                                            {msg.retryErrors.map((e, i) => (
                                                <p key={i} className="truncate max-w-[600px]">{t('chat.status.retryError', { count: i + 1, error: e })}</p>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            )}

                            {/* === SQL BLOCK === */}
                            {msg.sql && (
                                <SqlBlock sql={msg.sql} />
                            )}

                            {/* === 执行结果 / 原始数据预览 === */}
                            {msg.executionResult && (
                                <div className="my-3 flex items-center justify-between px-3 py-2.5 bg-emerald-50/50 dark:bg-emerald-950/20 rounded-lg border border-emerald-200/50 dark:border-emerald-800/30">
                                    <div className="flex items-center gap-2.5 text-xs">
                                        <CheckCircle2 size={14} className="text-emerald-500 flex-shrink-0" />
                                        <span className="text-emerald-700 dark:text-emerald-300 font-medium">{msg.executionResult}</span>
                                    </div>
                                    
                                    {/* 提供查看原始数据的入口 */}
                                    {msg.data && Array.isArray(msg.data) && msg.data.length > 0 && (
                                        <Dialog.Root>
                                            <Dialog.Trigger asChild>
                                                <button className="flex items-center gap-1 text-[10px] text-emerald-600 hover:text-emerald-700 dark:text-emerald-400 dark:hover:text-emerald-300 bg-emerald-100/50 dark:bg-emerald-900/30 px-2 py-1 rounded transition-colors">
                                                    <Table size={12} />
                                                    <span>查看数据</span>
                                                </button>
                                            </Dialog.Trigger>
                                            <Dialog.Portal>
                                                <Dialog.Overlay className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 data-[state=open]:animate-fadeIn" />
                                                <Dialog.Content className="fixed left-[50%] top-[50%] translate-x-[-50%] translate-y-[-50%] w-[90vw] max-w-4xl max-h-[85vh] bg-background rounded-xl shadow-2xl border border-border flex flex-col z-50 data-[state=open]:animate-slideUp">
                                                    <div className="flex items-center justify-between px-4 py-3 border-b border-border">
                                                        <Dialog.Title className="text-sm font-semibold flex items-center gap-2">
                                                            <Database size={16} className="text-primary" />
                                                            原始查询结果 ({msg.data.length} 行)
                                                        </Dialog.Title>
                                                        <Dialog.Close asChild>
                                                            <button className="text-muted-foreground hover:text-foreground transition-colors">
                                                                <AlertCircle size={16} className="rotate-45" />
                                                            </button>
                                                        </Dialog.Close>
                                                    </div>
                                                    <div className="overflow-auto p-4 flex-1">
                                                        <div className="rounded-lg border border-border overflow-hidden">
                                                            <table className="w-full text-sm text-left">
                                                                <thead className="text-xs uppercase bg-muted/50 text-muted-foreground sticky top-0">
                                                                    <tr>
                                                                        {Object.keys(msg.data[0]).map(key => (
                                                                            <th key={key} className="px-4 py-3 font-medium whitespace-nowrap">{key}</th>
                                                                        ))}
                                                                    </tr>
                                                                </thead>
                                                                <tbody className="divide-y divide-border">
                                                                    {msg.data.slice(0, 100).map((row, i) => (
                                                                        <tr key={i} className="hover:bg-muted/30 transition-colors">
                                                                            {Object.values(row).map((val: any, j) => (
                                                                                <td key={j} className="px-4 py-2 whitespace-nowrap">
                                                                                    {val === null ? <span className="text-muted-foreground/50 italic">null</span> : String(val)}
                                                                                </td>
                                                                            ))}
                                                                        </tr>
                                                                    ))}
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                        {msg.data.length > 100 && (
                                                            <div className="text-center text-xs text-muted-foreground mt-3">
                                                                * 仅显示前 100 行数据，导出功能开发中
                                                            </div>
                                                        )}
                                                    </div>
                                                </Dialog.Content>
                                            </Dialog.Portal>
                                        </Dialog.Root>
                                    )}
                                </div>
                            )}

                            {/* === MAIN CONTENT (Markdown) === */}
                            {finalDisplayedText && (
                                <div 
                                    className="prose prose-neutral dark:prose-invert max-w-none prose-headings:font-semibold prose-headings:mt-6 prose-headings:mb-3 prose-p:my-3 prose-p:leading-7 prose-li:my-1 prose-ul:my-3 prose-ol:my-3 prose-table:text-sm prose-th:bg-muted/50 prose-th:px-4 prose-th:py-3 prose-td:px-4 prose-td:py-3 prose-table:border prose-table:rounded-lg prose-table:overflow-hidden prose-img:rounded-lg prose-pre:p-0 prose-pre:bg-transparent relative"
                                    aria-live={shouldStream ? "polite" : "off"}
                                    aria-atomic="false"
                                >
                                    {/* 打字机效果跳过按钮 */}
                                    {isTyping && (
                                        <button
                                            onClick={handleSkipTyping}
                                            className="mb-3 text-xs text-muted-foreground/60 hover:text-primary transition-colors flex items-center gap-1.5"
                                        >
                                            <Sparkles size={12} />
                                            {t('chat.status.skip')} · {Math.round(progress * 100)}%
                                        </button>
                                    )}
                                    <MemoizedMarkdown 
                                        components={markdownComponents}
                                        content={finalDisplayedText}
                                    />
                                </div>
                            )}

                            {/* === 图表 === */}
                            {msg.chartOption && (
                                <div className="mt-4 w-full overflow-hidden bg-white dark:bg-[#1a1a1a] rounded-xl border border-gray-100 dark:border-zinc-800/50 shadow-sm animate-in fade-in slide-in-from-bottom-2">
                                    <div className="px-4 py-2.5 border-b border-gray-100 dark:border-zinc-800/50 bg-gray-50/50 dark:bg-zinc-900/30 flex items-center justify-between">
                                        <div className="flex items-center gap-2 text-xs font-medium text-gray-600 dark:text-gray-300">
                                            <svg className="w-4 h-4 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                                            </svg>
                                            {t('chat.status.visualization')}
                                        </div>
                                    </div>
                                    <div className="p-2 sm:p-4 bg-white dark:bg-[#1a1a1a] w-full">
                                        <ErrorBoundary fallback={<div className="p-4 text-xs text-muted-foreground text-center">图表渲染失败，请检查数据格式。</div>}>
                                            <Suspense fallback={
                                                <div className="w-full h-[300px] sm:h-[400px] md:h-[450px] flex flex-col items-center justify-center gap-3 text-muted-foreground bg-muted/10 rounded-xl border border-dashed border-border/50">
                                                    <Loader2 className="w-6 h-6 animate-spin text-blue-500" />
                                                    <span className="text-sm">{t('common.loading')}...</span>
                                                </div>
                                            }>
                                                <div className="w-full h-[300px] sm:h-[400px] md:h-[450px] relative flex-shrink-0">
                                                    <ChartRenderer option={msg.chartOption} height="100%" />
                                                </div>
                                            </Suspense>
                                        </ErrorBoundary>
                                    </div>
                                </div>
                            )}

                            {/* === 错误（结构化展示）=== */}
                            {msg.isError && (
                                <div className="mt-4 p-4 rounded-lg border border-red-200 bg-red-50 dark:bg-red-950/10 dark:border-red-900/50 flex flex-col gap-3 animate-in fade-in slide-in-from-bottom-2">
                                    <div className="flex items-center gap-2 text-red-700 dark:text-red-400 font-medium">
                                        <AlertCircle size={18} />
                                        <span>{t('chat.status.failed')}</span>
                                    </div>
                                    
                                    {/* 仅当没有生成长篇 Markdown 报告，且内容真的是纯报错文本时才渲染 */}
                                    {msg.content && !finalDisplayedText && (
                                        <div className="text-xs text-red-600/90 dark:text-red-300/90 bg-white/50 dark:bg-black/20 p-3 rounded border border-red-100 dark:border-red-900/30 font-mono whitespace-pre-wrap break-all max-h-60 overflow-y-auto">
                                            {msg.content}
                                        </div>
                                    )}
                                    
                                    <div className="text-xs text-red-500/70 dark:text-red-400/50 flex items-center gap-1.5">
                                        <Sparkles size={12} />
                                        {t('chat.status.suggestion')}
                                    </div>
                                </div>
                            )}

                            {/* === 完成脚注 === */}
                            {!msg.isLoading && !msg.isError && (
                                <div className="mt-5 flex items-center justify-between text-[11px] text-muted-foreground/50 select-none">
                                    <div className="h-px flex-1 bg-gradient-to-r from-transparent via-border/50 to-transparent" />
                                    <div className="flex items-center gap-3 px-3">
                                        <span className="flex items-center gap-1">
                                            {msg.executionTime ? (
                                                <>
                                                    <CheckCircle2 size={10} />
                                                    {t('chat.status.completed')} · {msg.executionTime}
                                                </>
                                            ) : (
                                                <>
                                                    <CheckCircle2 size={10} />
                                                    {t('chat.status.completed')}
                                                </>
                                            )}
                                        </span>
                                        {finalDisplayedText && (
                                            <button 
                                                onClick={handleCopyAll}
                                                className="flex items-center gap-1 hover:text-foreground transition-colors"
                                                aria-label="Copy message"
                                                title="Copy full message"
                                            >
                                                {isCopied ? <Check size={12} className="text-emerald-500" /> : <Copy size={12} />}
                                                <span>{isCopied ? t('sqlBlock.copied') : t('sqlBlock.copy')}</span>
                                            </button>
                                        )}
                                    </div>
                                    <div className="h-px flex-1 bg-gradient-to-r from-transparent via-border/50 to-transparent" />
                                </div>
                            )}
                        </>
                    ) : (
                        msg.content
                    )}
                </div>
                {msg.role === 'user' && (
                    <div className="text-[10px] text-muted-foreground mt-1 mr-1 opacity-0 group-hover:opacity-100 transition-opacity">
                        {new Date(msg.timestamp).toLocaleTimeString()}
                    </div>
                )}
            </div>
        </div>
    );
});

ChatMessage.displayName = 'ChatMessage';
