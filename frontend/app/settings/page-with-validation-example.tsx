// app/settings/page-with-validation-example.tsx
/**
 * Settings页面 - 集成表单验证示例
 * 这个文件展示如何使用：
 * 1. React Hook Form + Zod验证
 * 2. Toast通知
 * 3. 类型安全的表单处理
 * 
 * 使用方法：将此文件内容复制到 app/settings/page.tsx
 */
"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { toast } from "@/hooks/use-toast";
import {
    dbConnectionSchema,
    llmConfigSchema,
    type DbConnectionFormData,
    type LlmConfigFormData
} from "@/lib/schemas";

// 假设已有的API客户端
import { dbConnectionApi, llmConfigApi } from "@/lib/api-services";

export default function SettingsPage() {
    const [dbDialogOpen, setDbDialogOpen] = useState(false);
    const [llmDialogOpen, setLlmDialogOpen] = useState(false);

    // === 数据库连接表单 ===
    const dbForm = useForm<DbConnectionFormData>({
        resolver: zodResolver(dbConnectionSchema),
        defaultValues: {
            name: "",
            type: "mysql",
            host: "localhost",
            port: 3306,
            username: "",
            password: "",
            database_name: ""
        }
    });

    const onDbSubmit = async (data: DbConnectionFormData) => {
        try {
            await dbConnectionApi.create(data);

            toast({
                variant: "success",
                title: "✅ 连接已创建",
                description: `数据库连接"${data.name}"已成功保存`,
                duration: 3000
            });

            dbForm.reset();
            setDbDialogOpen(false);
        } catch (error: any) {
            toast({
                variant: "error",
                title: "❌ 创建失败",
                description: error.response?.data?.detail || error.message || "请稍后重试",
                duration: 5000
            });
        }
    };

    const testDbConnection = async () => {
        try {
            // 先验证表单
            const isValid = await dbForm.trigger();
            if (!isValid) {
                toast({
                    variant: "warning",
                    title: "⚠️ 请检查表单",
                    description: "部分字段填写有误，请修正后再测试"
                });
                return;
            }

            const data = dbForm.getValues();

            toast({
                title: "🔄 测试中...",
                description: "正在连接数据库",
                duration: 1000
            });

            const result = await dbConnectionApi.test(data);

            if (result.success) {
                toast({
                    variant: "success",
                    title: "✅ 连接成功",
                    description: result.message
                });
            } else {
                toast({
                    variant: "error",
                    title: "❌ 连接失败",
                    description: result.message
                });
            }
        } catch (error: any) {
            toast({
                variant: "error",
                title: "❌ 测试失败",
                description: error.message
            });
        }
    };

    // === LLM配置表单 ===
    const llmForm = useForm<LlmConfigFormData>({
        resolver: zodResolver(llmConfigSchema),
        defaultValues: {
            provider: "openai",
            model_name: "",
            api_key: "",
            base_url: ""
        }
    });

    const onLlmSubmit = async (data: LlmConfigFormData) => {
        try {
            await llmConfigApi.create(data);

            toast({
                variant: "success",
                title: "✅ LLM配置已创建",
                description: `${data.provider} - ${data.model_name} 配置成功`,
                duration: 3000
            });

            llmForm.reset();
            setLlmDialogOpen(false);
        } catch (error: any) {
            toast({
                variant: "error",
                title: "❌ 创建失败",
                description: error.response?.data?.detail || error.message,
                duration: 5000
            });
        }
    };

    return (
        <div className="container mx-auto py-8 px-4">
            <h1 className="text-3xl font-bold mb-6">系统设置</h1>

            <Tabs defaultValue="database" className="w-full">
                <TabsList className="grid w-full grid-cols-2">
                    <TabsTrigger value="database">数据库连接</TabsTrigger>
                    <TabsTrigger value="llm">LLM模型</TabsTrigger>
                </TabsList>

                {/* === 数据库连接标签页 === */}
                <TabsContent value="database" className="mt-6">
                    <div className="flex justify-between items-center mb-4">
                        <h2 className="text-xl font-semibold">数据库连接</h2>

                        <Dialog open={dbDialogOpen} onOpenChange={setDbDialogOpen}>
                            <DialogTrigger asChild>
                                <Button>+ 添加连接</Button>
                            </DialogTrigger>

                            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                                <DialogHeader>
                                    <DialogTitle>添加数据库连接</DialogTitle>
                                </DialogHeader>

                                <form onSubmit={dbForm.handleSubmit(onDbSubmit)} className="space-y-4">
                                    {/* 连接名称 */}
                                    <div>
                                        <Label htmlFor="name">连接名称 *</Label>
                                        <Input
                                            id="name"
                                            placeholder="例如：生产数据库"
                                            {...dbForm.register("name")}
                                        />
                                        {dbForm.formState.errors.name && (
                                            <p className="text-sm text-red-500 mt-1">
                                                {dbForm.formState.errors.name.message}
                                            </p>
                                        )}
                                    </div>

                                    {/* 数据库类型 */}
                                    <div>
                                        <Label htmlFor="type">数据库类型 *</Label>
                                        <Select
                                            onValueChange={(value) => dbForm.setValue("type", value as any)}
                                            defaultValue={dbForm.getValues("type")}
                                        >
                                            <SelectTrigger>
                                                <SelectValue placeholder="选择数据库类型" />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="mysql">MySQL</SelectItem>
                                                <SelectItem value="postgresql">PostgreSQL</SelectItem>
                                                <SelectItem value="mssql">MS SQL Server</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        {dbForm.formState.errors.type && (
                                            <p className="text-sm text-red-500 mt-1">
                                                {dbForm.formState.errors.type.message}
                                            </p>
                                        )}
                                    </div>

                                    {/* 主机和端口 */}
                                    <div className="grid grid-cols-2 gap-4">
                                        <div>
                                            <Label htmlFor="host">主机地址 *</Label>
                                            <Input
                                                id="host"
                                                placeholder="localhost"
                                                {...dbForm.register("host")}
                                            />
                                            {dbForm.formState.errors.host && (
                                                <p className="text-sm text-red-500 mt-1">
                                                    {dbForm.formState.errors.host.message}
                                                </p>
                                            )}
                                        </div>

                                        <div>
                                            <Label htmlFor="port">端口 *</Label>
                                            <Input
                                                id="port"
                                                type="number"
                                                placeholder="3306"
                                                {...dbForm.register("port", { valueAsNumber: true })}
                                            />
                                            {dbForm.formState.errors.port && (
                                                <p className="text-sm text-red-500 mt-1">
                                                    {dbForm.formState.errors.port.message}
                                                </p>
                                            )}
                                        </div>
                                    </div>

                                    {/* 用户名和密码 */}
                                    <div className="grid grid-cols-2 gap-4">
                                        <div>
                                            <Label htmlFor="username">用户名 *</Label>
                                            <Input
                                                id="username"
                                                placeholder="root"
                                                {...dbForm.register("username")}
                                            />
                                            {dbForm.formState.errors.username && (
                                                <p className="text-sm text-red-500 mt-1">
                                                    {dbForm.formState.errors.username.message}
                                                </p>
                                            )}
                                        </div>

                                        <div>
                                            <Label htmlFor="password">密码 *</Label>
                                            <Input
                                                id="password"
                                                type="password"
                                                {...dbForm.register("password")}
                                            />
                                            {dbForm.formState.errors.password && (
                                                <p className="text-sm text-red-500 mt-1">
                                                    {dbForm.formState.errors.password.message}
                                                </p>
                                            )}
                                        </div>
                                    </div>

                                    {/* 数据库名 */}
                                    <div>
                                        <Label htmlFor="database_name">数据库名 *</Label>
                                        <Input
                                            id="database_name"
                                            placeholder="my_database"
                                            {...dbForm.register("database_name")}
                                        />
                                        {dbForm.formState.errors.database_name && (
                                            <p className="text-sm text-red-500 mt-1">
                                                {dbForm.formState.errors.database_name.message}
                                            </p>
                                        )}
                                    </div>

                                    {/* 操作按钮 */}
                                    <div className="flex justify-end gap-2 pt-4">
                                        <Button
                                            type="button"
                                            variant="outline"
                                            onClick={testDbConnection}
                                        >
                                            测试连接
                                        </Button>
                                        <Button type="submit">
                                            保存配置
                                        </Button>
                                    </div>
                                </form>
                            </DialogContent>
                        </Dialog>
                    </div>

                    {/* 这里显示现有连接列表 */}
                    <div className="text-gray-500">
                        连接列表将显示在这里...
                    </div>
                </TabsContent>

                {/* === LLM配置标签页 === */}
                <TabsContent value="llm" className="mt-6">
                    {/* LLM配置表单类似实现... */}
                    <div className="text-gray-500">
                        LLM配置列表将显示在这里...
                    </div>
                </TabsContent>
            </Tabs>
        </div>
    );
}
