'use client';

import React, { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, TestTube, Database, Bot, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { useConnections, useLlmConfigs, useAppStore } from '@/store/useAppStore';
import { dbConnectionApi, llmConfigApi } from '@/lib/api-services';
import { DbConnectionForm, LlmConfigForm } from '@/types';
import { toast } from '@/hooks/use-toast';

const SettingsPage: React.FC = () => {
  const connections = useConnections();
  const llmConfigs = useLlmConfigs();
  const { setConnections, setLlmConfigs, addConnection, addLlmConfig, removeConnection, removeLlmConfig } = useAppStore();

  const [dbDialogOpen, setDbDialogOpen] = useState(false);
  const [llmDialogOpen, setLlmDialogOpen] = useState(false);
  const [editingDb, setEditingDb] = useState<(DbConnectionForm & { id?: number }) | null>(null);
  const [editingLlm, setEditingLlm] = useState<(LlmConfigForm & { id?: number }) | null>(null);
  const [testingConnection, setTestingConnection] = useState(false);

  // Database connection form state
  const [dbForm, setDbForm] = useState<DbConnectionForm>({
    name: '',
    type: 'mysql',
    host: '',
    port: 3306,
    username: '',
    password: '',
    database_name: '',
  });

  // LLM configuration form state
  const [llmForm, setLlmForm] = useState<LlmConfigForm>({
    provider: 'openai',
    model_name: '',
    api_key: '',
    base_url: '',
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
    setDbForm({
      name: '',
      type: 'mysql',
      host: '',
      port: 3306,
      username: '',
      password: '',
      database_name: '',
    });
    setEditingDb(null);
  };

  const resetLlmForm = () => {
    setLlmForm({
      provider: 'openai',
      model_name: '',
      api_key: '',
      base_url: '',
    });
    setEditingLlm(null);
  };

  const handleTestDbConnection = async () => {
    setTestingConnection(true);
    try {
      const result = await dbConnectionApi.testConnection(dbForm);
      if (result.success) {
        toast({
          title: '✅ 连接测试成功',
          description: result.message,
          variant: 'success',
        });
      } else {
        toast({
          title: '❌ 连接测试失败',
          description: result.message,
          variant: 'error',
        });
      }
    } catch (error: any) {
      toast({
        title: '❌ 连接测试失败',
        description: error.response?.data?.detail || error.message || '未知错误',
        variant: 'error',
      });
    } finally {
      setTestingConnection(false);
    }
  };

  const handleTestLlmConnection = async () => {
    setTestingConnection(true);
    try {
      const result = await llmConfigApi.testConnection(llmForm);
      if (result.success) {
        toast({
          title: '✅ LLM 配置测试成功',
          description: result.message,
          variant: 'success',
        });
      } else {
        toast({
          title: '❌ LLM 测试失败',
          description: result.message,
          variant: 'error',
        });
      }
    } catch (error: any) {
      toast({
        title: '❌ LLM 测试失败',
        description: error.response?.data?.detail || error.message || '未知错误',
        variant: 'error',
      });
    } finally {
      setTestingConnection(false);
    }
  };

  const handleSaveDbConnection = async () => {
    try {
      if (editingDb) {
        // Update existing connection
        const updated = await dbConnectionApi.update(editingDb.id as number, dbForm);
        setConnections(connections.map(conn => conn.id === updated.id ? updated : conn));
        toast({
          title: '✅ 更新成功',
          description: '数据库连接已更新',
          variant: 'success',
        });
      } else {
        // Create new connection
        const created = await dbConnectionApi.create(dbForm);
        addConnection(created);
        toast({
          title: '✅ 保存成功',
          description: '数据库连接已创建',
          variant: 'success',
        });
      }
      setDbDialogOpen(false);
      resetDbForm();
    } catch (error: any) {
      toast({
        title: '❌ 保存失败',
        description: error.response?.data?.detail || error.message || '保存数据库连接失败',
        variant: 'error',
      });
    }
  };

  const handleSaveLlmConfig = async () => {
    try {
      if (editingLlm) {
        // Update existing config
        const updated = await llmConfigApi.update(editingLlm.id as number, llmForm);
        setLlmConfigs(llmConfigs.map(config => config.id === updated.id ? updated : config));
        toast({
          title: '✅ 更新成功',
          description: 'LLM 配置已更新',
          variant: 'success',
        });
      } else {
        // Create new config
        const created = await llmConfigApi.create(llmForm);
        addLlmConfig(created);
        toast({
          title: '✅ 保存成功',
          description: 'LLM 配置已创建',
          variant: 'success',
        });
      }
      setLlmDialogOpen(false);
      resetLlmForm();
    } catch (error: any) {
      toast({
        title: '❌ 保存失败',
        description: error.response?.data?.detail || error.message || '保存 LLM 配置失败',
        variant: 'error',
      });
    }
  };

  const handleEditDb = (connection: any) => {
    setDbForm({
      name: connection.name,
      type: connection.type,
      host: connection.host,
      port: connection.port,
      username: connection.username,
      password: '', // Don't populate password for security
      database_name: connection.database_name,
    });
    setEditingDb(connection);
    setDbDialogOpen(true);
  };

  const handleEditLlm = (config: any) => {
    setLlmForm({
      provider: config.provider,
      model_name: config.model_name,
      api_key: '', // Don't populate API key for security
      base_url: config.base_url || '',
    });
    setEditingLlm(config);
    setLlmDialogOpen(true);
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
        });
      } catch (error: any) {
        toast({
          title: '❌ 删除失败',
          description: error.response?.data?.detail || error.message || '删除数据库连接失败',
          variant: 'error',
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
        });
      } catch (error: any) {
        toast({
          title: '❌ 删除失败',
          description: error.response?.data?.detail || error.message || '删除 LLM 配置失败',
          variant: 'error',
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
              <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                  <DialogTitle>
                    {editingDb ? '编辑数据库连接' : '添加数据库连接'}
                  </DialogTitle>
                  <DialogDescription>
                    配置您的数据库连接。保存前请测试连接。
                  </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="name" className="text-right">
                      名称
                    </Label>
                    <Input
                      id="name"
                      value={dbForm.name}
                      onChange={(e) => setDbForm({ ...dbForm, name: e.target.value })}
                      className="col-span-3"
                    />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="type" className="text-right">
                      类型
                    </Label>
                    <Select value={dbForm.type} onValueChange={(value: any) => setDbForm({ ...dbForm, type: value })}>
                      <SelectTrigger className="col-span-3">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="mysql">MySQL</SelectItem>
                        <SelectItem value="postgresql">PostgreSQL</SelectItem>
                        <SelectItem value="mssql">MS SQL Server</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="host" className="text-right">
                      主机
                    </Label>
                    <Input
                      id="host"
                      value={dbForm.host}
                      onChange={(e) => setDbForm({ ...dbForm, host: e.target.value })}
                      className="col-span-3"
                    />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="port" className="text-right">
                      端口
                    </Label>
                    <Input
                      id="port"
                      type="number"
                      value={dbForm.port}
                      onChange={(e) => setDbForm({ ...dbForm, port: Number(e.target.value) })}
                      className="col-span-3"
                    />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="username" className="text-right">
                      用户名
                    </Label>
                    <Input
                      id="username"
                      value={dbForm.username}
                      onChange={(e) => setDbForm({ ...dbForm, username: e.target.value })}
                      className="col-span-3"
                    />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="password" className="text-right">
                      密码
                    </Label>
                    <Input
                      id="password"
                      type="password"
                      value={dbForm.password}
                      onChange={(e) => setDbForm({ ...dbForm, password: e.target.value })}
                      className="col-span-3"
                    />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="database" className="text-right">
                      数据库
                    </Label>
                    <Input
                      id="database"
                      value={dbForm.database_name}
                      onChange={(e) => setDbForm({ ...dbForm, database_name: e.target.value })}
                      className="col-span-3"
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleTestDbConnection}
                    disabled={testingConnection}
                  >
                    <TestTube className="h-4 w-4 mr-2" />
                    {testingConnection ? '测试中...' : '测试连接'}
                  </Button>
                  <Button type="button" onClick={handleSaveDbConnection}>
                    保存
                  </Button>
                </DialogFooter>
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
              <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                  <DialogTitle>
                    {editingLlm ? '编辑 LLM 配置' : '添加 LLM 配置'}
                  </DialogTitle>
                  <DialogDescription>
                    配置您的 LLM 模型设置。保存前请测试连接。
                  </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="provider" className="text-right">
                      提供商
                    </Label>
                    <Select value={llmForm.provider} onValueChange={(value) => setLlmForm({ ...llmForm, provider: value })}>
                      <SelectTrigger className="col-span-3">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="openai">OpenAI</SelectItem>
                        <SelectItem value="qwen">Qwen</SelectItem>
                        <SelectItem value="deepseek">DeepSeek</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="model_name" className="text-right">
                      模型名称
                    </Label>
                    <Input
                      id="model_name"
                      value={llmForm.model_name}
                      onChange={(e) => setLlmForm({ ...llmForm, model_name: e.target.value })}
                      className="col-span-3"
                    />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="api_key" className="text-right">
                      API 密钥
                    </Label>
                    <Input
                      id="api_key"
                      type="password"
                      value={llmForm.api_key}
                      onChange={(e) => setLlmForm({ ...llmForm, api_key: e.target.value })}
                      className="col-span-3"
                    />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="base_url" className="text-right">
                      API 代理地址
                    </Label>
                    <Input
                      id="base_url"
                      value={llmForm.base_url}
                      onChange={(e) => setLlmForm({ ...llmForm, base_url: e.target.value })}
                      className="col-span-3"
                      placeholder="可选: 自定义 API 端点"
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleTestLlmConnection}
                    disabled={testingConnection}
                  >
                    <TestTube className="h-4 w-4 mr-2" />
                    {testingConnection ? '测试中...' : '测试连接'}
                  </Button>
                  <Button type="button" onClick={handleSaveLlmConfig}>
                    保存
                  </Button>
                </DialogFooter>
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
                    <td className="p-4">{config.provider}</td>
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
