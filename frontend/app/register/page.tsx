'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { authApi } from '@/lib/api-services';
import { useAppStore } from '@/store/useAppStore';
import { RegisterForm } from '@/types';

export default function RegisterPage() {
  const router = useRouter();
  const { setUser } = useAppStore();
  const [formData, setFormData] = useState<RegisterForm>({
    username: '',
    email: '',
    password: '',
    confirm_password: '',
  });
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    // Validate passwords match
    if (formData.password !== formData.confirm_password) {
      setError('两次输入的密码不一致');
      setIsLoading(false);
      return;
    }

    try {
      const user = await authApi.register(formData);
      setUser(user);
      router.push('/chat');
    } catch (err: any) {
      setError(err.response?.data?.error || '注册失败，请重试。');
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="max-w-md w-full space-y-8 p-8">
        <div className="text-center">
          <h2 className="mt-6 text-3xl font-bold">创建新账户</h2>
          <p className="mt-2 text-sm text-muted-foreground">
            或者{' '}
            <Link href="/login" className="text-primary hover:underline">
              登录现有账户
            </Link>
          </p>
        </div>

        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          {error && (
            <div className="bg-destructive/10 border border-destructive text-destructive p-3 rounded-md text-sm">
              {error}
            </div>
          )}

          <div className="space-y-4">
            <div>
              <Label htmlFor="username">用户名</Label>
              <Input
                id="username"
                name="username"
                type="text"
                required
                value={formData.username}
                onChange={handleChange}
                placeholder="请选择用户名"
              />
            </div>

            <div>
              <Label htmlFor="email">电子邮箱</Label>
              <Input
                id="email"
                name="email"
                type="email"
                required
                value={formData.email}
                onChange={handleChange}
                placeholder="请输入电子邮箱"
              />
            </div>

            <div>
              <Label htmlFor="password">密码</Label>
              <Input
                id="password"
                name="password"
                type="password"
                required
                value={formData.password}
                onChange={handleChange}
                placeholder="请设置密码"
              />
            </div>

            <div>
              <Label htmlFor="confirm_password">确认密码</Label>
              <Input
                id="confirm_password"
                name="confirm_password"
                type="password"
                required
                value={formData.confirm_password}
                onChange={handleChange}
                placeholder="请确认密码"
              />
            </div>
          </div>

          <Button
            type="submit"
            className="w-full"
            disabled={isLoading}
          >
            {isLoading ? '正在创建...' : '创建账户'}
          </Button>
        </form>
      </div>
    </div>
  );
}
