import type { ThinkingStatus } from "@/components/ThinkingState";
import type { ChartOption } from "./api";

export interface Message {
    id: string | number;
    role: 'user' | 'ai';
    content: string | null;
    thinking?: string;
    thinkingStatus?: ThinkingStatus;
    sqlThought?: string;
    sql?: string;
    status?: string;
    executionResult?: string;
    executionTime?: string;  // 执行耗时，如 "3.45秒"
    executionSeconds?: number;  // 执行秒数
    chartOption?: ChartOption;
    isLoading?: boolean;
    isError?: boolean;
    retryErrors?: string[];   // 重试过程中的错误（不显示在正文中）
    timestamp: number;
}
