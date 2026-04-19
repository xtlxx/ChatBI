import { useState } from 'react';
import { Copy, Check, Terminal } from 'lucide-react';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism';

export const SqlBlock = ({ sql }: { sql: string }) => {
    const [copied, setCopied] = useState(false);

    const handleCopy = () => {
        navigator.clipboard.writeText(sql);
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
    };

    return (
        <div className="my-6 overflow-hidden rounded-xl border border-white/5 bg-[#0d0d0d] shadow-2xl">
            {/* Header: 仿 IDE 标签栏 */} 
            <div className="flex items-center justify-between bg-white/[0.03] px-4 py-2.5"> 
                <div className="flex items-center gap-2.5"> 
                    <div className="flex gap-1.5"> 
                        <div className="h-3 w-3 rounded-full bg-red-500/20 border border-red-500/30" /> 
                        <div className="h-3 w-3 rounded-full bg-amber-500/20 border border-amber-500/30" /> 
                        <div className="h-3 w-3 rounded-full bg-emerald-500/20 border border-emerald-500/30" /> 
                    </div> 
                    <div className="h-4 w-px bg-white/10 mx-1" /> 
                    <div className="flex items-center gap-2 text-[11px] font-medium text-zinc-400 tracking-wider uppercase"> 
                        <Terminal size={12} className="text-indigo-400" /> 
                        PostgreSQL Query 
                    </div> 
                </div> 
                <button 
                    onClick={handleCopy} 
                    className="flex items-center gap-1.5 rounded-md px-2 py-1 text-xs text-zinc-500 hover:bg-white/5 hover:text-zinc-200 transition-all" 
                > 
                    {copied ? <Check size={13} className="text-emerald-500" /> : <Copy size={13} />} 
                    <span className="text-[10px]">{copied ? 'Copied' : 'Copy'}</span> 
                </button> 
            </div> 

            {/* SQL Content */} 
            <div className="relative group"> 
                <SyntaxHighlighter 
                    language="sql" 
                    style={vscDarkPlus} 
                    customStyle={{ 
                        margin: 0, 
                        padding: '1.5rem', 
                        fontSize: '13px', 
                        lineHeight: '1.6', 
                        background: 'transparent', 
                    }} 
                > 
                    {sql} 
                </SyntaxHighlighter> 
                
                {/* 装饰物：右下角水印 */} 
                <div className="absolute bottom-2 right-4 text-[10px] text-white/5 font-mono select-none pointer-events-none"> 
                    NEURAL_SQL_V2 
                </div> 
            </div> 
        </div>
    );
};
