import { useState, useEffect, useRef, memo } from 'react';
import { ChevronDown, CheckCircle2, BrainCircuit, AlertCircle, Code as CodeIcon } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
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

// 优化3：Markdown 渲染组件化与 Memo 封装，只在内容变化时重绘
const MarkdownContent = memo(({ content, business, technical, hasTechnical, t }: { content: string, business: string, technical: string, hasTechnical: boolean, t: any }) => {
    if (!content) {
        return (
            <div className="flex items-center gap-2 text-muted-foreground/50 italic py-2">
                <BrainCircuit size={14} className="animate-pulse transform-gpu" />
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

export function ThinkingState({ status = 'idle', content, currentStep, elapsedTime, timeoutMs = 600000 }: ThinkingStateProps) {
    const { t } = useTranslation();
    const [isOpen, setIsOpen] = useState(true);
    const [userManuallyToggled, setUserManuallyToggled] = useState(false);
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

    useEffect(() => {
        const newContent = content || '';
        const oldContent = prevContentRef.current;
        
        if (newContent === oldContent) return;

        if (status === 'completed' || status === 'error' || status === 'idle') {
            reset(newContent);
            prevContentRef.current = newContent;
            return;
        }

        if (newContent.startsWith(oldContent)) {
            addChunk(newContent.slice(oldContent.length));
        } else {
            reset(newContent);
        }
        prevContentRef.current = newContent;
    }, [content, status, addChunk, reset]);

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

    useEffect(() => {
        if (userManuallyToggled) return;

        if (status === 'thinking' && !isOpen) {
            setIsOpen(true);
        } else if (status === 'completed' && isOpen) {
            const timer = setTimeout(() => {
                setIsOpen(false);
            }, 800);
            return () => clearTimeout(timer);
        }
    }, [status, isOpen, userManuallyToggled]);

    const handleOpenChange = () => {
        setIsOpen(!isOpen);
        setUserManuallyToggled(true);
    };

    const { business, technical, hasTechnical } = splitContent(displayedContent);

    return ( 
        <div className="relative overflow-hidden rounded-2xl border border-border/50 bg-gradient-to-b from-muted/30 to-background shadow-sm"> 
            {/* 顶部状态：呼吸感的光晕 */} 
            <div className="flex items-center justify-between px-4 py-3"> 
                <div className="flex items-center gap-3"> 
                    <div className="relative"> 
                        {status === 'thinking' && ( 
                            <div className="absolute inset-0 bg-blue-500/30 rounded-full animate-pulse-glow" /> 
                        )} 
                        <div className={`relative z-10 w-8 h-8 rounded-full flex items-center justify-center bg-background border shadow-sm`}> 
                            {status === 'thinking' ? ( 
                                <motion.div 
                                    animate={{ rotate: 360 }} 
                                    transition={{ duration: 4, repeat: Infinity, ease: "linear" }} 
                                > 
                                    <BrainCircuit size={16} className="text-blue-500" /> 
                                </motion.div> 
                            ) : status === 'error' ? (
                                <AlertCircle size={16} className="text-red-500" />
                            ) : ( 
                                <CheckCircle2 size={16} className="text-emerald-500" /> 
                            )} 
                        </div> 
                    </div> 
                    <div> 
                        <div className="text-sm font-semibold tracking-tight"> 
                            {status === 'thinking' ? (currentStep || t('chat.thinking.process')) : status === 'error' ? t('chat.thinking.error') : t('chat.thinking.done')} 
                        </div> 
                        <div className="text-[10px] text-muted-foreground uppercase tracking-widest opacity-60 flex items-center gap-2"> 
                            <span>Neural Engine Processing</span>
                            {status === 'thinking' && elapsedTime !== undefined ? (
                                <span className="font-mono bg-muted/30 px-1 py-0.5 rounded">{elapsedTime.toFixed(1)}s</span>
                            ) : status === 'thinking' ? (
                                <span className="font-mono bg-muted/30 px-1 py-0.5 rounded"><TimerDisplay isActive={true} /></span>
                            ) : null}
                        </div> 
                    </div> 
                </div> 
                <button onClick={handleOpenChange} className="text-muted-foreground hover:text-foreground"> 
                    <ChevronDown className={`transition-transform duration-300 ${isOpen ? 'rotate-180' : ''}`} size={16} /> 
                </button> 
            </div> 

            {/* 思考内容：使用折叠动画 */} 
            <AnimatePresence> 
                {isOpen && ( 
                    <motion.div 
                        initial={{ height: 0, opacity: 0 }} 
                        animate={{ height: 'auto', opacity: 1 }} 
                        exit={{ height: 0, opacity: 0 }} 
                        className="px-4 pb-4 overflow-hidden" 
                    > 
                        <div className="pl-11 pr-4 py-2 border-l border-blue-500/10 ml-4 space-y-4"> 
                            <div className="prose prose-sm max-w-none dark:prose-invert opacity-80 italic leading-relaxed prose-p:leading-relaxed prose-pre:bg-muted/50 prose-pre:border transform-gpu"> 
                                <MarkdownContent 
                                    content={displayedContent} 
                                    business={business} 
                                    technical={technical} 
                                    hasTechnical={hasTechnical} 
                                    t={t} 
                                /> 
                            </div> 
                        </div> 
                    </motion.div> 
                )} 
            </AnimatePresence> 
        </div> 
    ); 
}
