import { useState, useEffect, useRef, memo } from 'react';
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

// 抽离独立的计时器组件，防止父组件 Markdown 疯狂重绘
const TimerDisplay = memo(({ isActive, initialTime = 0 }: { isActive: boolean, initialTime?: number }) => {
    const [time, setTime] = useState(initialTime);

    useEffect(() => {
        if (!isActive) return;
        const timer = setInterval(() => {
            setTime(prev => prev + 0.1);
        }, 100);
        return () => clearInterval(timer);
    }, [isActive]);

    return <>{time.toFixed(1)}s</>;
});

// 优化1：SVG 图标组件化与 Memo 封装，避免在流式输出时频繁重绘
const StatusIcon = memo(({ status }: { status: ThinkingStatus }) => {
    if (status === 'thinking') return <Loader2 size={14} className="animate-spin transform-gpu will-change-transform" />;
    if (status === 'completed') return <CheckCircle2 size={14} className="transform-gpu" />;
    if (status === 'error') return <AlertCircle size={14} className="transform-gpu" />;
    return <BrainCircuit size={14} className="transform-gpu" />;
});

// 优化2：Pipeline 进度条独立组件化，使用 GPU 加速类
const PipelineDisplay = memo(({ pipelineIndex, isActive, t }: { pipelineIndex: number, isActive: boolean, t: any }) => {
    if (!isActive) return null;
    return (
        <div className="mb-4 pb-4 border-b border-border/40 will-change-transform">
            <div className="flex items-center justify-between gap-1">
                {PIPELINE_STEPS.map((step, idx) => {
                    const StepIcon = step.icon;
                    const isDone = idx < pipelineIndex;
                    const isCurrent = idx === pipelineIndex;
                    
                    return (
                        <div key={step.key} className="flex flex-col items-center gap-1.5 flex-1 relative group">
                            <div className={`
                                w-8 h-8 rounded-full flex items-center justify-center transition-all duration-300 z-10 bg-background border-2 transform-gpu will-change-transform
                                ${isDone 
                                    ? 'border-emerald-500 text-emerald-600' 
                                    : isCurrent 
                                        ? 'border-blue-500 text-blue-600 scale-110 shadow-[0_4px_12px_rgba(59,130,246,0.2)]' 
                                        : 'border-muted text-muted-foreground/30'}
                            `}>
                                {isDone ? <CheckCircle2 size={14} /> : <StepIcon size={14} className={isCurrent ? "animate-pulse transform-gpu" : ""} />}
                            </div>
                            
                            {idx < PIPELINE_STEPS.length - 1 && (
                                <div className={`
                                    absolute top-4 left-[50%] w-full h-[2px] -z-0 transition-colors duration-300 transform-gpu
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
    );
});

// 优化3：Markdown 渲染组件化与 Memo 封装，只在内容变化时重绘
const MarkdownContent = memo(({ content, business, technical, hasTechnical, t }: { content: string, business: string, technical: string, hasTechnical: boolean, t: any }) => {
    if (!content) {
        return (
            <div className="flex items-center gap-2 text-muted-foreground/50 italic py-2">
                <Loader2 size={14} className="animate-spin transform-gpu" />
                <span>{t('chat.thinking.waiting')}</span>
            </div>
        );
    }

    return (
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
    );
});

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
    const [userManuallyToggled, setUserManuallyToggled] = useState(false); // Track if user manually intervened
    const [displayStatus, setDisplayStatus] = useState<ThinkingStatus>(status);
    const [isTimedOut, setIsTimedOut] = useState(false);

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

    const splitContent = (text: string) => {
        if (!text) return { business: '', technical: '', hasTechnical: false };
        const separator = "**技术思考 (SQL Strategy):**";
        if (text.includes(separator)) {
            const parts = text.split(separator);
            return { business: parts[0] || '', technical: parts.slice(1).join(separator), hasTechnical: true };
        }
        return { business: text, technical: '', hasTechnical: false };
    };

    // 自动展开/折叠逻辑
    useEffect(() => {
        // 如果用户手动介入过，就不再自动折叠/展开，尊重用户意愿
        if (userManuallyToggled) return;

        if (status === 'thinking' && !isOpen) {
            setIsOpen(true);
        } else if (status === 'completed' && isOpen) {
            // 当状态变为已完成，且当前是打开状态时，延迟一下自动收起，让用户有个视觉缓冲
            const timer = setTimeout(() => {
                setIsOpen(false);
            }, 800); // 800ms 缓冲时间
            return () => clearTimeout(timer);
        }
    }, [status, isOpen, userManuallyToggled]);

    const handleOpenChange = (open: boolean) => {
        setIsOpen(open);
        setUserManuallyToggled(true); // 记录用户手动操作
    };

    const { business, technical, hasTechnical } = splitContent(displayedContent);

    return (
        <div className="space-y-3">
            {/* 状态条 + 定时器 */}
            <div className="border rounded-xl overflow-hidden bg-card/50 shadow-sm transition-all duration-300 hover:shadow-md">
                <Collapsible.Root open={isOpen} onOpenChange={handleOpenChange}>
                    <Collapsible.Trigger className={`
                        w-full flex items-center justify-between px-4 py-3 text-sm font-medium transition-colors
                        hover:bg-muted/50
                        ${displayStatus === 'error' ? 'bg-red-50/50 text-red-700' : 'bg-transparent text-foreground/80'}
                    `}>
                        <div className="flex items-center gap-2.5">
                            {/* Icon State */}
                            <div className={`
                                flex items-center justify-center w-6 h-6 rounded-md transition-colors duration-300
                                ${displayStatus === 'thinking' ? 'bg-blue-100 text-blue-600' : 
                                  displayStatus === 'completed' ? 'bg-green-100 text-green-600' :
                                  displayStatus === 'error' ? 'bg-red-100 text-red-600' : 
                                  'bg-muted text-muted-foreground'}
                            `}>
                                <StatusIcon status={displayStatus} />
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
                                <span className="flex gap-0.5 mt-1 will-change-transform">
                                    <span className="w-1 h-1 bg-current rounded-full animate-bounce transform-gpu [animation-delay:-0.3s]"></span>
                                    <span className="w-1 h-1 bg-current rounded-full animate-bounce transform-gpu [animation-delay:-0.15s]"></span>
                                    <span className="w-1 h-1 bg-current rounded-full animate-bounce transform-gpu"></span>
                                </span>
                            )}
                        </div>

                        <div className="flex items-center gap-3 text-muted-foreground/60">
                            <span className="font-mono text-xs tabular-nums bg-muted/30 px-1.5 py-0.5 rounded">
                                {elapsedTime !== undefined ? (
                                    `${elapsedTime.toFixed(1)}s`
                                ) : (
                                    <TimerDisplay isActive={isActive} />
                                )}
                            </span>
                            <ChevronDown 
                                size={16} 
                                className={`transition-transform duration-300 ${isOpen ? 'rotate-180' : ''}`} 
                            />
                        </div>
                    </Collapsible.Trigger>

                    <Collapsible.Content className="data-[state=open]:animate-slideDown data-[state=closed]:animate-slideUp overflow-hidden will-change-[height,opacity] transform-gpu">
                        <div className="px-4 py-3 bg-muted/10 border-t border-border/40">
                            {/* Pipeline Progress - Integrated inside content */}
                            <PipelineDisplay pipelineIndex={pipelineIndex} isActive={isActive} t={t} />

                            <div className="prose prose-sm max-w-none text-muted-foreground/90 dark:prose-invert prose-p:leading-relaxed prose-pre:bg-muted/50 prose-pre:border transform-gpu">
                                <MarkdownContent 
                                    content={content} 
                                    business={business} 
                                    technical={technical} 
                                    hasTechnical={hasTechnical} 
                                    t={t} 
                                />
                            </div>
                        </div>
                    </Collapsible.Content>
                </Collapsible.Root>
            </div>
        </div>
    );
}
