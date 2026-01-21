'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useUser } from '@/store/useAppStore';

export default function HomePage() {
  const router = useRouter();
  const user = useUser();

  useEffect(() => {
    if (user) {
      router.push('/chat');
    } else {
      router.push('/login');
    }
  }, [user, router]);

  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="text-center">
        <h1 className="text-2xl font-bold mb-4">企业级 AI SQL 分析平台</h1>
        <p className="text-muted-foreground">正在跳转...</p>
      </div>
    </div>
  );
}
