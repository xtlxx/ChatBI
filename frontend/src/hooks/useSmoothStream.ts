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

    // Sync refs with props
    useEffect(() => {
        streamDoneRef.current = streamDone;
    }, [streamDone]);

    useEffect(() => {
        onUpdateRef.current = onUpdate;
    }, [onUpdate]);

    // Main loop function - stable across renders
    const renderLoopRef = useRef<((deadline?: IdleDeadline) => void) | undefined>(undefined);

    const renderLoop = useCallback((deadline?: IdleDeadline) => {
        const now = performance.now();
        
        // 1. If queue is empty
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

        // 2. Time control or Idle time check
        if (now - lastUpdateTimeRef.current < minDelay || (deadline && deadline.timeRemaining() < 1)) {
            if (renderLoopRef.current) {
                // @ts-ignore
                updateTaskRef.current = (window.requestIdleCallback || window.requestAnimationFrame)(renderLoopRef.current);
            }
            return;
        }

        // 3. Dynamic speed control
        const count = Math.max(15, Math.floor(queueRef.current.length / 3));
        
        // 4. Extract chars
        const charsToRender = queueRef.current.splice(0, count);
        displayedTextRef.current += charsToRender.join('');
        lastUpdateTimeRef.current = now;

        // 5. Update UI
        onUpdateRef.current(displayedTextRef.current);

        // 6. Continue loop
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

    // Ensure loop starts when component mounts or stream restarts
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
