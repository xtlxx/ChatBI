'use client';

/**
 * 登录页面 - 集成表单验证和Toast通知
 * 
 * 改进：
 * 1. ✅ 使用React Hook Form + Zod验证
 * 2. ✅ Toast通知替代error state
 * 3. ✅ 类型安全
 * 4. ✅ 实时验证反馈
 * 5. ✅ 更好的用户体验
 */

import React from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from '@/hooks/use-toast';
import { authApi } from '@/lib/api-services';
import { useAppStore } from '@/store/useAppStore';
import { loginSchema, type LoginFormData } from '@/lib/schemas';

export default function LoginPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { setUser } = useAppStore();

  // 获取重定向参数
  const redirectUrl = searchParams.get('redirect') || '/chat';

  // 使用React Hook Form + Zod
  const form = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      username: '',
      password: '',
    },
  });

  const onSubmit = async (data: LoginFormData) => {
    try {
      // 显示加载Toast
      const loadingToast = toast({
        title: "🔄 正在登录...",
        description: "请稍候",
        duration: 0  // 不自动关闭
      });

      const user = await authApi.login(data);

      // 验证返回的数据
      if (!user || !user.token) {
        throw new Error('登录响应数据无效');
      }

      console.log('登录成功,准备跳转:', user);

      // 必须手动保存 token
      if (typeof window !== 'undefined') {
        localStorage.setItem('jwt_token', user.token);
      }

      setUser(user);

      // 关闭加载Toast，显示成功Toast
      loadingToast.dismiss();
      toast({
        variant: "success",
        title: "✅ 登录成功",
        description: `欢迎回来, ${user.username}!`,
        duration: 2000
      });

      // 延迟一点跳转，让用户看到成功提示
      setTimeout(() => {
        console.log('正在跳转到:', redirectUrl);
        router.push(redirectUrl);
        router.refresh();
      }, 500);

    } catch (err: any) {
      console.error('登录错误:', err);

      // 提取错误信息
      let errorMessage = '登录失败,请重试';

      if (err.response) {
        const data = err.response.data;
        errorMessage = data?.detail || data?.message || data?.error || errorMessage;
      } else if (err.message) {
        errorMessage = err.message;
      }

      // 使用Toast显示错误
      toast({
        variant: "error",
        title: "❌ 登录失败",
        description: errorMessage,
        duration: 5000
      });
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background to-muted">
      <div className="max-w-md w-full space-y-8 p-8 bg-card rounded-lg shadow-lg border">
        <div className="text-center">
          <h2 className="mt-6 text-3xl font-bold tracking-tight">
            登录您的账户
          </h2>
          <p className="mt-2 text-sm text-muted-foreground">
            或者{' '}
            <Link href="/register" className="text-primary hover:underline font-medium">
              创建新账户
            </Link>
          </p>
        </div>

        <form className="mt-8 space-y-6" onSubmit={form.handleSubmit(onSubmit)}>
          <div className="space-y-4">
            {/* 用户名 */}
            <div>
              <Label htmlFor="username">
                用户名 <span className="text-red-500">*</span>
              </Label>
              <Input
                id="username"
                type="text"
                placeholder="请输入用户名"
                {...form.register("username")}
                className={form.formState.errors.username ? "border-red-500" : ""}
              />
              {form.formState.errors.username && (
                <p className="text-sm text-red-500 mt-1">
                  {form.formState.errors.username.message}
                </p>
              )}
            </div>

            {/* 密码 */}
            <div>
              <Label htmlFor="password">
                密码 <span className="text-red-500">*</span>
              </Label>
              <Input
                id="password"
                type="password"
                placeholder="请输入密码"
                {...form.register("password")}
                className={form.formState.errors.password ? "border-red-500" : ""}
              />
              {form.formState.errors.password && (
                <p className="text-sm text-red-500 mt-1">
                  {form.formState.errors.password.message}
                </p>
              )}
            </div>
          </div>

          {/* 提交按钮 */}
          <Button
            type="submit"
            className="w-full"
            disabled={form.formState.isSubmitting}
          >
            {form.formState.isSubmitting ? (
              <span className="flex items-center gap-2">
                <span className="animate-spin">⏳</span>
                正在登录...
              </span>
            ) : (
              '登录'
            )}
          </Button>

          {/* 提示信息 */}
          {redirectUrl !== '/chat' && (
            <p className="text-sm text-center text-muted-foreground">
              登录后将返回到您之前访问的页面
            </p>
          )}
        </form>

        {/* 开发提示 */}
        <div className="mt-4 p-3 bg-muted rounded-md text-xs text-muted-foreground">
          <p className="font-semibold mb-1">💡 开发提示:</p>
          <p>• 表单验证：实时反馈</p>
          <p>• Toast通知：优雅提示</p>
          <p>• 路由保护：自动重定向</p>
        </div>
      </div>
    </div>
  );
}
