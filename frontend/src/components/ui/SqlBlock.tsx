import { useState } from 'react';
import { ChevronDown, Code as CodeIcon, Copy, Check } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useTranslation } from 'react-i18next';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { vscDarkPlus, vs } from 'react-syntax-highlighter/dist/esm/styles/prism';
import { useThemeStore } from '@/store/theme-store';

interface SqlBlockProps {
  sql: string;
}

export function SqlBlock({ sql }: SqlBlockProps) {
  const { t } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);
  const [copied, setCopied] = useState(false);
  const { theme } = useThemeStore();

  const isDark = theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);

  const toggle = () => setIsOpen(!isOpen);

  const copyToClipboard = (e: React.MouseEvent) => {
    e.stopPropagation();
    navigator.clipboard.writeText(sql);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="mt-4 border border-border rounded-xl overflow-hidden bg-card shadow-sm">
      <div
        onClick={toggle}
        className="bg-muted/50 px-4 py-2.5 text-xs font-mono text-muted-foreground border-b border-border flex justify-between items-center cursor-pointer hover:bg-muted/70 transition-colors"
      >
        <div className="flex items-center gap-2 select-none">
          <CodeIcon size={14} className="text-blue-500" />
          <span className="font-medium">{t('sqlBlock.title')}</span>
          <div className={`transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`}>
            <ChevronDown size={14} />
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-[10px] opacity-50 hidden sm:inline">
            {sql.split('\n').length} {t('sqlBlock.lines')}
          </span>
          <button
            onClick={copyToClipboard}
            className="hover:text-primary transition-colors flex items-center gap-1 z-10 px-2 py-1 rounded-md hover:bg-background"
          >
            {copied ? <Check size={12} className="text-green-500" /> : <Copy size={12} />}
            <span className="hidden sm:inline">{copied ? t('sqlBlock.copied') : t('sqlBlock.copy')}</span>
          </button>
        </div>
      </div>
      <div
        className={cn(
          "transition-all duration-300 ease-in-out overflow-hidden",
          isOpen ? "max-h-[2000px] opacity-100" : "max-h-0 opacity-0"
        )}
      >
        <SyntaxHighlighter
            PreTag="div"
            children={sql}
            language="sql"
            style={isDark ? vscDarkPlus : vs}
            customStyle={{ margin: 0, padding: '1rem', fontSize: '0.75rem', backgroundColor: 'transparent', lineHeight: 1.6 }}
        />
      </div>

    </div>
  );
}
