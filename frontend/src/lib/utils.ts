import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function cleanMarkdownContent(content: string | null): string {
  if (!content) return "";

  let cleaned = content;

  // 1. 移除 ECharts 代码块（包括标题）
  cleaned = cleaned.replace(/(#+)?\s*📊\s*自动可视化\s*\(Auto-Visualization\)[\s\S]*?```echarts[\s\S]*?```/g, '');

  // 2. 检测并提取嵌套的 content 字段（LLM 错误地输出了整个 JSON 对象）
  // 匹配: { "content": "实际内容", "chart_option": {...} }
  const nestedContentMatch = cleaned.match(/^\s*\{\s*"content"\s*:\s*"([\s\S]*?)"\s*,\s*"chart_option"/);
  if (nestedContentMatch) {
    // 提取实际的 content 内容，并处理转义字符
    try {
      const extractedContent = JSON.parse(`"${nestedContentMatch[1]}"`);
      cleaned = extractedContent;
    } catch {
      // 如果 JSON 解析失败，使用原始匹配
      cleaned = nestedContentMatch[1]
        .replace(/\\n/g, '\n')
        .replace(/\\"/g, '"')
        .replace(/\\\\/g, '\\');
    }
  }

  // 3. 移除独立的 chart_option JSON 对象
  cleaned = cleaned.replace(/[,\s]*"chart_option"\s*:\s*\{[\s\S]*?\}\s*(?=[,}]|$)/g, '');

  // 4. 移除可能残留的顶层 JSON 包装
  cleaned = cleaned.replace(/^\s*\{\s*"content"\s*:\s*"([\s\S]*?)"\s*\}\s*$/g, '$1');

  // 5. 移除特殊占位符和标签
  cleaned = cleaned.replace(/\[\/?(SQL|Thinking|Chart)\]/g, '');
  cleaned = cleaned.replace(/<think>[\s\S]*?<\/think>/g, '');

  // 6. 补全未闭合的代码块 (非常关键：防止代码块未闭合导致的整个页面高度猛跳)
  const codeBlockCount = (cleaned.match(/```/g) || []).length;
  if (codeBlockCount % 2 !== 0) {
      cleaned += '\n```';
  }

  return cleaned.trim();
}
