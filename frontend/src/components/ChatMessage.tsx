import { memo, useState, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { AlertCircle, CheckCircle2, Sparkles, ChevronDown, ChevronRight, RefreshCw, SparklesIcon } from 'lucide-react';
import ReactMarkdown, { type Components } from 'react-markdown';
import remarkGfm from 'remark-gfm';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import 'katex/dist/katex.min.css';
import { ThinkingState } from './ThinkingState';
import { ChartRenderer } from '@/components/ChartRenderer';
import { SqlBlock } from '@/components/ui/SqlBlock';
import { cleanMarkdownContent } from '@/lib/utils';
import type { Message } from '@/types/chat';
import { useSmoothStream } from '@/hooks/useSmoothStream';

// Markdown 代码块中的 SQL 语法高亮器
function highlightSQLInMarkdown(code: string): string {
  const keywords = [
    'SELECT', 'FROM', 'WHERE', 'AND', 'OR', 'NOT', 'IN', 'IS', 'NULL',
    'JOIN', 'LEFT', 'RIGHT', 'INNER', 'OUTER', 'CROSS', 'ON',
    'GROUP', 'BY', 'ORDER', 'ASC', 'DESC', 'HAVING',
    'LIMIT', 'OFFSET', 'AS', 'DISTINCT', 'ALL', 'UNION',
    'INSERT', 'INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE',
    'CREATE', 'ALTER', 'DROP', 'TABLE', 'INDEX',
    'CASE', 'WHEN', 'THEN', 'ELSE', 'END',
    'BETWEEN', 'LIKE', 'EXISTS', 'WITH', 'RECURSIVE',
    'TRUE', 'FALSE', 'DEFAULT', 'LIMIT', 'OFFSET',
  ];

  const functions = [
    'COUNT', 'SUM', 'AVG', 'MIN', 'MAX', 'COALESCE', 'IFNULL', 'NULLIF',
    'DATE_FORMAT', 'DATE', 'NOW', 'CURDATE', 'YEAR', 'MONTH', 'DAY',
    'CONCAT', 'SUBSTRING', 'TRIM', 'UPPER', 'LOWER', 'LENGTH',
    'CAST', 'CONVERT', 'ROUND', 'FLOOR', 'CEIL', 'ABS',
    'GROUP_CONCAT', 'IF', 'DATEDIFF', 'DATE_ADD', 'DATE_SUB',
    'ROW_NUMBER', 'RANK', 'DENSE_RANK', 'LAG', 'LEAD', 'OVER', 'PARTITION',
  ];

  let result = code;

  // 转义 HTML，防止 XSS
  result = result.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  // 高亮单引号字符串
  result = result.replace(
    /('(?:[^'\\]|\\.)*')/g,
    '<span class="sql-string">$1</span>'
  );

  // 高亮数字，包括小数
  result = result.replace(
    /\b(\d+(?:\.\d+)?)\b/g,
    '<span class="sql-number">$1</span>'
  );

  // 高亮注释
  result = result.replace(
    /(--.*$)/gm,
    '<span class="sql-comment">$1</span>'
  );

  // 高亮关键词（不区分大小写，完整匹配）
  for (const kw of keywords) {
    const regex = new RegExp(`\\b(${kw})\\b`, 'gi');
    result = result.replace(regex, '<span class="sql-keyword">$1</span>');
  }

  // 高亮函数（不区分大小写，完整匹配）
  for (const fn of functions) {
    const regex = new RegExp(`\\b(${fn})\\s*(?=\\()`, 'gi');
    result = result.replace(regex, '<span class="sql-function">$1</span>');
  }

  // 高亮反引号字符串（标识符） ，包括空格
  // 注意：这与 SQL 语法不同，SQL 只允许反引号字符串（不包含空格）或单引号字符串
  result = result.replace(
    /(`[^`]+`)/g,
    '<span class="sql-identifier">$1</span>'
  );

  return result;
}

interface ChatMessageProps {
    message: Message;
    containerClass?: string;
}

export const ChatMessage = memo(({ message: msg, containerClass }: ChatMessageProps) => {
    const { t } = useTranslation();
    const [showRetryDetails, setShowRetryDetails] = useState(false);
    const [showTypewriter, setShowTypewriter] = useState(true);

    // 始终清理 AI 消息的 content
    const rawContent = msg.role === 'ai' && msg.content
        ? cleanMarkdownContent(msg.content)
        : msg.content;

    const [displayedText, setDisplayedText] = useState('');
    const prevContentRef = useRef('');
    
    // 是否需要流式效果：仅对 AI 消息且有内容、非错误时
    const shouldStream = showTypewriter && msg.role === 'ai' && !msg.isError;
    // 判断流是否结束：非 loading 即为结束
    const streamDone = !msg.isLoading;

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

    // 当新消息到达时重置状态
    useEffect(() => {
        prevContentRef.current = '';
        reset('');
    }, [msg.id, reset]);

    // 不流式时，直接显示内容（使用 derived state）
    const finalDisplayedText = shouldStream ? displayedText : (rawContent || '');

    // 打字完成后允许跳过效果
    const handleSkipTyping = () => {
        setShowTypewriter(false);
    };

    // 自定义 Markdown 组件，特别是代码块的语法高亮
    const markdownComponents: Components = {
        code(props) {
            const { children, className, ...rest } = props;
            const match = /language-(\w+)/.exec(className || '');
            const isInline = !match && !className;
            
            if (!isInline && match && match[1].toLowerCase() === 'sql') {
                // SQL 代码块 - 使用语法高亮
                const code = String(children).replace(/\n$/, '');
                const highlightedCode = highlightSQLInMarkdown(code);
                return (
                    <div className="my-3 border border-border rounded-xl overflow-hidden bg-card shadow-sm">
                        <div className="bg-muted/50 px-3 py-2 text-[10px] font-medium text-muted-foreground border-b border-border flex items-center gap-2">
                            <span className="text-blue-500">SQL</span>
                            <span className="opacity-50">{t('sqlBlock.statement')}</span>
                        </div>
                        <pre className="p-3 overflow-x-auto text-xs font-mono leading-relaxed bg-card m-0">
                            <code 
                                dangerouslySetInnerHTML={{ __html: highlightedCode }}
                                className="sql-highlight"
                            />
                        </pre>
                    </div>
                );
            }
            
            if (!isInline) {
                // 其他代码块 - 使用默认样式
                return (
                    <div className="my-3 border border-border rounded-xl overflow-hidden bg-card shadow-sm">
                        <div className="bg-muted/50 px-3 py-2 text-[10px] font-medium text-muted-foreground border-b border-border">
                            {match ? match[1].toUpperCase() : t('sqlBlock.code')}
                        </div>
                        <pre className="p-3 overflow-x-auto text-xs font-mono leading-relaxed bg-card m-0">
                            <code className={className} {...rest}>
                                {children}
                            </code>
                        </pre>
                    </div>
                );
            }
            
            // 行内代码
            return (
                <code className="px-1.5 py-0.5 bg-muted/50 rounded text-xs font-mono text-pink-600 dark:text-pink-400" {...rest}>
                    {children}
                </code>
            );
        }
    };

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
                    {/* === THINKING === */}
                    {(msg.thinking || msg.thinkingStatus) && (
                        <div className="mb-4">
                            <ThinkingState
                                status={msg.thinkingStatus}
content={(msg.thinking || '') + (msg.sqlThought ? '\n\n**技术思考 (SQL Strategy):**\n' + msg.sqlThought : '')}
                                currentStep={msg.status}
                            />
                        </div>
                    )}

                    {msg.role === 'ai' ? (
                        <>
                            {/* === LOADING SKELETON === */}
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

                            {/* === STATUS PILL === */}
                            {msg.isLoading && (msg.content || msg.thinking) && msg.status && !msg.status.includes('Thinking') && (
                                <div className="flex items-center gap-2 text-xs text-blue-600 dark:text-blue-400 mb-3 py-1.5 px-3 bg-blue-500/5 rounded-lg border border-blue-200/30 dark:border-blue-800/30 w-fit">
                                    <div className="w-3.5 h-3.5 rounded-full border-[1.5px] border-blue-400 border-t-blue-600 animate-spin" />
                                    <span className="font-medium">{msg.status}</span>
                                </div>
                            )}

                            {/* === RETRY ERRORS (折叠显示) === */}
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

                            {/* === EXECUTION RESULT === */}
                            {msg.executionResult && (
                                <div className="my-3 px-3 py-2.5 bg-emerald-50/50 dark:bg-emerald-950/20 rounded-lg text-xs flex items-center gap-2.5 border border-emerald-200/50 dark:border-emerald-800/30">
                                    <CheckCircle2 size={14} className="text-emerald-500 flex-shrink-0" />
                                    <span className="text-emerald-700 dark:text-emerald-300 font-medium">{msg.executionResult}</span>
                                </div>
                            )}

                            {/* === MAIN CONTENT (Markdown) === */}
                            {finalDisplayedText && (
                                <div className="prose prose-neutral dark:prose-invert max-w-none prose-headings:font-semibold prose-headings:mt-6 prose-headings:mb-3 prose-p:my-3 prose-p:leading-7 prose-li:my-1 prose-ul:my-3 prose-ol:my-3 prose-table:text-sm prose-th:bg-muted/50 prose-th:px-4 prose-th:py-3 prose-td:px-4 prose-td:py-3 prose-table:border prose-table:rounded-lg prose-table:overflow-hidden prose-img:rounded-lg prose-pre:p-0 prose-pre:bg-transparent">
                                    {/* 打字机效果跳过按钮 */}
                                    {isTyping && (
                                        <button
                                            onClick={handleSkipTyping}
                                            className="mb-3 text-xs text-muted-foreground/60 hover:text-primary transition-colors flex items-center gap-1.5"
                                        >
                                            <SparklesIcon size={12} />
                                            {t('chat.status.skip')} · {Math.round(progress * 100)}%
                                        </button>
                                    )}
                                    <ReactMarkdown 
                                        remarkPlugins={[remarkGfm, remarkMath]}
                                        rehypePlugins={[rehypeKatex]}
                                        components={markdownComponents}
                                    >
                                        {finalDisplayedText}
                                    </ReactMarkdown>
                                </div>
                            )}

                            {/* === CHART === */}
                            {msg.chartOption && (
                                <div className="mt-5">
                                    <div className="h-px bg-gradient-to-r from-transparent via-border to-transparent mb-4" />
                                    <div className="h-80 md:h-96 border border-border rounded-xl bg-card p-4 shadow-sm overflow-hidden">
                                        <ChartRenderer option={msg.chartOption} />
                                    </div>
                                </div>
                            )}

                            {/* === ERROR (Structured Display) === */}
                            {msg.isError && (
                                <div className="mt-4 p-4 rounded-lg border border-red-200 bg-red-50 dark:bg-red-950/10 dark:border-red-900/50 flex flex-col gap-3 animate-in fade-in slide-in-from-bottom-2">
                                    <div className="flex items-center gap-2 text-red-700 dark:text-red-400 font-medium">
                                        <AlertCircle size={18} />
                                        <span>{t('chat.status.failed')}</span>
                                    </div>
                                    
                                    {/* 仅当 content 不是通过降级生成的长篇 Markdown 报告时才在此处显示，避免重复 */}
                                    {msg.content && !msg.content.includes('⚠️ **系统提示**') && (
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

                            {/* === COMPLETION FOOTER === */}
                            {!msg.isLoading && !msg.isError && (
                                <div className="mt-5 flex items-center justify-between text-[11px] text-muted-foreground/50 select-none">
                                    <div className="h-px flex-1 bg-gradient-to-r from-transparent via-border/50 to-transparent" />
                                    <span className="px-3 flex items-center gap-1">
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
