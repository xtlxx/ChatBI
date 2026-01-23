// middleware.ts
/**
 * Next.js 中间件 - 路由保护
 * 
 * 功能：
 * 1. 保护需要登录的页面
 * 2. 防止已登录用户访问登录/注册页面
 * 3. 自动重定向
 */
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
    // 获取JWT Token（优先从Cookie，其次从localStorage模拟）
    const token = request.cookies.get('jwt_token')?.value;

    const { pathname } = request.nextUrl;

    // 定义公开页面（不需要登录）
    const publicPaths = ['/login', '/register'];
    const isPublicPath = publicPaths.some(path => pathname.startsWith(path));

    // 定义受保护页面（需要登录）
    const protectedPaths = ['/chat', '/settings'];
    const isProtectedPath = protectedPaths.some(path => pathname.startsWith(path));

    // === 规则1: 未登录访问受保护页面 → 重定向到登录 ===
    if (!token && isProtectedPath) {
        const loginUrl = new URL('/login', request.url);
        // 保存原始URL，登录后可跳转回来
        loginUrl.searchParams.set('redirect', pathname);
        return NextResponse.redirect(loginUrl);
    }

    // === 规则2: 已登录访问登录/注册页面 → 重定向到聊天 ===
    if (token && isPublicPath) {
        return NextResponse.redirect(new URL('/chat', request.url));
    }

    // === 规则3: 根路径重定向 ===
    if (pathname === '/') {
        if (token) {
            return NextResponse.redirect(new URL('/chat', request.url));
        } else {
            return NextResponse.redirect(new URL('/login', request.url));
        }
    }

    // 其他路径正常访问
    return NextResponse.next();
}

// 配置需要中间件处理的路径
export const config = {
    // 匹配所有路径，但排除：
    // - API路由
    // - Next.js内部路由(_next)
    // - 静态文件(images, favicon等)
    matcher: [
        /*
         * 匹配所有路径，除了：
         * - api (API routes)
         * - _next/static (static files)
         * - _next/image (image optimization files)
         * - favicon.ico (favicon file)
         * - public folder files
         */
        '/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
    ],
};
