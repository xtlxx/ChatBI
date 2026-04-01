import { useState, useEffect, useRef } from 'react';
import { ChevronDown, Loader2, CheckCircle2, BrainCircuit, AlertCircle, Database, Code as CodeIcon, BarChart3, Zap } from 'lucide-react';
import * as Collapsible from "@radix-ui/react-collapsible";
import { useTranslation } from "react-i18next";
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import 'katex/dist/katex.min.css';

import { useSmoothStream } from '@/hooks/useSmoothStream';

export type ThinkingStatus = 'idle' | 'starting' | 'thinking' | 'completed' | 'error';

interface ThinkingStateProps {
    status?: ThinkingStatus;
    content: string;
    currentStep?: string; // e.g. "开始深度思考...", "正在生成 SQL..."
    elapsedTime?: number;
    timeoutMs?: number;
}

// 可视化进度条步骤
// 注意：标签将在组件内部进行翻译
const PIPELINE_STEPS = [
    { key: 'thinking', icon: BrainCircuit, keywords: ['思考', 'thinking', 'Thinking'] },
    { key: 'sql', icon: CodeIcon, keywords: ['SQL', 'sql', '分析数据', 'Analysis'] },
    { key: 'validate', icon: Zap, keywords: ['校验', 'validate', 'Validating'] },
    { key: 'execute', icon: Database, keywords: ['查询', 'execute', '数据库', 'Query', 'query', 'Fetching'] },
    { key: 'response', icon: BarChart3, keywords: ['整理', 'response', '回答', '生成回', 'Generating'] },
];

function detectCurrentPipelineStep(step?: string): number {
    if (!step) return 0;
    for (let i = PIPELINE_STEPS.length - 1; i >= 0; i--) {
        if (PIPELINE_STEPS[i].keywords.some(kw => step.includes(kw))) return i;
    }
    return 0;
}

