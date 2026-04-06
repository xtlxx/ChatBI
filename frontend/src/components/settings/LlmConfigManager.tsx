import { useState, useEffect, useRef, useCallback } from 'react';
import { llmService } from '@/services/llm-service';
import type { LlmConfig, LlmConfigCreate, LlmProvider, LlmTestResponse } from '@/types/api';
import { Modal } from '@/components/ui/Modal';
import { Trash2, Edit2, Cpu, Loader2, Play, AlertCircle, CheckCircle2, RotateCcw, X, Eye, EyeOff } from 'lucide-react';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';

export function LlmConfigManager({ configs = [], selectedId, onSelect, onUpdate }: { configs?: LlmConfig[]; selectedId?: number | null; onSelect?: (id: number | null) => void; onUpdate?: () => void }) {
  const { t } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);
  const [modalConfigs, setModalConfigs] = useState<LlmConfig[]>([]);
  const [loading, setLoading] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [testing, setTesting] = useState(false);
  
  const [testResult, setTestResult] = useState<LlmTestResponse | null>(null);
  const [retryCount, setRetryCount] = useState(0);
  const [lockTime, setLockTime] = useState(0);
  const [showApiKey, setShowApiKey] = useState(false);
  const resultTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const apiKeyInputRef = useRef<HTMLInputElement>(null);

  // Countdown timer for lock
  useEffect(() => {
      if (lockTime > 0) {
          const timer = setTimeout(() => setLockTime(t => t - 1), 1000);
          return () => clearTimeout(timer);
      } else if (lockTime === 0 && retryCount >= 3) {
           setRetryCount(0); // Reset retry count after lock expires
      }
  }, [lockTime, retryCount]);

  // Clear result timer on unmount
  useEffect(() => {
      const timer = resultTimerRef.current;
      return () => {
          if (timer) clearTimeout(timer);
      };
  }, []);
  
  // Form State
  const [formData, setFormData] = useState<LlmConfigCreate>({
    provider: 'openai',
    model_name: 'gpt-3.5-turbo',
    base_url: '',
    temperature: 0.7,
    api_key: ''
  });

  const fetchConfigs = useCallback(async () => {
    try {
      setLoading(true);
      const data = await llmService.getAll();
      setModalConfigs(data);
    } catch {
      toast.error(t('settings.llm.loadFailed'));
    } finally {
      setLoading(false);
    }
  }, [t]);

  useEffect(() => {
    if (isOpen) {
      fetchConfigs();
    }
  }, [isOpen, fetchConfigs]);

  const handleEdit = async (id: number) => {
    try {
      setLoading(true);
      const data = await llmService.getForEdit(id);
      setFormData({
        provider: data.provider,
        model_name: data.model_name,
        base_url: data.base_url || '',
        temperature: data.temperature,
        api_key: data.api_key
      });
      setEditingId(id);
    } catch {
      toast.error(t('settings.llm.loadFailed'));
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm(t('settings.llm.confirmDelete'))) return;
    try {
      await llmService.delete(id);
      toast.success(t('settings.llm.deleteSuccess'));
      fetchConfigs();
      onUpdate?.();
    } catch {
      toast.error(t('common.error'));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setShowApiKey(false); // Force hide password on submit for security
    try {
      setLoading(true);
      if (editingId) {
        await llmService.update(editingId, formData);
        toast.success(t('settings.llm.updateSuccess'));
      } else {
        await llmService.create(formData);
        toast.success(t('settings.llm.createSuccess'));
      }
      resetForm();
      fetchConfigs();
      onUpdate?.();
    } catch {
      toast.error(editingId ? t('common.error') : t('common.error'));
    } finally {
      setLoading(false);
    }
  };

  const handleTestConnection = async () => {
    if (!formData.api_key) {
      toast.error(t('settings.llm.apiKeyRequired'));
      return;
    }
    try {
      setTesting(true);
      const res = await llmService.testConnection(formData);
      setTestResult(res);
      
      if (res.success) {
        toast.success(res.message || t('settings.llm.testSuccess'));
      } else {
        toast.error(res.message || t('settings.llm.testFailed'));
      }
    } catch {
      toast.error(t('settings.llm.testFailed'));
    } finally {
      setTesting(false);
    }
  };

  const handleToggleApiKey = (e: React.MouseEvent | React.KeyboardEvent) => {
    // Prevent default scrolling for space key
    if (e.type === 'keydown' && (e as React.KeyboardEvent).key === ' ') {
      e.preventDefault();
    }

    const input = apiKeyInputRef.current;
    if (input) {
      // Record cursor position
      const start = input.selectionStart;
      const end = input.selectionEnd;

      // Toggle state
      setShowApiKey(!showApiKey);

      // Restore cursor position after render
      requestAnimationFrame(() => {
        if (input) {
            input.setSelectionRange(start, end);
            input.focus();
        }
      });
    } else {
        setShowApiKey(!showApiKey);
    }
  };

  const resetForm = () => {
    setEditingId(null);
    setFormData({
      provider: 'openai',
      model_name: 'gpt-3.5-turbo',
      base_url: '',
      temperature: 0.7,
      api_key: ''
    });
    setShowApiKey(false);
    setTestResult(null);
    setRetryCount(0);
    setLockTime(0);
  };

  return (
    <div className="space-y-2">
        <div className="flex items-center justify-between">
            <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider flex items-center gap-1">
                <Cpu size={12} />
                {t('settings.model')}
            </label>
            <button 
                onClick={() => setIsOpen(true)}
                className="text-xs text-blue-600 hover:text-blue-800 font-medium"
            >
                {t('settings.manage')}
            </button>
        </div>

        {onSelect && (
             <div className="flex items-center gap-2">
                 <div className="flex-1 p-1 bg-muted/50 rounded-xl border border-border">
                    <select 
                        className="w-full text-sm bg-transparent border-none focus:ring-0 p-2 outline-none dark:bg-zinc-900 dark:text-gray-200"
                        value={selectedId || ''}
                        onChange={(e) => onSelect(e.target.value ? Number(e.target.value) : null)}
                    >
                        <option value="">{t('settings.selectModel') || "Select Model..."}</option>
                        {configs.map(c => (
                            <option key={c.id} value={c.id}>{c.model_name} ({c.provider})</option>
                        ))}
                    </select>
                 </div>
                 <button
                    onClick={() => {
                        if (selectedId) {
                            setIsOpen(true);
                            handleEdit(selectedId);
                        }
                    }}
                    disabled={!selectedId}
                    className="p-2 text-muted-foreground hover:text-foreground hover:bg-muted rounded-md transition-colors disabled:opacity-50"
                    title={t('settings.llm.edit') || "Edit"}
                 >
                    <Edit2 size={16} />
                 </button>
             </div>
        )}

      <Modal 
        isOpen={isOpen} 
        onClose={() => setIsOpen(false)} 
        title={t('settings.llm.title')}
        description={t('settings.llm.description')}
      >
        <div className="space-y-6">
            {/* List */}
            <div className="space-y-2 max-h-40 overflow-y-auto border border-border rounded-md p-2 bg-muted/30 dark:bg-zinc-900/30">
                {loading && modalConfigs.length === 0 ? (
                    <div className="flex justify-center p-4"><Loader2 className="animate-spin text-muted-foreground" /></div>
                ) : modalConfigs.length === 0 ? (
                    <div className="text-center text-sm text-muted-foreground py-4">{t('settings.llm.noConfigurations')}</div>
                ) : (
                    modalConfigs.map(cfg => (
                        <div key={cfg.id} className="flex items-center justify-between p-2 bg-background border border-border rounded-md shadow-sm">
                            <div className="flex items-center gap-2 overflow-hidden">
                                <Cpu size={16} className="text-gray-400 flex-shrink-0" />
                                <div className="truncate">
                                    <div className="text-sm font-medium text-gray-900 truncate">{cfg.provider} / {cfg.model_name}</div>
                                    <div className="text-xs text-gray-500 truncate">{t('settings.llm.temperature')}: {cfg.temperature}</div>
                                </div>
                            </div>
                            <div className="flex items-center gap-1 flex-shrink-0">
                                <button onClick={() => handleEdit(cfg.id)} className="p-1.5 text-gray-500 hover:bg-gray-100 rounded">
                                    <Edit2 size={14} />
                                </button>
                                <button onClick={() => handleDelete(cfg.id)} className="p-1.5 text-red-500 hover:bg-red-50 rounded">
                                    <Trash2 size={14} />
                                </button>
                            </div>
                        </div>
                    ))
                )}
            </div>

            <div className="h-px bg-gray-200"></div>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-3">
                <h3 className="text-sm font-medium text-gray-900">{editingId ? t('settings.llm.edit') : t('settings.llm.add')}</h3>
                
                <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-1">
                        <label className="text-xs font-medium text-gray-700">{t('settings.llm.provider')}</label>
                        <select 
                            className="w-full text-sm border rounded px-2 py-1.5 focus:ring-2 focus:ring-blue-500 outline-none bg-white"
                            value={formData.provider}
                            onChange={e => setFormData({...formData, provider: e.target.value as LlmProvider})}
                        >
                            <option value="openai">OpenAI</option>
                            <option value="anthropic">Anthropic</option>
                            <option value="gemini">Gemini</option>
                            <option value="deepseek">DeepSeek</option>
                            <option value="qwen">Qwen (Tongyi Qianwen)</option>
                            <option value="moonshot">Moonshot (Kimi)</option>
                            <option value="ollama">Ollama</option>
                            <option value="other">Other (OpenAI Compatible)</option>
                        </select>
                    </div>
                    <div className="space-y-1">
                        <label className="text-xs font-medium text-gray-700">{t('settings.llm.modelName')}</label>
                        <input 
                            required
                            className="w-full text-sm border rounded px-2 py-1.5 focus:ring-2 focus:ring-blue-500 outline-none"
                            value={formData.model_name}
                            onChange={e => setFormData({...formData, model_name: e.target.value})}
                            placeholder="gpt-4o"
                        />
                    </div>
                </div>

                <div className="space-y-1">
                    <label className="text-xs font-medium text-gray-700">{t('settings.llm.baseUrl')}</label>
                    <input 
                        className="w-full text-sm border rounded px-2 py-1.5 focus:ring-2 focus:ring-blue-500 outline-none"
                        value={formData.base_url}
                        onChange={e => setFormData({...formData, base_url: e.target.value})}
                        placeholder="https://api.example.com/v1"
                    />
                </div>

                <div className="space-y-1">
                    <label className="text-xs font-medium text-gray-700">{t('settings.llm.apiKey')}</label>
                    <div className="relative">
                        <input 
                            ref={apiKeyInputRef}
                            type={showApiKey ? "text" : "password"}
                            required={!editingId} // Optional on edit
                            className="w-full text-sm border rounded px-2 py-1.5 pr-8 focus:ring-2 focus:ring-blue-500 outline-none"
                            value={formData.api_key}
                            onChange={e => setFormData({...formData, api_key: e.target.value})}
                            placeholder={editingId ? t('settings.connections.passwordPlaceholder') : "sk-..."}
                            autoComplete="off"
                            autoCapitalize="off"
                            style={{ willChange: 'type' }}
                        />
                        <button
                            type="button"
                            onClick={handleToggleApiKey}
                            onKeyDown={(e) => {
                                if (e.key === 'Enter' || e.key === ' ') {
                                    handleToggleApiKey(e);
                                }
                            }}
                            className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 focus:outline-none flex items-center justify-center p-0"
                            style={{ width: '20px', height: '20px' }}
                            aria-label={showApiKey ? t('common.hideApiKey') : t('common.showApiKey')}
                            tabIndex={0}
                        >
                            {showApiKey ? <EyeOff size={16} /> : <Eye size={16} />}
                        </button>
                        {/* Live region for screen readers */}
                        <span className="sr-only" aria-live="polite">
                            {showApiKey ? t('common.showApiKey') : t('common.hideApiKey')}
                        </span>
                    </div>
                </div>
                
                 <div className="space-y-1">
                    <label className="text-xs font-medium text-gray-700">{t('settings.llm.temperature')}: {formData.temperature}</label>
                     <input 
                        type="range"
                        min="0"
                        max="2"
                        step="0.1"
                        className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
                        value={formData.temperature}
                        onChange={e => setFormData({...formData, temperature: parseFloat(e.target.value)})}
                    />
                </div>

                <div className="flex justify-between items-center pt-2 relative">
                    <button 
                        type="button"
                        onClick={handleTestConnection}
                        disabled={testing || lockTime > 0}
                        className={`flex items-center gap-2 px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                             lockTime > 0 
                                 ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                 : 'text-gray-700 hover:bg-gray-100 border border-gray-300'
                        }`}
                    >
                        {testing ? (
                            <Loader2 className="animate-spin" size={16} />
                        ) : lockTime > 0 ? (
                            <span className="flex items-center gap-1">
                                {t('settings.llm.testResult.retryLocked', { seconds: lockTime })}
                            </span>
                        ) : retryCount > 0 ? (
                            <>
                                <RotateCcw size={16} />
                                {t('settings.llm.testResult.retry', { count: retryCount })}
                            </>
                        ) : (
                            <>
                                <Play size={16} />
                                {t('settings.llm.test')}
                            </>
                        )}
                    </button>
                    
                    <div className="flex gap-2">
                        <button 
                            type="button" 
                            onClick={() => {
                                setIsOpen(false);
                                resetForm();
                            }}
                            className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-md transition-colors"
                        >
                            {t('common.cancel')}
                        </button>
                        <button 
                            type="submit" 
                            disabled={loading}
                            className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md transition-colors disabled:opacity-50"
                        >
                            {loading && <Loader2 className="animate-spin" size={16} />}
                            {t('common.save')}
                        </button>
                    </div>
                </div>
            
                {/* Test Result Display */}
                {testResult && (
                    <div className={`mt-4 p-3 rounded-md text-sm border flex items-start gap-3 relative animate-in fade-in slide-in-from-top-2 ${
                        testResult.success 
                            ? 'bg-green-50 border-green-200 text-green-800' 
                            : 'bg-red-50 border-red-200 text-red-800'
                    }`}>
                        {testResult.success ? (
                            <CheckCircle2 className="shrink-0 text-green-600 mt-0.5" size={18} />
                        ) : (
                            <AlertCircle className="shrink-0 text-red-600 mt-0.5" size={18} />
                        )}
                        <div className="flex-1 space-y-1">
                            <div className="font-medium flex justify-between items-center">
                                <span>{testResult.message}</span>
                                {testResult.timestamp && (
                                    <span className="text-xs opacity-70 font-normal">
                                        {new Date(testResult.timestamp).toLocaleTimeString()}
                                    </span>
                                )}
                            </div>
                            
                            <div className="text-xs opacity-90 flex flex-col gap-1">
                                {testResult.duration_ms !== undefined && (
                                    <span>{t('settings.llm.testResult.duration', { ms: testResult.duration_ms })}</span>
                                )}
                                {testResult.status_code !== undefined && (
                                    <span>{t('settings.llm.testResult.statusCode', { code: testResult.status_code })}</span>
                                )}
                                {testResult.error_detail && (
                                    <div className="mt-1 pt-1 border-t border-red-200/50">
                                        <span className="font-semibold block mb-0.5">{t('settings.llm.testResult.errorDetail')}:</span>
                                        <span className="font-mono break-all">{testResult.error_detail}</span>
                                    </div>
                                )}
                            </div>
                        </div>
                        <button 
                            type="button"
                            onClick={() => setTestResult(null)}
                            className="absolute top-2 right-2 p-1 rounded-full hover:bg-black/5 transition-colors"
                        >
                            <X size={14} />
                        </button>
                    </div>
                )}
            </form>
        </div>
      </Modal>
    </div>
  );
}
