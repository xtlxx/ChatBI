import { useState, useMemo } from 'react';
import { ChevronDown, Code as CodeIcon, Copy, Check } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useTranslation } from 'react-i18next';

interface SqlBlockProps {
  sql: string;
}

// Simple SQL syntax highlighter (no external dependency needed)
function highlightSQL(sql: string): string {
  // Reserved keywords
  const keywords = [
    'SELECT', 'FROM', 'WHERE', 'AND', 'OR', 'NOT', 'IN', 'IS', 'NULL',
    'JOIN', 'LEFT', 'RIGHT', 'INNER', 'OUTER', 'CROSS', 'ON',
    'GROUP', 'BY', 'ORDER', 'ASC', 'DESC', 'HAVING',
    'LIMIT', 'OFFSET', 'AS', 'DISTINCT', 'ALL', 'UNION',
    'INSERT', 'INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE',
    'CREATE', 'ALTER', 'DROP', 'TABLE', 'INDEX',
    'CASE', 'WHEN', 'THEN', 'ELSE', 'END',
    'BETWEEN', 'LIKE', 'EXISTS', 'WITH', 'RECURSIVE',
    'TRUE', 'FALSE', 'DEFAULT',
  ];

  // Functions
  const functions = [
    'COUNT', 'SUM', 'AVG', 'MIN', 'MAX', 'COALESCE', 'IFNULL', 'NULLIF',
    'DATE_FORMAT', 'DATE', 'NOW', 'CURDATE', 'YEAR', 'MONTH', 'DAY',
    'CONCAT', 'SUBSTRING', 'TRIM', 'UPPER', 'LOWER', 'LENGTH',
    'CAST', 'CONVERT', 'ROUND', 'FLOOR', 'CEIL', 'ABS',
    'GROUP_CONCAT', 'IF', 'DATEDIFF', 'DATE_ADD', 'DATE_SUB',
    'ROW_NUMBER', 'RANK', 'DENSE_RANK', 'LAG', 'LEAD', 'OVER', 'PARTITION',
  ];

  let result = sql;

  // Escape HTML
  result = result.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  // Highlight strings (single-quoted)
  result = result.replace(
    /('(?:[^'\\]|\\.)*')/g,
    '<span class="sql-string">$1</span>'
  );

  // Highlight numbers
  result = result.replace(
    /\b(\d+(?:\.\d+)?)\b/g,
    '<span class="sql-number">$1</span>'
  );

  // Highlight comments
  result = result.replace(
    /(--.*$)/gm,
    '<span class="sql-comment">$1</span>'
  );

  // Highlight keywords (case insensitive, whole word)
  for (const kw of keywords) {
    const regex = new RegExp(`\\b(${kw})\\b`, 'gi');
    result = result.replace(regex, '<span class="sql-keyword">$1</span>');
  }

  // Highlight functions
  for (const fn of functions) {
    const regex = new RegExp(`\\b(${fn})\\s*(?=\\()`, 'gi');
    result = result.replace(regex, '<span class="sql-function">$1</span>');
  }

  // Highlight backtick-quoted identifiers
  result = result.replace(
    /(`[^`]+`)/g,
    '<span class="sql-identifier">$1</span>'
  );

  return result;
}

export function SqlBlock({ sql }: SqlBlockProps) {
  const { t } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const toggle = () => setIsOpen(!isOpen);

  const highlightedSQL = useMemo(() => highlightSQL(sql), [sql]);

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
        <pre
          className="p-4 overflow-x-auto text-xs font-mono leading-relaxed text-foreground bg-card m-0 sql-highlight"
          dangerouslySetInnerHTML={{ __html: highlightedSQL }}
        />
      </div>

    </div>
  );
}
