import { useState, useCallback, useRef } from 'react';
import { useAppStore } from '@/store/useAppStore';
import { chatApi } from '@/lib/api-services';
import { Message, SSEChunk } from '@/types';

export const useChatStream = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const abortControllerRef = useRef<AbortController | null>(null);
  
  const { 
    addMessage, 
    updateMessage, 
    activeConnectionId, 
    activeLlmConfigId,
    user 
  } = useAppStore();

  const sendMessage = useCallback(async (query: string) => {
    // Validation
    if (!query.trim()) {
      setError('Please enter a query');
      return;
    }

    if (!activeConnectionId) {
      setError('Please select a database connection');
      return;
    }

    if (!activeLlmConfigId) {
      setError('Please select an LLM configuration');
      return;
    }

    if (!user) {
      setError('Please login to send messages');
      return;
    }

    setIsLoading(true);
    setError(null);

    // Cancel any existing request
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
    }

    // Create new abort controller
    abortControllerRef.current = new AbortController();

    try {
      // Add user message
      const userMessage: Message = {
        id: `user-${Date.now()}`,
        role: 'user',
        content: query,
      };
      addMessage(userMessage);

      // Add placeholder AI message for streaming
      const aiMessageId = `ai-${Date.now()}`;
      const aiMessage: Message = {
        id: aiMessageId,
        role: 'ai',
        content: '',
        metadata: {
          thoughts: [],
          sql_query: '',
          chart_data: null,
        },
      };
      addMessage(aiMessage);

      // Start streaming
      const stream = await chatApi.sendMessage({
        query,
        connection_id: activeConnectionId,
        llm_config_id: activeLlmConfigId,
      });

      const reader = stream.getReader();
      const decoder = new TextDecoder();
      let buffer = '';

      while (true) {
        const { done, value } = await reader.read();
        
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || ''; // Keep incomplete line in buffer

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            try {
              const data = JSON.parse(line.slice(6));
              const chunk: SSEChunk = data;

              switch (chunk.type) {
                case 'thought':
                  updateMessage(aiMessageId, {
                    metadata: {
                      thoughts: [...(aiMessage.metadata?.thoughts || []), chunk.content],
                    },
                  });
                  break;

                case 'observation':
                  updateMessage(aiMessageId, {
                    content: aiMessage.content + `\n\n**Observation:**\n${chunk.content}`,
                  });
                  break;

                case 'final_output':
                  const { sql, summary, chartOption } = chunk.content;
                  let finalContent = '';

                  if (sql) {
                    finalContent += `\n\n**SQL Query:**\n\`\`\`sql\n${sql}\n\`\`\``;
                  }

                  if (summary) {
                    finalContent += `\n\n**Analysis:**\n${summary}`;
                  }

                  updateMessage(aiMessageId, {
                    content: finalContent,
                    metadata: {
                      thoughts: aiMessage.metadata?.thoughts || [],
                      sql_query: sql,
                      chart_data: chartOption,
                    },
                  });
                  break;

                case 'error':
                  updateMessage(aiMessageId, {
                    content: `**Error:** ${chunk.content}`,
                    isError: true,
                  });
                  setError(chunk.content);
                  break;

                case 'end':
                  // Stream completed
                  break;
              }
            } catch (parseError) {
              console.error('Error parsing SSE data:', parseError);
            }
          }
        }
      }
    } catch (err) {
      if (err instanceof Error && err.name === 'AbortError') {
        console.log('Request was aborted');
      } else {
        const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred';
        setError(errorMessage);
        
        // Update the last AI message with error
        const messages = useAppStore.getState().messages;
        const lastAiMessage = messages.filter(m => m.role === 'ai').pop();
        if (lastAiMessage) {
          updateMessage(lastAiMessage.id, {
            content: `**Error:** ${errorMessage}`,
            isError: true,
          });
        }
      }
    } finally {
      setIsLoading(false);
      abortControllerRef.current = null;
    }
  }, [activeConnectionId, activeLlmConfigId, user, addMessage, updateMessage]);

  const stopMessage = useCallback(() => {
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
      setIsLoading(false);
    }
  }, []);

  return {
    sendMessage,
    stopMessage,
    isLoading,
    error,
  };
};
