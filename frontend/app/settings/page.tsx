'use client';

import React, { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Zap, Eye, EyeOff, Database, Bot, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { useConnections, useLlmConfigs, useAppStore } from '@/store/useAppStore';
import { dbConnectionApi, llmConfigApi } from '@/lib/api-services';
import { toast } from '@/hooks/use-toast';
import { api } from '@/lib/api';
import { dbConnectionSchema, llmConfigSchema, type DbConnectionFormData, type LlmConfigFormData } from '@/lib/schemas';

const SettingsPage: React.FC = () => {
  const connections = useConnections();
  const llmConfigs = useLlmConfigs();
  const { setConnections, setLlmConfigs, addConnection, addLlmConfig, removeConnection, removeLlmConfig } = useAppStore();

  // Provider显示名称映射
  const getProviderDisplayName = (provider: string) => {
    const providerMap: { [key: string]: string } = {
      'openai': 'OpenAI',
      'qwen': 'Qwen',
      'deepseek': 'DeepSeek',
      'anthropic': 'Anthropic (Claude)',
      'moonshot': 'Moonshot',
      'ollama': 'Ollama (本地)',
      'gemini': 'Google Gemini',
      'other': '其他'
    };
    return providerMap[provider] || provider;
  };

  // 临时API方法
  const getConnectionForEdit = async (id: number): Promise<any> => {
    const response = await api.get(`/connections/${id}/edit`);
    return response.data || response;
  };

  const getLlmConfigForEdit = async (id: number): Promise<any> => {
    const response = await api.get(`/llm-configs/${id}/edit`);
    return response.data || response;
  };

  const [dbDialogOpen, setDbDialogOpen] = useState(false);
  const [llmDialogOpen, setLlmDialogOpen] = useState(false);
  const [editingDbId, setEditingDbId] = useState<number | null>(null);
  const [editingLlmId, setEditingLlmId] = useState<number | null>(null);
  const [testingConnection, setTestingConnection] = useState(false);
  const [showApiKey, setShowApiKey] = useState(false);
  const [showDbPassword, setShowDbPassword] = useState(false);

  // Database connection form with react-hook-form
  const dbForm = useForm<DbConnectionFormData>({
    resolver: zodResolver(dbConnectionSchema),
    mode: 'onChange',  // 实时验证
    defaultValues: {
      name: '',
      type: 'mysql',
      host: '',
      port: 3306,
      username: '',
      password: '',
      database_name: ''
    }
  });

  // LLM configuration form with react-hook-form
  const llmForm = useForm<LlmConfigFormData>({
    resolver: zodResolver(llmConfigSchema),
    mode: 'onChange',  // 实时验证
    defaultValues: {
      provider: 'openai',
      model_name: '',
      api_key: '',
      base_url: '',
    }
  });

  useEffect(() => {
    loadConnections();
    loadLlmConfigs();
  }, []);

  const loadConnections = async () => {
    try {
      const data = await dbConnectionApi.getAll();
      setConnections(data);
    } catch (error) {
      console.error('Failed to load database connections:', error);
    }
  };

  const loadLlmConfigs = async () => {
    try {
      const data = await llmConfigApi.getAll();
      setLlmConfigs(data);
    } catch (error) {
      console.error('Failed to load LLM configurations:', error);
    }
  };

  const resetDbForm = () => {
    dbForm.reset({
      name: '',
      type: 'mysql',
      host: '',
      port: 3306,
      username: '',
      password: '',
      database_name: '',
    });
    setEditingDbId(null);
    setShowDbPassword(false);
  };

  const resetLlmForm = () => {
    llmForm.reset({
      provider: 'openai',
      model_name: '',
      api_key: '',
      base_url: '',
    });
    setEditingLlmId(null);
    setShowApiKey(false);
  };

  const handleTestDbConnection = async () => {
    const isValid = await dbForm.trigger();
    if (!isValid) {
      toast({
        title: '⚠️ 验证失败',
        description: '请检查表单错误并修正',
        variant: 'error',
        duration: 3000,
      });
      return;
    }

    setTestingConnection(true);
    try {
      const formData = dbForm.getValues();
      const result = await dbConnectionApi.testConnection(formData);
      if (result.success) {
        toast({
          title: '✅ 连接测试成功',
          description: result.message,
          variant: 'success',
          duration: 3000,
        });
      } else {
        toast({
          title: '❌ 连接测试失败',
          description: result.message,
          variant: 'error',
          duration: 5000,
        });
      }
    } catch (error: any) {
      toast({
        title: '❌ 连接测试失败',
        description: error.response?.data?.detail || error.message || '未知错误',
        variant: 'error',
        duration: 5000,
      });
    } finally {
      setTestingConnection(false);
    }
  };

  const handleTestLlmConnection = async () => {
    const isValid = await llmForm.trigger();
    if (!isValid) {
      toast({
        title: '⚠️ 验证失败',
        description: '请检查表单错误并修正',
        variant: 'error',
        duration: 3000,
      });
      return;
    }

    setTestingConnection(true);
    try {
      const formData = llmForm.getValues();
      const result = await llmConfigApi.testConnection(formData);
      if (result.success) {
        toast({
          title: '✅ LLM 配置测试成功',
          description: result.message,
          variant: 'success',
          duration: 3000,
        });
      } else {
        toast({
          title: '❌ LLM 测试失败',
          description: result.message,
          variant: 'error',
          duration: 5000,
        });
      }
    } catch (error: any) {
      toast({
        title: '❌ LLM 测试失败',
        description: error.message || '网络连接失败，请检查配置',
        variant: 'error',
        duration: 5000,
      });
    } finally {
      setTestingConnection(false);
    }
  };

  const onSubmitDbConnection = async (data: DbConnectionFormData) => {
    try {
      if (editingDbId) {
        // Update existing connection
        const updated = await dbConnectionApi.update(editingDbId, data);
        setConnections(connections.map(conn => conn.id === updated.id ? updated : conn));
        toast({
          title: '✅ 更新成功',
          description: '数据库连接已更新',
          variant: 'success',
          duration: 3000,
        });
      } else {
        // Create new connection
        const created = await dbConnectionApi.create(data);
        addConnection(created);
        toast({
          title: '✅ 保存成功',
          description: '数据库连接已创建',
          variant: 'success',
          duration: 3000,
        });
      }
      setDbDialogOpen(false);
      resetDbForm();
    } catch (error: any) {
      toast({
        title: '❌ 保存失败',
        description: error.response?.data?.detail || error.message || '保存数据库连接失败',
        variant: 'error',
        duration: 5000,
      });
    }
  };

  const onSubmitLlmConfig = async (data: LlmConfigFormData) => {
    try {
      if (editingLlmId) {
        // Update existing config
        const updated = await llmConfigApi.update(editingLlmId, data);
        setLlmConfigs(llmConfigs.map(config => config.id === updated.id ? updated : config));
        toast({
          title: '✅ 更新成功',
          description: 'LLM 配置已更新',
          variant: 'success',
          duration: 3000,
        });
      } else {
        // Create new config
        const created = await llmConfigApi.create(data);
        addLlmConfig(created);
        toast({
          title: '✅ 保存成功',
          description: 'LLM 配置已创建',
          variant: 'success',
          duration: 3000,
        });
      }
      setLlmDialogOpen(false);
      resetLlmForm();
    } catch (error: any) {
      toast({
        title: '❌ 保存失败',
        description: error.response?.data?.detail || error.message || '保存 LLM 配置失败',
        variant: 'error',
        duration: 5000,
      });
    }
  };

  const handleEditDb = async (connection: any) => {
    try {
      // 获取包含密码的完整配置
      const fullConnection = await getConnectionForEdit(connection.id);
      dbForm.reset({
        name: fullConnection.name,
        type: fullConnection.type,
        host: fullConnection.host,
        port: fullConnection.port,
        username: fullConnection.username,
        password: fullConnection.password,
        database_name: fullConnection.database_name,
      });
      setEditingDbId(connection.id);
      setDbDialogOpen(true);
      setShowDbPassword(false);
    } catch (error) {
      toast({
        title: '❌ 获取配置失败',
        description: '无法获取数据库连接配置，请重试',
        variant: 'error',
        duration: 5000,
      });
    }
  };

  const handleEditLlm = async (config: any) => {
    try {
      // 获取包含API密钥的完整配置
      const fullConfig = await getLlmConfigForEdit(config.id);
      llmForm.reset({
        provider: fullConfig.provider,
        model_name: fullConfig.model_name,
        api_key: fullConfig.api_key,
        base_url: fullConfig.base_url || '',
      });
      setEditingLlmId(config.id);
      setLlmDialogOpen(true);
      setShowApiKey(false);
    } catch (error) {
      toast({
        title: '❌ 获取配置失败',
        description: '无法获取LLM配置，请重试',
        variant: 'error',
        duration: 5000,
      });
    }
  };

  const handleDeleteDb = async (id: number) => {
    if (confirm('您确定要删除此数据库连接吗?')) {
      try {
        await dbConnectionApi.delete(id);
        removeConnection(id);
        toast({
          title: '✅ 删除成功',
          description: '数据库连接已删除',
          variant: 'success',
          duration: 3000,
        });
      } catch (error: any) {
        toast({
          title: '❌ 删除失败',
          description: error.response?.data?.detail || error.message || '删除数据库连接失败',
          variant: 'error',
          duration: 5000,
        });
      }
    }
  };

  const handleDeleteLlm = async (id: number) => {
    if (confirm('您确定要删除此 LLM 配置吗?')) {
      try {
        await llmConfigApi.delete(id);
        removeLlmConfig(id);
        toast({
          title: '✅ 删除成功',
          description: 'LLM 配置已删除',
          variant: 'success',
          duration: 3000,
        });
      } catch (error: any) {
        toast({
          title: '❌ 删除失败',
          description: error.response?.data?.detail || error.message || '删除 LLM 配置失败',
          variant: 'error',
          duration: 5000,
        });
      }
    }
  };

  return (
    <div className="container mx-auto py-6">
      <div className="flex items-center gap-4 mb-6">
        <Link href="/chat">
          <Button variant="ghost" size="icon">
            <ArrowLeft className="h-4 w-4" />
          </Button>
        </Link>
        <div>
          <h1 className="text-3xl font-bold">设置</h1>
          <p className="text-muted-foreground">管理您的数据库连接和 LLM 配置</p>
        </div>
      </div>

      <Tabs defaultValue="database" className="w-full">
        <TabsList>
          <TabsTrigger value="database" className="flex items-center gap-2">
            <Database className="h-4 w-4" />
            数据库连接
          </TabsTrigger>
          <TabsTrigger value="llm" className="flex items-center gap-2">
            <Bot className="h-4 w-4" />
            LLM 模型
          </TabsTrigger>
        </TabsList>

        <TabsContent value="database" className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-semibold">数据库连接</h2>
            <Dialog open={dbDialogOpen} onOpenChange={setDbDialogOpen}>
              <DialogTrigger asChild>
                <Button onClick={resetDbForm}>
                  <Plus className="h-4 w-4 mr-2" />
                  添加连接
                </Button>
              </DialogTrigger>
              <DialogContent
                className="sm:max-w-[425px]"
                onInteractOutside={(e) => e.preventDefault()}
                onEscapeKeyDown={(e) => e.preventDefault()}
              >
                <DialogHeader>
                  <DialogTitle>
                    {editingDbId ? '编辑数据库连接' : '添加数据库连接'}
                  </DialogTitle>
                  <DialogDescription>
                    配置您的数据库连接。保存前请测试连接。
                  </DialogDescription>
                </DialogHeader>
                <form onSubmit={dbForm.handleSubmit(onSubmitDbConnection)} className="grid gap-4 py-4">
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="name" className="text-right">
                      名称 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <Input
                        id="name"
                        {...dbForm.register('name')}
                        className={dbForm.formState.errors.name ? 'border-red-500' : ''}
                      />
                      {dbForm.formState.errors.name && (
                        <p className="text-sm text-red-500 mt-1">{dbForm.formState.errors.name.message}</p>
                      )}
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="type" className="text-right">
                      类型 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <Select
                        value={dbForm.watch('type')}
                        onValueChange={(value: any) => dbForm.setValue('type', value)}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="mysql">MySQL</SelectItem>
                          <SelectItem value="postgresql">PostgreSQL</SelectItem>
                          <SelectItem value="mssql">MS SQL Server</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="host" className="text-right">
                      主机 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <Input
                        id="host"
                        {...dbForm.register('host')}
                        className={dbForm.formState.errors.host ? 'border-red-500' : ''}
                      />
                      {dbForm.formState.errors.host && (
                        <p className="text-sm text-red-500 mt-1">{dbForm.formState.errors.host.message}</p>
                      )}
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="port" className="text-right">
                      端口 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <Input
                        id="port"
                        type="number"
                        {...dbForm.register('port', { valueAsNumber: true })}
                        className={dbForm.formState.errors.port ? 'border-red-500' : ''}
                      />
                      {dbForm.formState.errors.port && (
                        <p className="text-sm text-red-500 mt-1">{dbForm.formState.errors.port.message}</p>
                      )}
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="username" className="text-right">
                      用户名 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <Input
                        id="username"
                        {...dbForm.register('username')}
                        className={dbForm.formState.errors.username ? 'border-red-500' : ''}
                      />
                      {dbForm.formState.errors.username && (
                        <p className="text-sm text-red-500 mt-1">{dbForm.formState.errors.username.message}</p>
                      )}
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="password" className="text-right">
                      密码 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <div className="relative">
                        <Input
                          id="password"
                          type={showDbPassword ? "text" : "password"}
                          {...dbForm.register('password')}
                          className={`pr-10 ${dbForm.formState.errors.password ? 'border-red-500' : ''}`}
                        />
                        <Button
                          type="button"
                          variant="ghost"
                          size="sm"
                          className="absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent"
                          onClick={() => setShowDbPassword(!showDbPassword)}
                        >
                          {showDbPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </Button>
                      </div>
                      {dbForm.formState.errors.password && (
                        <p className="text-sm text-red-500 mt-1">{dbForm.formState.errors.password.message}</p>
                      )}
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="database_name" className="text-right">
                      数据库 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <Input
                        id="database_name"
                        {...dbForm.register('database_name')}
                        className={dbForm.formState.errors.database_name ? 'border-red-500' : ''}
                      />
                      {dbForm.formState.errors.database_name && (
                        <p className="text-sm text-red-500 mt-1">{dbForm.formState.errors.database_name.message}</p>
                      )}
                    </div>
                  </div>
                  <DialogFooter>
                    <Button
                      type="button"
                      variant="outline"
                      onClick={handleTestDbConnection}
                      disabled={testingConnection}
                    >
                      <Zap className="h-4 w-4 mr-2" />
                      {testingConnection ? '测试中...' : '测试连接'}
                    </Button>
                    <Button type="submit" disabled={!dbForm.formState.isValid}>
                      保存
                    </Button>
                  </DialogFooter>
                </form>
              </DialogContent>
            </Dialog>
          </div>

          <div className="border rounded-lg">
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left p-4">名称</th>
                  <th className="text-left p-4">类型</th>
                  <th className="text-left p-4">主机</th>
                  <th className="text-left p-4">端口</th>
                  <th className="text-left p-4">用户名</th>
                  <th className="text-left p-4">操作</th>
                </tr>
              </thead>
              <tbody>
                {connections.map((connection) => (
                  <tr key={connection.id} className="border-b">
                    <td className="p-4">{connection.name}</td>
                    <td className="p-4">{connection.type}</td>
                    <td className="p-4">{connection.host}</td>
                    <td className="p-4">{connection.port}</td>
                    <td className="p-4">{connection.username}</td>
                    <td className="p-4">
                      <div className="flex gap-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleEditDb(connection)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDeleteDb(connection.id)}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {connections.length === 0 && (
              <div className="text-center p-8 text-muted-foreground">
                未配置数据库连接。请添加您的第一个连接以开始使用。
              </div>
            )}
          </div>
        </TabsContent>

        <TabsContent value="llm" className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-semibold">LLM 模型</h2>
            <Dialog open={llmDialogOpen} onOpenChange={setLlmDialogOpen}>
              <DialogTrigger asChild>
                <Button onClick={resetLlmForm}>
                  <Plus className="h-4 w-4 mr-2" />
                  添加 LLM 模型
                </Button>
              </DialogTrigger>
              <DialogContent
                className="sm:max-w-[425px]"
                onInteractOutside={(e) => e.preventDefault()}
                onEscapeKeyDown={(e) => e.preventDefault()}
              >
                <DialogHeader>
                  <DialogTitle>
                    {editingLlmId ? '编辑 LLM 配置' : '添加 LLM 配置'}
                  </DialogTitle>
                  <DialogDescription>
                    配置您的 LLM 模型设置。保存前请测试连接。
                  </DialogDescription>
                </DialogHeader>
                <form onSubmit={llmForm.handleSubmit(onSubmitLlmConfig)} className="grid gap-4 py-4">
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="provider" className="text-right">
                      提供商 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <Select
                        value={llmForm.watch('provider')}
                        onValueChange={(value) => llmForm.setValue('provider', value as LlmConfigFormData['provider'])}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="openai">OpenAI</SelectItem>
                          <SelectItem value="qwen">Qwen</SelectItem>
                          <SelectItem value="deepseek">DeepSeek</SelectItem>
                          <SelectItem value="anthropic">Anthropic(Claude)</SelectItem>
                          <SelectItem value="moonshot">Moonshot</SelectItem>
                          <SelectItem value="ollama">Ollama(本地)</SelectItem>
                          <SelectItem value="gemini">Google Gemini</SelectItem>
                          <SelectItem value="other">其他</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="model_name" className="text-right">
                      模型名称 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <Input
                        id="model_name"
                        {...llmForm.register('model_name')}
                        className={llmForm.formState.errors.model_name ? 'border-red-500' : ''}
                      />
                      {llmForm.formState.errors.model_name && (
                        <p className="text-sm text-red-500 mt-1">{llmForm.formState.errors.model_name.message}</p>
                      )}
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="api_key" className="text-right">
                      API 密钥 <span className="text-red-500">*</span>
                    </Label>
                    <div className="col-span-3">
                      <div className="relative">
                        <Input
                          id="api_key"
                          type={showApiKey ? "text" : "password"}
                          {...llmForm.register('api_key')}
                          className={`pr-10 ${llmForm.formState.errors.api_key ? 'border-red-500' : ''}`}
                        />
                        <Button
                          type="button"
                          variant="ghost"
                          size="sm"
                          className="absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent"
                          onClick={() => setShowApiKey(!showApiKey)}
                        >
                          {showApiKey ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </Button>
                      </div>
                      {llmForm.formState.errors.api_key && (
                        <p className="text-sm text-red-500 mt-1">{llmForm.formState.errors.api_key.message}</p>
                      )}
                    </div>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="base_url" className="text-right">
                      API 代理地址
                    </Label>
                    <div className="col-span-3">
                      <Input
                        id="base_url"
                        {...llmForm.register('base_url')}
                        placeholder="可选: 自定义 API 端点"
                        className={llmForm.formState.errors.base_url ? 'border-red-500' : ''}
                      />
                      {llmForm.formState.errors.base_url && (
                        <p className="text-sm text-red-500 mt-1">{llmForm.formState.errors.base_url.message}</p>
                      )}
                    </div>
                  </div>
                  <DialogFooter>
                    <Button
                      type="button"
                      variant="outline"
                      onClick={handleTestLlmConnection}
                      disabled={testingConnection}
                    >
                      <Zap className="h-4 w-4 mr-2" />
                      {testingConnection ? '测试中...' : '测试连接'}
                    </Button>
                    <Button type="submit" disabled={!llmForm.formState.isValid}>
                      保存
                    </Button>
                  </DialogFooter>
                </form>
              </DialogContent>
            </Dialog>
          </div>

          <div className="border rounded-lg">
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left p-4">提供商</th>
                  <th className="text-left p-4">模型名称</th>
                  <th className="text-left p-4">API 代理地址 (Base URL)</th>
                  <th className="text-left p-4">操作</th>
                </tr>
              </thead>
              <tbody>
                {llmConfigs.map((config) => (
                  <tr key={config.id} className="border-b">
                    <td className="p-4">{getProviderDisplayName(config.provider)}</td>
                    <td className="p-4">{config.model_name}</td>
                    <td className="p-4">{config.base_url || '默认'}</td>
                    <td className="p-4">
                      <div className="flex gap-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleEditLlm(config)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDeleteLlm(config.id)}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {llmConfigs.length === 0 && (
              <div className="text-center p-8 text-muted-foreground">
                未找到 LLM 配置。请添加您的第一个 LLM 模型以开始使用。
              </div>
            )}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default SettingsPage;
