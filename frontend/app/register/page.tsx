'use client';

/**
 * 注册页面 - 集成表单验证和Toast通知
 * 
 * 改进：
 * 1. ✅ 使用React Hook Form + Zod验证
 * 2. ✅ Toast通知替代error state
 * 3. ✅ 类型安全
 * 4. ✅ 密码强度提示
 * 5. ✅ 实时验证反馈
 */

import React from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from '@/hooks/use-toast';
import { authApi } from '@/lib/api-services';
import { useAppStore } from '@/store/useAppStore';
import { registerSchema, type RegisterFormData } from '@/lib/schemas';

export default function RegisterPage() {
  const router = useRouter();
  const { setUser } = useAppStore();

  // 使用React Hook Form + Zod
  const form = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
    },
  });

  const onSubmit = async (data: RegisterFormData) => {
    try {
      // 显示加载Toast
      const loadingToast = toast({
        title: "🔄 正在创建账户...",
        description: "请稍候",
        duration: 0
      });

      // 注册请求 (后端不需要confirmPassword)
      const { confirmPassword, ...registerData } = data;
      const user = await authApi.register(registerData);

      // 验证返回数据
      if (!user || !user.token) {
        throw new Error('注册响应数据无效');
      }

      console.log('注册成功:', user);

      // 保存token
      if (typeof window !== 'undefined') {
        localStorage.setItem('jwt_token', user.token);
      }

      setUser(user);

      // 关闭加载，显示成功
      loadingToast.dismiss();
      toast({
        variant: "success",
        title: "✅ 注册成功",
        description: `欢迎加入, ${user.username}!`,
        duration: 2000
      });

      // 延迟跳转
      setTimeout(() => {
        console.log('正在跳转到 /chat');
        router.push('/chat');
        router.refresh();
      }, 500);

    } catch (err: any) {
      console.error('注册错误:', err);

      let errorMessage = '注册失败,请重试';

      if (err.response) {
        const data = err.response.data;
        errorMessage = data?.detail || data?.message || data?.error || errorMessage;

        // 处理常见错误
        if (errorMessage.includes('duplicate') || errorMessage.includes('已存在')) {
          errorMessage = '用户名或邮箱已被使用';
        }
      } else if (err.message) {
        errorMessage = err.message;
      }

      toast({
        variant: "error",
        title: "❌ 注册失败",
        description: errorMessage,
        duration: 5000
      });
    }
  };

  // 监听密码字段，显示强度提示
  const password = form.watch("password");

  const getPasswordStrength = (pwd: string) => {
    if (!pwd) return { label: "", color: "" };
    if (pwd.length < 6) return { label: "太短", color: "text-red-500" };
    if (pwd.length < 8) return { label: "一般", color: "text-yellow-500" };
    if (pwd.length >= 12 || /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(pwd)) {
      return { label: "强", color: "text-green-500" };
    }
    return { label: "中等", color: "text-blue-500" };
  };

  const passwordStrength = getPasswordStrength(password);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background to-muted">
      <div className="max-w-md w-full space-y-8 p-8 bg-card rounded-lg shadow-lg border">
        <div className="text-center">
          <h2 className="mt-6 text-3xl font-bold tracking-tight">
            创建新账户
          </h2>
          <p className="mt-2 text-sm text-muted-foreground">
            或者{' '}
            <Link href="/login" className="text-primary hover:underline font-medium">
              登录现有账户
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
                placeholder="3-50个字符，只能包含字母、数字、下划线"
                {...form.register("username")}
                className={form.formState.errors.username ? "border-red-500" : ""}
              />
              {form.formState.errors.username && (
                <p className="text-sm text-red-500 mt-1">
                  {form.formState.errors.username.message}
                </p>
              )}
              {!form.formState.errors.username && form.formState.touchedFields.username && (
                <p className="text-sm text-green-500 mt-1">✓ 用户名格式正确</p>
              )}
            </div>

            {/* 电子邮箱 */}
            <div>
              <Label htmlFor="email">
                电子邮箱 <span className="text-red-500">*</span>
              </Label>
              <Input
                id="email"
                type="email"
                placeholder="your@email.com"
                {...form.register("email")}
                className={form.formState.errors.email ? "border-red-500" : ""}
              />
              {form.formState.errors.email && (
                <p className="text-sm text-red-500 mt-1">
                  {form.formState.errors.email.message}
                </p>
              )}
              {!form.formState.errors.email && form.formState.touchedFields.email && (
                <p className="text-sm text-green-500 mt-1">✓ 邮箱格式正确</p>
              )}
            </div>

            {/* 密码 */}
            <div>
              <Label htmlFor="password">
                密码 <span className="text-red-500">*</span>
                {passwordStrength.label && (
                  <span className={`ml-2 text-xs ${passwordStrength.color}`}>
                    强度: {passwordStrength.label}
                  </span>
                )}
              </Label>
              <Input
                id="password"
                type="password"
                placeholder="至少6个字符"
                {...form.register("password")}
                className={form.formState.errors.password ? "border-red-500" : ""}
              />
              {form.formState.errors.password && (
                <p className="text-sm text-red-500 mt-1">
                  {form.formState.errors.password.message}
                </p>
              )}
            </div>

            {/* 确认密码 */}
            <div>
              <Label htmlFor="confirmPassword">
                确认密码 <span className="text-red-500">*</span>
              </Label>
              <Input
                id="confirmPassword"
                type="password"
                placeholder="请再次输入密码"
                {...form.register("confirmPassword")}
                className={form.formState.errors.confirmPassword ? "border-red-500" : ""}
              />
              {form.formState.errors.confirmPassword && (
                <p className="text-sm text-red-500 mt-1">
                  {form.formState.errors.confirmPassword.message}
                </p>
              )}
              {!form.formState.errors.confirmPassword &&
                form.watch("confirmPassword") &&
                form.watch("password") === form.watch("confirmPassword") && (
                  <p className="text-sm text-green-500 mt-1">✓ 密码匹配</p>
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
                正在创建账户...
              </span>
            ) : (
              '创建账户'
            )}
          </Button>

          {/* 提示信息 */}
          <div className="text-xs text-center text-muted-foreground space-y-1">
            <p>创建账户即表示您同意我们的服务条款和隐私政策</p>
          </div>
        </form>

        {/* 开发提示 */}
        <div className="mt-4 p-3 bg-muted rounded-md text-xs text-muted-foreground">
          <p className="font-semibold mb-1">💡 开发提示:</p>
          <p>• 实时验证：即时反馈</p>
          <p>• 密码强度：智能提示</p>
          <p>• Toast通知：用户友好</p>
        </div>
      </div>
    </div>
  );
}
