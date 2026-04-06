import React, { useEffect, useRef, useState } from 'react';
import mermaid from 'mermaid';
import { useThemeStore } from '@/store/theme-store';

interface MermaidDiagramProps {
    chart: string;
}

export const MermaidDiagram: React.FC<MermaidDiagramProps> = ({ chart }) => {
    const containerRef = useRef<HTMLDivElement>(null);
    const [svgCode, setSvgCode] = useState<string>('');
    const { theme } = useThemeStore();
    
    // Determine actual theme string ('dark' or 'light')
    const actualTheme = theme === 'system' 
        ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default')
        : (theme === 'dark' ? 'dark' : 'default');

    useEffect(() => {
        // Initialize mermaid with dynamic theme
        mermaid.initialize({
            startOnLoad: false,
            theme: actualTheme as any,
            securityLevel: 'loose',
            fontFamily: 'inherit'
        });

        const renderDiagram = async () => {
            if (!containerRef.current || !chart) return;
            try {
                // Generate a unique ID for the mermaid container to avoid conflicts
                const id = `mermaid-${Math.random().toString(36).substr(2, 9)}`;
                const { svg } = await mermaid.render(id, chart);
                setSvgCode(svg);
            } catch (error) {
                console.error('Failed to render Mermaid diagram:', error);
                setSvgCode(`<div class="p-4 text-sm text-red-500 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md">Failed to render diagram: Invalid Mermaid syntax</div>`);
            }
        };

        renderDiagram();
    }, [chart, actualTheme]);

    return (
        <div 
            className="my-4 overflow-x-auto flex justify-center p-4 bg-white dark:bg-[#1a1a1a] rounded-xl border border-gray-100 dark:border-zinc-800/50 shadow-sm"
            ref={containerRef}
            dangerouslySetInnerHTML={{ __html: svgCode }}
        />
    );
};
