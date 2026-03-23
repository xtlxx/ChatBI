import { useCallback, useEffect, useRef } from 'react';

interface UseSmoothStreamOptions {
    onUpdate: (text: string) => void;
    streamDone: boolean;
    minDelay?: number;
}

export function useSmoothStream({ onUpdate, streamDone, minDelay = 10 }: UseSmoothStreamOptions) {
    const queueRef = useRef<string[]>([]);
    const rafRef = useRef<number | null>(null);
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
    const renderLoopRef = useRef<(timestamp: number) => void>(undefined);

    const renderLoop = useCallback((timestamp: number) => {
        // 1. If queue is empty
        if (queueRef.current.length === 0) {
            if (streamDoneRef.current) {
                // Stream is done and queue is empty -> Stop loop
                rafRef.current = null;
                return;
            }
            // Stream not done -> Keep waiting
            if (renderLoopRef.current) {
                rafRef.current = requestAnimationFrame(renderLoopRef.current);
            }
            return;
        }

        // 2. Time control
        if (timestamp - lastUpdateTimeRef.current < minDelay) {
            if (renderLoopRef.current) {
                rafRef.current = requestAnimationFrame(renderLoopRef.current);
            }
            return;
        }

        // 3. Dynamic speed control
        // Render 1/5 of the queue or 1 char, whichever is larger.
        const count = Math.max(1, Math.floor(queueRef.current.length / 5));
        
        // 4. Extract chars
        const charsToRender = queueRef.current.splice(0, count);
        displayedTextRef.current += charsToRender.join('');
        lastUpdateTimeRef.current = timestamp;

        // 5. Update UI
        onUpdateRef.current(displayedTextRef.current);

        // 6. Continue loop
        if (renderLoopRef.current) {
            rafRef.current = requestAnimationFrame(renderLoopRef.current);
        }
    }, [minDelay]); // Only depends on minDelay which is usually static

    // Update ref whenever renderLoop changes
    useEffect(() => {
        renderLoopRef.current = renderLoop;
    }, [renderLoop]);

    // Reset state
    const reset = useCallback((initialText = '') => {
        if (rafRef.current) {
            cancelAnimationFrame(rafRef.current);
            rafRef.current = null;
        }
        queueRef.current = [];
        displayedTextRef.current = initialText;
        lastUpdateTimeRef.current = 0;
        onUpdateRef.current(initialText);
        
        // Restart loop if needed (though usually reset implies new stream)
        if (!streamDoneRef.current && renderLoopRef.current) {
            rafRef.current = requestAnimationFrame(renderLoopRef.current);
        }
    }, []);

    // Add text chunk
    const addChunk = useCallback((chunk: string) => {
        if (!chunk) return;
        const chars = Array.from(chunk);
        queueRef.current.push(...chars);
        
        // Ensure loop is running
        if (!rafRef.current && renderLoopRef.current) {
             rafRef.current = requestAnimationFrame(renderLoopRef.current);
        }
    }, []);

    // Ensure loop starts when component mounts or stream restarts
    useEffect(() => {
        if (!rafRef.current && !streamDone && renderLoopRef.current) {
            rafRef.current = requestAnimationFrame(renderLoopRef.current);
        }
        return () => {
            if (rafRef.current) {
                cancelAnimationFrame(rafRef.current);
                rafRef.current = null;
            }
        };
    }, [streamDone]);

    return { addChunk, reset };
}
