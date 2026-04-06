import { useState, useEffect, useRef, useCallback } from 'react';
import { connectionService } from '@/services/connection-service';
import type { DbConnection, DbConnectionCreate, ConnectionTestResponse, DbType } from '@/types/api';
import { Modal } from '@/components/ui/Modal';
import { Trash2, Edit2, Database, Loader2, Play, AlertCircle, CheckCircle2, RotateCcw, Eye, EyeOff } from 'lucide-react';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';

export function DbConnectionManager({ connections = [], selectedId, onSelect, onUpdate }: { connections?: DbConnection[]; selectedId?: number | null; onSelect?: (id: number | null) => void; onUpdate?: () => void }) {
  const { t } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);
  const [modalConnections, setModalConnections] = useState<DbConnection[]>([]);
  const [loading, setLoading] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [testing, setTesting] = useState(false);
  const [testResult, setTestResult] = useState<ConnectionTestResponse | null>(null);
  const [retryCount, setRetryCount] = useState(0);
  const [lockTime, setLockTime] = useState(0);
  const [showPassword, setShowPassword] = useState(false);
  const resultTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

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
      return () => {
          if (resultTimerRef.current) clearTimeout(resultTimerRef.current);
      };
  }, []);
  
  // Form State
  const [formData, setFormData] = useState<DbConnectionCreate>({
    name: '',
    type: 'mysql',
    host: 'localhost',
    port: 3306,
    username: '',
    database_name: '',
    password: ''
  });

  const [view, setView] = useState<'list' | 'form'>('list');

  const fetchConnections = useCallback(async () => {
    try {
      setLoading(true);
      const data = await connectionService.getAll();
      setModalConnections(data);
    } catch {
      toast.error(t('settings.connections.loadFailed'));
    } finally {
      setLoading(false);
    }
  }, [t]);

  useEffect(() => {
    if (isOpen && view === 'list') {
      fetchConnections();
    }
  }, [isOpen, view, fetchConnections]);

  const handleEdit = async (id: number) => {
    console.log('handleEdit called with id:', id);
    try {
      setLoading(true);
      console.log('Fetching connection for edit...');
      const data = await connectionService.getForEdit(id);
      console.log('Connection data received:', data);
      setFormData({
        name: data.name,
        type: data.type,
        host: data.host,
        port: data.port,
        username: data.username,
        database_name: data.database_name,
        password: data.password
      });
      setEditingId(id);
      setView('form');
      console.log('Form view set, editingId:', id);
    } catch (error) {
      console.error('Error in handleEdit:', error);
      toast.error(t('settings.connections.loadFailed'));
    } finally {
      setLoading(false);
    }
  };

  const handleAdd = () => {
    resetForm();
    setView('form');
  };

  const handleBackToList = () => {
    resetForm();
    setView('list');
  };

  const handleDelete = async (id: number) => {
    if (!confirm(t('settings.connections.confirmDelete'))) return;
    try {
      await connectionService.delete(id);
      toast.success(t('settings.connections.deleteSuccess'));
      fetchConnections();
      onUpdate?.();
    } catch {
      toast.error(t('common.error'));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setLoading(true);
      if (editingId) {
        await connectionService.update(editingId, formData);
        toast.success(t('settings.connections.updateSuccess'));
      } else {
        await connectionService.create(formData);
        toast.success(t('settings.connections.createSuccess'));
      }
      resetForm();
      setView('list');
      fetchConnections();
      onUpdate?.();
    } catch {
      toast.error(editingId ? t('common.error') : t('common.error'));
    } finally {
      setLoading(false);
    }
  };

  const handleTestConnection = async () => {
    if (lockTime > 0) return;

    setTesting(true);
    setTestResult(null);
    
    // Clear previous result timer
    if (resultTimerRef.current) clearTimeout(resultTimerRef.current);

    try {
      const result = await connectionService.testConnection(formData);
      setTestResult(result);

      if (result.success) {
        // Success: clear retry count
        setRetryCount(0);
        toast.success(t('settings.connections.testSuccess'));
      } else {
        // Failure: increment retry count
        const newRetryCount = retryCount + 1;
        setRetryCount(newRetryCount);
        if (newRetryCount >= 3) {
            setLockTime(30); // Lock for 30 seconds
        }
        toast.error(t('settings.connections.testFailed'));
      }
    } catch (error) {
        setTestResult({
            success: false,
            message: t('settings.connections.testFailed'),
            error_detail: String(error),
            timestamp: new Date().toISOString(),
            duration_ms: 0
        });
        const newRetryCount = retryCount + 1;
        setRetryCount(newRetryCount);
        if (newRetryCount >= 3) {
             setLockTime(30);
        }
    } finally {
      setTesting(false);
      
      // Auto hide after 5 seconds
      resultTimerRef.current = setTimeout(() => {
          setTestResult(null);
      }, 5000);
    }
  };

  const resetForm = () => {
    setEditingId(null);
    setFormData({
      name: '',
      type: 'mysql',
      host: 'localhost',
      port: 3306,
      username: '',
      database_name: '',
      password: ''
    });
    setTestResult(null);
    setRetryCount(0);
    setLockTime(0);
    setShowPassword(false);
  };

  return (
    <div className="space-y-2">
        <div className="flex items-center justify-between">
            <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider flex items-center gap-1">
                <Database size={12} />
                {t('settings.database')}
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
                        <option value="">{t('settings.selectDatabase')}</option>
                        {connections.map(c => (
                            <option key={c.id} value={c.id}>{c.name}</option>
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
                    title={t('settings.connections.edit')}
                 >
                    <Edit2 size={16} />
                 </button>
             </div>
        )}

      <Modal 
        isOpen={isOpen} 
        onClose={() => setIsOpen(false)} 
        title={t('settings.connections.title')}
        description={t('settings.connections.description')}
      >
        <div className="space-y-6">
            {/* List View */}
            {view === 'list' && (
                <div className="space-y-4">
                    <div className="flex justify-end">
                        <button 
                            type="button"
                            onClick={handleAdd}
                            className="flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md transition-colors"
                        >
                            <Database size={14} />
                            {t('settings.connections.add')}
                        </button>
                    </div>

                    <div className="space-y-2 max-h-[60vh] overflow-y-auto border border-border rounded-md p-2 bg-muted/30 dark:bg-zinc-900/30">
                        {loading && modalConnections.length === 0 ? (
                            <div className="flex justify-center p-4"><Loader2 className="animate-spin text-muted-foreground" /></div>
                        ) : modalConnections.length === 0 ? (
                            <div className="text-center text-sm text-muted-foreground py-4">{t('settings.connections.noConnections')}</div>
                        ) : (
                            modalConnections.map(conn => (
                                <div key={conn.id} className="flex items-center justify-between p-3 bg-background border border-border rounded-md shadow-sm hover:shadow-md transition-shadow relative group">
                                    <div className="flex items-center gap-3 overflow-hidden flex-1 min-w-0 pr-2">
                                        <div className="p-2 bg-blue-50 rounded-full flex-shrink-0">
                                            <Database size={16} className="text-blue-600" />
                                        </div>
                                        <div className="truncate">
                                            <div className="text-sm font-medium text-gray-900 truncate">{conn.name}</div>
                                            <div className="text-xs text-gray-500 truncate flex items-center gap-1">
                                                <span className="px-1.5 py-0.5 bg-gray-100 rounded text-[10px] uppercase font-semibold">{conn.type}</span>
                                                <span>{conn.host}:{conn.port}/{conn.database_name}</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-1 flex-shrink-0 bg-white pl-2">
                                        <button 
                                            type="button"
                                            onClick={async (e) => {
                                                e.stopPropagation();
                                                try {
                                                    const res = await connectionService.refreshSchema(conn.id);
                                                    if (res.success) toast.success(res.message);
                                                } catch {
                                                    toast.error('刷新缓存失败');
                                                }
                                            }} 
                                            className="p-2 text-gray-500 hover:bg-green-50 hover:text-green-600 rounded-full transition-colors cursor-pointer z-10"
                                            title="刷新 Schema 缓存"
                                        >
                                            <RotateCcw size={16} />
                                        </button>
                                        <button 
                                            type="button"
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                handleEdit(conn.id);
                                            }} 
                                            className="p-2 text-gray-500 hover:bg-gray-100 hover:text-blue-600 rounded-full transition-colors cursor-pointer z-10"
                                            title={t('common.edit')}
                                        >
                                            <Edit2 size={16} />
                                        </button>
                                        <button 
                                            type="button"
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                handleDelete(conn.id);
                                            }} 
                                            className="p-2 text-gray-500 hover:bg-red-50 hover:text-red-600 rounded-full transition-colors cursor-pointer z-10"
                                            title={t('common.delete')}
                                        >
                                            <Trash2 size={16} />
                                        </button>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            )}

            {/* Form View */}
            {view === 'form' && (
                <form onSubmit={handleSubmit} className="space-y-4 animate-in fade-in slide-in-from-right-4 duration-300">
                    <div className="flex items-center gap-2 mb-4 pb-2 border-b">
                        <button 
                            type="button" 
                            onClick={handleBackToList}
                            className="p-1 hover:bg-gray-100 rounded-full transition-colors"
                        >
                            <RotateCcw className="rotate-90" size={20} />
                        </button>
                        <h3 className="text-lg font-medium text-gray-900">
                            {editingId ? t('settings.connections.edit') : t('settings.connections.add')}
                        </h3>
                    </div>
                
                <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                        <label className="text-xs font-medium text-gray-700">{t('settings.connections.name')}</label>
                        <input 
                            required
                            className="w-full text-sm border rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                            value={formData.name}
                            onChange={e => setFormData({...formData, name: e.target.value})}
                            placeholder="My DB"
                        />
                    </div>
                    <div className="space-y-1.5">
                        <label className="text-xs font-medium text-gray-700">{t('settings.connections.type')}</label>
                        <select 
                            className="w-full text-sm border rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none bg-white transition-all"
                            value={formData.type}
                            onChange={e => setFormData({...formData, type: e.target.value as DbType})}
                        >
                            <option value="mysql">MySQL</option>
                            <option value="postgresql">PostgreSQL</option>
                            <option value="sqlite">SQLite</option>
                        </select>
                    </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                     <div className="col-span-2 space-y-1.5">
                        <label className="text-xs font-medium text-gray-700">{t('settings.connections.host')}</label>
                        <input 
                            required
                            className="w-full text-sm border rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                            value={formData.host}
                            onChange={e => setFormData({...formData, host: e.target.value})}
                            placeholder="localhost"
                        />
                    </div>
                    <div className="space-y-1.5">
                        <label className="text-xs font-medium text-gray-700">{t('settings.connections.port')}</label>
                        <input 
                            required
                            type="number"
                            className="w-full text-sm border rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                            value={formData.port}
                            onChange={e => setFormData({...formData, port: parseInt(e.target.value) || 3306})}
                        />
                    </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                     <div className="space-y-1.5">
                        <label className="text-xs font-medium text-gray-700">{t('settings.connections.username')}</label>
                        <input 
                            required
                            className="w-full text-sm border rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                            value={formData.username}
                            onChange={e => setFormData({...formData, username: e.target.value})}
                        />
                    </div>
                    <div className="space-y-1.5">
                        <label className="text-xs font-medium text-gray-700">{t('settings.connections.database')}</label>
                        <input 
                            required
                            className="w-full text-sm border rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                            value={formData.database_name}
                            onChange={e => setFormData({...formData, database_name: e.target.value})}
                        />
                    </div>
                </div>

                <div className="space-y-1.5">
                    <label className="text-xs font-medium text-gray-700">{t('settings.connections.password')}</label>
                    <div className="relative">
                        <input 
                            type={showPassword ? "text" : "password"}
                            required={!editingId} // Optional on edit
                            className="w-full text-sm border rounded-md px-3 py-2 pr-10 focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                            value={formData.password}
                            onChange={e => setFormData({...formData, password: e.target.value})}
                            placeholder={editingId ? t('settings.connections.passwordPlaceholder') : ""}
                        />
                        <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 focus:outline-none"
                            aria-label={showPassword ? t('common.hidePassword') : t('common.showPassword')}
                        >
                            {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                        </button>
                    </div>
                </div>

                <div className="flex justify-between items-center pt-4 border-t mt-4">
                    <button 
                        type="button"
                        onClick={handleTestConnection}
                        disabled={testing || lockTime > 0}
                        className={`flex items-center gap-2 px-4 py-2 text-sm font-medium rounded-md transition-colors ${
                           lockTime > 0 
                             ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                             : 'text-gray-700 hover:bg-gray-100 border border-gray-300'
                        }`}
                    >
                        {testing ? (
                            <Loader2 className="animate-spin" size={16} />
                        ) : lockTime > 0 ? (
                            <span className="flex items-center gap-1">
                                {t('settings.connections.testResult.retryLocked', { seconds: lockTime })}
                            </span>
                        ) : retryCount > 0 ? (
                            <>
                                <RotateCcw size={16} />
                                {t('settings.connections.testResult.retry', { count: retryCount })}
                            </>
                        ) : (
                            <>
                                <Play size={16} />
                                {t('settings.connections.test')}
                            </>
                        )}
                    </button>
                    <div className="flex gap-3">
                        <button 
                            type="button" 
                            onClick={handleBackToList}
                            className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-md transition-colors"
                        >
                            {t('common.cancel')}
                        </button>
                        <button 
                            type="submit" 
                            disabled={loading}
                            className="flex items-center gap-2 px-6 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md shadow-sm hover:shadow transition-all disabled:opacity-50 disabled:shadow-none"
                        >
                            {loading && <Loader2 className="animate-spin" size={16} />}
                            {t('common.save')}
                        </button>
                    </div>
                </div>
                
                {/* Test Result Display */}
                {testResult && (
                    <div className={`mt-4 p-4 rounded-md text-sm border flex flex-col gap-3 relative animate-in fade-in slide-in-from-bottom-2 ${testResult.success ? 'bg-green-50 border-green-200 text-green-800' : 'bg-red-50 border-red-200 text-red-800'}`}>
                        <div className="flex items-start gap-3">
                            {testResult.success ? <CheckCircle2 className="shrink-0 text-green-600 mt-0.5" size={20} /> : <AlertCircle className="shrink-0 text-red-600 mt-0.5" size={20} />}
                            <div className="flex-1 space-y-1.5">
                                <div className="font-medium flex justify-between items-center">
                                    <span className="text-base">{testResult.message}</span>
                                    {testResult.timestamp && <span className="text-xs opacity-70 font-normal bg-white/50 px-2 py-0.5 rounded-full">{new Date(testResult.timestamp).toLocaleTimeString()}</span>}
                                </div>
                                
                                {testResult.success && testResult.duration_ms !== undefined && (
                                    <div className="flex items-center gap-2 text-xs mt-1">
                                        <div className="flex items-center gap-1 bg-green-100/50 px-2 py-1 rounded">
                                            <span className="font-medium">延迟:</span>
                                            <span className={`${testResult.duration_ms < 200 ? 'text-green-700' : testResult.duration_ms < 500 ? 'text-yellow-700' : 'text-red-700'}`}>
                                                {testResult.duration_ms}ms
                                            </span>
                                        </div>
                                    </div>
                                )}

                                {!testResult.success && testResult.error_detail && (
                                    <div className="mt-2 text-xs font-mono bg-red-100/50 p-2 rounded overflow-x-auto whitespace-pre-wrap border border-red-200">
                                        {testResult.error_detail}
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                )}
            </form>
            )}
        </div>
      </Modal>
    </div>
  );
}