export function ThinkingState({ status = 'idle', content, currentStep, elapsedTime, timeoutMs = 600000 }: ThinkingStateProps) {
    const { t } = useTranslation();
    const [isOpen, setIsOpen] = useState(false); // Default collapsed for cleaner UI
    const [displayStatus, setDisplayStatus] = useState<ThinkingStatus>(status);
    const [isTimedOut, setIsTimedOut] = useState(false);
    const [internalTimer, setInternalTimer] = useState(0);
    const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

    // 平滑流状态管理
    const [displayedContent, setDisplayedContent] = useState('');
    const prevContentRef = useRef('');

    const streamDone = status === 'completed' || status === 'error' || status === 'idle';
    
    const { addChunk, reset } = useSmoothStream({
        onUpdate: setDisplayedContent,
        streamDone: streamDone,
        minDelay: 10
    });

    // 将外部传入的 content 与内部平滑流状态同步
    useEffect(() => {
        const newContent = content || '';
        const oldContent = prevContentRef.current;
        
        if (newContent === oldContent) return;

        if (newContent.startsWith(oldContent)) {
            addChunk(newContent.slice(oldContent.length));
        } else {
            reset(newContent);
        }
        prevContentRef.current = newContent;
    }, [content, addChunk, reset]);

    const pipelineIndex = detectCurrentPipelineStep(currentStep);
    const isActive = displayStatus === 'thinking' || displayStatus === 'starting';

    // 内部定时器，当没有提供 elapsedTime 时使用
    useEffect(() => {
        if (isActive && elapsedTime === undefined) {
            timerRef.current = setInterval(() => {
                setInternalTimer(prev => prev + 0.1);
            }, 100);
            return () => { if (timerRef.current) clearInterval(timerRef.current); };
        } else if (!isActive) {
            // 保留最后一次计时，不重置
            if (timerRef.current) clearInterval(timerRef.current);
        }
    }, [isActive, elapsedTime]);

    useEffect(() => {
        if (isTimedOut) setIsTimedOut(false);
        if (status === 'thinking') {
            if (displayStatus === 'idle') {
                setDisplayStatus('starting');
                const timer = setTimeout(() => setDisplayStatus('thinking'), 500);
                return () => clearTimeout(timer);
            } else {
                setDisplayStatus('thinking');
            }
            const timeoutTimer = setTimeout(() => setIsTimedOut(true), timeoutMs);
            return () => clearTimeout(timeoutTimer);
        } else {
            setDisplayStatus(status);
        }
        // 忽略依赖项警告：status 变化时重置超时计时器，timeoutMs 仅在初始化时生效
    }, [status, timeoutMs]);

    const displayTime = elapsedTime ?? internalTimer;

    const splitContent = (text: string) => {
        if (!text) return { business: '', technical: '', hasTechnical: false };
        const separator = "**技术思考 (SQL Strategy):**";
        if (text.includes(separator)) {
            const parts = text.split(separator);
            return { business: parts[0] || '', technical: parts.slice(1).join(separator), hasTechnical: true };
        }
        return { business: text, technical: '', hasTechnical: false };
    };

    // 自动展开当状态 变为 thinking 时触发
    useEffect(() => {
        if (status === 'thinking' && !isOpen) {
            setIsOpen(true);
        }
    }, [status]);

    const { business, technical, hasTechnical } = splitContent(displayedContent);

    return (
        <div className="space-y-3">
            {/* 状态条 + 定时器 */}
            <div className="border rounded-xl overflow-hidden bg-card/50 shadow-sm transition-all duration-300 hover:shadow-md">
                <Collapsible.Root open={isOpen} onOpenChange={setIsOpen}>
                    <Collapsible.Trigger className={`
                        w-full flex items-center justify-between px-4 py-3 text-sm font-medium transition-colors
                        hover:bg-muted/50
                        ${displayStatus === 'error' ? 'bg-red-50/50 text-red-700' : 'bg-transparent text-foreground/80'}
                    `}>
                        <div className="flex items-center gap-2.5">
                            {/* Icon State */}
                            <div className={`
                                flex items-center justify-center w-6 h-6 rounded-md transition-colors
                                ${displayStatus === 'thinking' ? 'bg-blue-100 text-blue-600' : 
                                  displayStatus === 'completed' ? 'bg-green-100 text-green-600' :
                                  displayStatus === 'error' ? 'bg-red-100 text-red-600' : 
                                  'bg-muted text-muted-foreground'}
                            `}>
                                {displayStatus === 'thinking' ? (
                                    <Loader2 size={14} className="animate-spin" />
                                ) : displayStatus === 'completed' ? (
                                    <CheckCircle2 size={14} />
                                ) : displayStatus === 'error' ? (
                                    <AlertCircle size={14} />
                                ) : (
                                    <BrainCircuit size={14} />
                                )}
                            </div>

                            <span className="text-sm font-medium">
                                {displayStatus === 'thinking' 
                                    ? (currentStep || t('chat.thinking.process'))
                                    : displayStatus === 'completed' 
                                        ? t('chat.thinking.done') 
                                        : displayStatus === 'error'
                                            ? t('chat.thinking.error')
                                            : t('chat.thoughts')}
                            </span>
                            
                            {displayStatus === 'thinking' && (
                                <span className="flex gap-0.5 mt-1">
                                    <span className="w-1 h-1 bg-current rounded-full animate-bounce [animation-delay:-0.3s]"></span>
                                    <span className="w-1 h-1 bg-current rounded-full animate-bounce [animation-delay:-0.15s]"></span>
                                    <span className="w-1 h-1 bg-current rounded-full animate-bounce"></span>
                                </span>
                            )}
                        </div>

                        <div className="flex items-center gap-3 text-muted-foreground/60">
                            <span className="font-mono text-xs tabular-nums bg-muted/30 px-1.5 py-0.5 rounded">
                                {displayTime.toFixed(1)}s
                            </span>
                            <ChevronDown 
                                size={16} 
                                className={`transition-transform duration-300 ${isOpen ? 'rotate-180' : ''}`} 
                            />
                        </div>
                    </Collapsible.Trigger>

                    <Collapsible.Content className="data-[state=open]:animate-slideDown data-[state=closed]:animate-slideUp overflow-hidden">
                        <div className="px-4 py-3 bg-muted/10 border-t border-border/40">
                            {/* Pipeline Progress - Integrated inside content */}
                            {isActive && (
                                <div className="mb-4 pb-4 border-b border-border/40">
                                    <div className="flex items-center justify-between gap-1">
                                        {PIPELINE_STEPS.map((step, idx) => {
                                            const StepIcon = step.icon;
                                            const isDone = idx < pipelineIndex;
                                            const isCurrent = idx === pipelineIndex;
                                            
                                            return (
                                                <div key={step.key} className="flex flex-col items-center gap-1.5 flex-1 relative group">
                                                    <div className={`
                                                        w-8 h-8 rounded-full flex items-center justify-center transition-all duration-500 z-10 bg-background border-2
                                                        ${isDone 
                                                            ? 'border-emerald-500 text-emerald-600' 
                                                            : isCurrent 
                                                                ? 'border-blue-500 text-blue-600 scale-110 shadow-[0_0_10px_rgba(59,130,246,0.2)]' 
                                                                : 'border-muted text-muted-foreground/30'}
                                                    `}>
                                                        {isDone ? <CheckCircle2 size={14} /> : <StepIcon size={14} className={isCurrent ? "animate-pulse" : ""} />}
                                                    </div>
                                                    
                                                    {idx < PIPELINE_STEPS.length - 1 && (
                                                        <div className={`
                                                            absolute top-4 left-[50%] w-full h-[2px] -z-0 transition-colors duration-500
                                                            ${idx < pipelineIndex ? 'bg-emerald-500' : 'bg-muted'}
                                                        `} />
                                                    )}
                                                    
                                                    <span className={`
                                                        text-[10px] font-medium transition-colors duration-300 text-center
                                                        ${isCurrent ? 'text-blue-600' : 'text-muted-foreground/60'}
                                                    `}>
                                                        {t(`chat.pipeline.${step.key}`)}
                                                    </span>
                                                </div>
                                            );
                                        })}
                                    </div>
                                </div>
                            )}

                            <div className="prose prose-sm max-w-none text-muted-foreground/90 dark:prose-invert prose-p:leading-relaxed prose-pre:bg-muted/50 prose-pre:border">
                                {content ? (
                                    <>
                                        <ReactMarkdown remarkPlugins={[remarkGfm, remarkMath]} rehypePlugins={[rehypeKatex]}>
                                            {business}
                                        </ReactMarkdown>
                                        
                                        {hasTechnical && technical && (
                                            <div className="mt-4 pl-3 border-l-2 border-blue-500/20">
                                                <div className="flex items-center gap-2 mb-2 text-xs font-semibold text-blue-600/80 uppercase tracking-wider">
                                                    <CodeIcon size={12} />
                                                    Technical Strategy
                                                </div>
                                                <ReactMarkdown remarkPlugins={[remarkGfm, remarkMath]} rehypePlugins={[rehypeKatex]}>
                                                    {technical.trim()}
                                                </ReactMarkdown>
                                            </div>
                                        )}
                                    </>
                                ) : (
                                    <div className="flex items-center gap-2 text-muted-foreground/50 italic py-2">
                                        <Loader2 size={14} className="animate-spin" />
                                        <span>{t('chat.thinking.waiting')}</span>
                                    </div>
                                )}
                            </div>
                        </div>
                    </Collapsible.Content>
                </Collapsible.Root>
            </div>
        </div>
    );
}
