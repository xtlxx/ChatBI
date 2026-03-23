import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import { chatService } from './chat-service';
import type { QueryRequest, StreamEvent } from '@/types/api';

// Mock types
type MockReader = {
  read: () => Promise<{ done: boolean; value?: Uint8Array }>;
};

import { useAuthStore } from '@/store/auth-store';

describe('ChatService Stream Handling', () => {
  let originalFetch: typeof globalThis.fetch;

  beforeAll(() => {
    originalFetch = globalThis.fetch;
    // Mock authenticated state
    useAuthStore.setState({ token: 'mock-token' });
  });

  afterAll(() => {
    globalThis.fetch = originalFetch;
    useAuthStore.setState({ token: null });
  });

  it('should process incomplete buffer when stream ends without double newline', async () => {
    // Setup mock stream data
    // The last chunk "final_event" does NOT end with \n\n
    const chunks = [
      'data: {"type": "start", "content": "Start"}\n\n',
      'data: {"type": "thinking", "content": "Thinking..."}\n\n',
      'data: {"type": "final_answer", "content": "Done"}' 
    ];

    let chunkIndex = 0;
    const encoder = new TextEncoder();

    const mockReader: MockReader = {
      read: async () => {
        if (chunkIndex >= chunks.length) {
          return { done: true };
        }
        const value = encoder.encode(chunks[chunkIndex++]);
        return { done: false, value };
      }
    };

    // Mock fetch
    const mockResponse = {
      ok: true,
      body: {
        getReader: () => mockReader
      }
    };
    globalThis.fetch = vi.fn().mockResolvedValue(mockResponse as unknown as Response);

    // Track events
    const receivedEvents: StreamEvent[] = [];
    const onChunk = (event: StreamEvent) => receivedEvents.push(event);
    const onError = vi.fn();
    const onComplete = vi.fn();

    // Execute
    const req: QueryRequest = { query: 'test', session_id: '123' };
    await chatService.sendMessageStream(
      req,
      onChunk,
      onError,
      onComplete
    );

    // Verify
    expect(receivedEvents.length).toBe(3);
    expect(receivedEvents[0].type).toBe('start');
    expect(receivedEvents[1].type).toBe('thinking');
    
    // This is the critical check: the last event MUST be processed despite missing \n\n
    expect(receivedEvents[2].type).toBe('final_answer');
    expect(receivedEvents[2].content).toBe('Done');
    
    expect(onComplete).toHaveBeenCalled();
    expect(onError).not.toHaveBeenCalled();
  });
});
