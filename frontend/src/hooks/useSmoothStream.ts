import { useCallback, useEffect, useRef } from 'react';

interface UseSmoothStreamOptions {
    onUpdate: (text: string) => void;
    streamDone: boolean;
    minDelay?: number;
}

export function useSmoothStream({ onUpdate, streamDone, minDelay = 10 }: UseSmoothStreamOptions) {
    const queueRef = useRef<string[]>([]);
    const updateTaskRef = useRef<number | null>(null);
    const lastUpdateTimeRef = useRef<number>(0);
    const displayedTextRef = useRef<string>('');
    const streamDoneRef = useRef(streamDone);
    const onUpdateRef = useRef(onUpdate);

    // 将 ref 与 props 同步
    useEffect(() => {
        streamDoneRef.current = streamDone;
    }, [streamDone]);

    useEffect(() => {
        onUpdateRef.current = onUpdate;
    }, [onUpdate]);

    // loop 主循环函数 - 跨渲染保持稳定
    const renderLoopRef = useRef<((deadline?: IdleDeadline) => void) | undefined>(undefined);

    const renderLoop = useCallback((deadline?: IdleDeadline) => {
        const now = performance.now();
        
        // 1. 如果队列为空
        if (queueRef.current.length === 0) {
            if (streamDoneRef.current) {
                updateTaskRef.current = null;
                return;
            }
            if (renderLoopRef.current) {
                // @ts-ignore
                updateTaskRef.current = (window.requestIdleCallback || window.requestAnimationFrame)(renderLoopRef.current);
            }
            return;
        }

        // 2. 时间控制或空闲时间检查，确保最小延迟
        if (now - lastUpdateTimeRef.current < minDelay || (deadline && deadline.timeRemaining() < 1)) {
            if (renderLoopRef.current) {
                // @ts-ignore
                updateTaskRef.current = (window.requestIdleCallback || window.requestAnimationFrame)(renderLoopRef.current);
            }
            return;
        }

        // 3. 动态速度控制
        // 限制每次最大吐字数量，避免大块文字突然糊在屏幕上
        // 改为恒定且较小的消费量，加上上限阈值
        const count = Math.max(1, Math.min(5, Math.floor(queueRef.current.length / 5)));
        
        // 4. 提取字符
        const charsToRender = queueRef.current.splice(0, count);
        displayedTextRef.current += charsToRender.join('');
        lastUpdateTimeRef.current = now;

        // 5. 更新 UI
        onUpdateRef.current(displayedTextRef.current);

        // 6. 继续循环，确保流继续运行 
        if (renderLoopRef.current) {
            // @ts-ignore
            updateTaskRef.current = (window.requestIdleCallback || window.requestAnimationFrame)(renderLoopRef.current);
        }
    }, [minDelay]);

    useEffect(() => {
        renderLoopRef.current = renderLoop;
    }, [renderLoop]);

    const reset = useCallback((initialText = '') => {
        if (updateTaskRef.current !== null) {
            // @ts-ignore
            (window.cancelIdleCallback || window.cancelAnimationFrame)(updateTaskRef.current);
            updateTaskRef.current = null;
        }
        queueRef.current = [];
        displayedTextRef.current = initialText;
        lastUpdateTimeRef.current = 0;
        onUpdateRef.current(initialText);
        
        if (!streamDoneRef.current && renderLoopRef.current) {
            // @ts-ignore
            updateTaskRef.current = (window.requestIdleCallback || window.requestAnimationFrame)(renderLoopRef.current);
        }
    }, []);

    const addChunk = useCallback((chunk: string) => {
        if (!chunk) return;
        const chars = Array.from(chunk);
        queueRef.current.push(...chars);
        
        if (updateTaskRef.current === null && renderLoopRef.current) {
            // @ts-ignore
            updateTaskRef.current = (window.requestIdleCallback || window.requestAnimationFrame)(renderLoopRef.current);
        }
    }, []);

    // 确保循环在组件挂载或流重启时启动
    useEffect(() => {
        if (!updateTaskRef.current && !streamDone && renderLoopRef.current) {
            // @ts-ignore
            updateTaskRef.current = (window.requestIdleCallback || window.requestAnimationFrame)(renderLoopRef.current);
        }
        return () => {
            if (updateTaskRef.current !== null) {
                // @ts-ignore
                (window.cancelIdleCallback || window.cancelAnimationFrame)(updateTaskRef.current);
                updateTaskRef.current = null;
            }
        };
    }, [streamDone]);

    return { addChunk, reset };
}
