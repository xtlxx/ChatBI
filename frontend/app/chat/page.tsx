'use client';

import React, { useState, useRef, useEffect } from 'react';
import { Send, Square, Database, Bot, Menu, X, Settings } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useChatStream } from '@/hooks/useChatStream';
import { useAppStore, useConnections, useLlmConfigs, useMessages, useActiveConnection, useActiveLlmConfig } from '@/store/useAppStore';
import { dbConnectionApi, llmConfigApi } from '@/lib/api-services';
import { Message } from '@/types';
import ReactMarkdown from 'react-markdown';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { oneDark } from 'react-syntax-highlighter/dist/esm/styles/prism';
import dynamic from 'next/dynamic';

// Dynamically import ECharts to avoid SSR issues
const ReactECharts = dynamic(() => import('echarts-for-react'), { ssr: false });

const ChatPage: React.FC = () => {
  const [input, setInput] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const { sendMessage, stopMessage, isLoading, error } = useChatStream();
  const messages = useMessages();
  const connections = useConnections();
  const llmConfigs = useLlmConfigs();
  const activeConnection = useActiveConnection();
  const activeLlmConfig = useActiveLlmConfig();

  const {
    sidebarOpen,
    setSidebarOpen,
    setActiveConnectionId,
    setActiveLlmConfigId,
    setConnections,
    setLlmConfigs,
    clearMessages
  } = useAppStore();

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // Load initial data
  useEffect(() => {
    const loadData = async () => {
      try {
        const [conns, configs] = await Promise.all([
          dbConnectionApi.getAll(),
          llmConfigApi.getAll()
        ]);

        setConnections(conns);
        setLlmConfigs(configs);

        // Auto-select first item if not selected
        if (conns.length > 0 && !activeConnection) {
          setActiveConnectionId(conns[0].id);
        }
        if (configs.length > 0 && !activeLlmConfig) {
          setActiveLlmConfigId(configs[0].id);
        }
      } catch (error) {
        console.error('Failed to load initial data:', error);
      }
    };

    loadData();
  }, []); // Only run once on mount

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const currentInput = input;
    setInput('');
    await sendMessage(currentInput);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e as any);
    }
  };

  const renderMessage = (message: Message) => {
    const isUser = message.role === 'user';

    return (
      <div
        key={message.id}
        className={`flex ${isUser ? 'justify-end' : 'justify-start'} mb-4`}
      >
        <div
          className={`max-w-3xl ${isUser
            ? 'bg-primary text-primary-foreground'
            : 'bg-muted'
            } rounded-lg p-4`}
        >
          <div className="flex items-center gap-2 mb-2">
            {isUser ? (
              <div className="w-6 h-6 bg-primary-foreground rounded-full flex items-center justify-center">
                <span className="text-xs text-primary font-semibold">U</span>
              </div>
            ) : (
              <div className="w-6 h-6 bg-background rounded-full flex items-center justify-center">
                <Bot className="w-4 h-4" />
              </div>
            )}
            <span className="text-sm font-medium">
              {isUser ? '用户' : 'AI 助手'}
            </span>
          </div>

          {/* Render thoughts for AI messages */}
          {!isUser && message.metadata?.thoughts && message.metadata.thoughts.length > 0 && (
            <details className="mb-3">
              <summary className="cursor-pointer text-sm font-medium mb-2">
                🤔 思考过程...
              </summary>
              <div className="text-sm opacity-80 space-y-1">
                {message.metadata.thoughts.map((thought, index) => (
                  <div key={index}>{thought}</div>
                ))}
              </div>
            </details>
          )}

          {/* Render message content */}
          <div className="prose prose-sm max-w-none dark:prose-invert">
            <ReactMarkdown
              components={{
                code({ className, children, ...props }: any) {
                  const match = /language-(\w+)/.exec(className || '');
                  return match ? (
                    <SyntaxHighlighter
                      style={oneDark as any}
                      language={match[1]}
                      PreTag="div"
                      {...props}
                    >
                      {String(children).replace(/\n$/, '')}
                    </SyntaxHighlighter>
                  ) : (
                    <code className={className} {...props}>
                      {children}
                    </code>
                  );
                },
              }}
            >
              {message.content}
            </ReactMarkdown>
          </div>

          {/* Render chart if available */}
          {!isUser && message.metadata?.chart_data && (
            <div className="mt-4">
              <ReactECharts
                option={message.metadata.chart_data}
                style={{ height: '400px', width: '100%' }}
                notMerge={true}
                lazyUpdate={true}
              />
            </div>
          )}

          {/* Error indicator */}
          {message.isError && (
            <div className="mt-2 text-xs text-destructive">
              ⚠️ 此消息包含错误
            </div>
          )}
        </div>
      </div>
    );
  };

  return (
    <div className="flex h-screen bg-background">
      {/* Sidebar */}
      <div className={`${sidebarOpen ? 'w-64' : 'w-0'} transition-all duration-300 bg-card border-r overflow-hidden`}>
        <div className="p-4 h-full flex flex-col">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold">历史会话</h2>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setSidebarOpen(false)}
            >
              <X className="h-4 w-4" />
            </Button>
          </div>

          <div className="flex-1 overflow-y-auto">
            <div className="space-y-2">
              <Button
                variant="ghost"
                className="w-full justify-start"
                onClick={() => clearMessages()}
              >
                新对话
              </Button>
              {/* Chat sessions would be rendered here */}
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col">
        {/* Header */}
        <div className="bg-card border-b p-4">
          <div className="flex items-center gap-4">
            {/* Menu Toggle */}
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setSidebarOpen(!sidebarOpen)}
            >
              <Menu className="h-4 w-4" />
            </Button>

            {/* Database Connection Selector */}
            <div className="flex items-center gap-2 flex-1">
              <Database className="h-4 w-4" />
              <Select
                value={activeConnection?.id?.toString() || ''}
                onValueChange={(value) => setActiveConnectionId(Number(value))}
              >
                <SelectTrigger className="w-64">
                  <SelectValue placeholder="选择数据库连接">
                    {activeConnection ? activeConnection.name : '选择数据库'}
                  </SelectValue>
                </SelectTrigger>
                <SelectContent>
                  {connections.map((connection) => (
                    <SelectItem key={connection.id} value={connection.id.toString()}>
                      {connection.name} ({connection.type})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* LLM Configuration Selector */}
            <div className="flex items-center gap-2 flex-1">
              <Bot className="h-4 w-4" />
              <Select
                value={activeLlmConfig?.id?.toString() || ''}
                onValueChange={(value) => setActiveLlmConfigId(Number(value))}
              >
                <SelectTrigger className="w-64">
                  <SelectValue placeholder="选择 LLM 模型">
                    {activeLlmConfig ? `${activeLlmConfig.provider} - ${activeLlmConfig.model_name}` : '选择 LLM'}
                  </SelectValue>
                </SelectTrigger>
                <SelectContent>
                  {llmConfigs.map((config) => (
                    <SelectItem key={config.id} value={config.id.toString()}>
                      {config.provider} - {config.model_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Settings Button */}
            <Button
              variant="ghost"
              size="icon"
              onClick={() => window.location.href = '/settings'}
              title="设置"
            >
              <Settings className="h-4 w-4" />
            </Button>
          </div>

          {/* Configuration warnings */}
          {(!activeConnection || !activeLlmConfig) && (
            <div className="mt-2 text-sm text-destructive">
              {!activeConnection && '⚠️ 请选择一个数据库连接。 '}
              {!activeLlmConfig && '⚠️ 请选择一个 LLM 配置。'}
              {(!activeConnection || !activeLlmConfig) && (
                <Button
                  variant="link"
                  className="p-0 h-auto text-destructive underline"
                  onClick={() => window.location.href = '/settings'}
                >
                  前往设置
                </Button>
              )}
            </div>
          )}
        </div>

        {/* Messages Area */}
        <div className="flex-1 overflow-y-auto p-4">
          {messages.length === 0 ? (
            <div className="flex items-center justify-center h-full text-muted-foreground">
              <div className="text-center">
                <h3 className="text-lg font-medium mb-2">欢迎使用 AI SQL 分析助手</h3>
                <p>使用自然语言询问您的数据问题</p>
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              {messages.map(renderMessage)}
              <div ref={messagesEndRef} />
            </div>
          )}
        </div>

        {/* Input Area */}
        <div className="border-t p-4">
          {error && (
            <div className="mb-2 text-sm text-destructive">
              ⚠️ {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="flex gap-2">
            <Textarea
              ref={textareaRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="询问您的数据... (例如: '显示按收入排名前10的客户')"
              className="flex-1 min-h-[60px] max-h-[200px] resize-none"
              disabled={isLoading}
            />

            <div className="flex gap-2">
              {isLoading ? (
                <Button type="button" variant="destructive" onClick={stopMessage}>
                  <Square className="h-4 w-4" />
                </Button>
              ) : (
                <Button type="submit" disabled={!input.trim()}>
                  <Send className="h-4 w-4" />
                </Button>
              )}
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default ChatPage;
