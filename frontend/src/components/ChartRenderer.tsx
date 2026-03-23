import { useRef, useEffect, useState, useCallback } from 'react';
import ReactECharts from 'echarts-for-react';
import { Maximize2, Minimize2, Download, RefreshCw } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import type { ChartOption } from '@/types/api';

interface ChartRendererProps {
  option: ChartOption | unknown;
  height?: string;
}

export function ChartRenderer({ option, height = '100%' }: ChartRendererProps) {
  const { t } = useTranslation();
  const chartRef = useRef<ReactECharts>(null);
  const [isFullscreen, setIsFullscreen] = useState(false);

  // Validate chart option
  const validatedOption = (() => {
    if (!option || typeof option !== 'object') return null;
    const opt = option as Record<string, unknown>;

    // Must have series or dataset
    if (!opt.series && !opt.dataset) {
      return null;
    }

    return opt;
  })();

  // Apply dark mode adaptive theme
  const themeOverrides = {
    backgroundColor: 'transparent',
    textStyle: {
      color: 'var(--foreground, #1f2937)',
      fontFamily: 'Inter, system-ui, -apple-system, sans-serif',
      fontSize: 14,
    },
    // Modern color palette
    color: [
      '#3b82f6', // blue-500
      '#10b981', // emerald-500
      '#f59e0b', // amber-500
      '#ef4444', // red-500
      '#8b5cf6', // violet-500
      '#ec4899', // pink-500
      '#6366f1', // indigo-500
      '#14b8a6', // teal-500
    ],
    animation: true,
    animationDuration: 1000,
    animationEasing: 'cubicOut',
    grid: {
      top: 40,
      right: 20,
      bottom: 40,
      left: 20,
      containLabel: true
    }
  };

  const mergedOption = validatedOption ? { ...themeOverrides, ...validatedOption } : null;

  // Calculate error state based on validated option
  const hasError = !validatedOption;
  const errorMsg = hasError ? t('chart.error') : '';

  // Toggle fullscreen
  const toggleFullscreen = useCallback(() => {
    setIsFullscreen(prev => !prev);
  }, []);

  // Download chart as image
  const downloadChart = useCallback(() => {
    const chart = chartRef.current?.getEchartsInstance();
    if (chart) {
      const url = chart.getDataURL({
        type: 'png',
        pixelRatio: 2,
        backgroundColor: '#ffffff',
      });
      const link = document.createElement('a');
      link.download = `chart-${Date.now()}.png`;
      link.href = url;
      link.click();
    }
  }, []);

  // Refresh/resize chart
  const refreshChart = useCallback(() => {
    const chart = chartRef.current?.getEchartsInstance();
    if (chart) {
      chart.resize();
    }
  }, []);

  // Handle ESC key for fullscreen
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isFullscreen) {
        setIsFullscreen(false);
      }
    };
    if (isFullscreen) {
      document.addEventListener('keydown', handleKeyDown);
      return () => document.removeEventListener('keydown', handleKeyDown);
    }
  }, [isFullscreen]);

  if (hasError || !mergedOption) {
    return (
      <div className="w-full h-full flex items-center justify-center text-muted-foreground text-sm">
        <div className="text-center space-y-2">
          <RefreshCw size={20} className="mx-auto opacity-40" />
          <p className="opacity-60">{errorMsg || t('chart.renderError')}</p>
        </div>
      </div>
    );
  }

  const chartContent = (
    <div className={`relative group ${isFullscreen ? 'fixed inset-0 z-50 bg-background/95 backdrop-blur-sm p-8' : 'w-full h-full'}`}>
      {/* Toolbar */}
      <div className="absolute top-2 right-2 z-10 flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
        <button
          onClick={refreshChart}
          className="p-1.5 rounded-md bg-muted/80 hover:bg-muted text-muted-foreground hover:text-foreground transition-colors backdrop-blur-sm"
          title={t('chart.refresh')}
        >
          <RefreshCw size={14} />
        </button>
        <button
          onClick={downloadChart}
          className="p-1.5 rounded-md bg-muted/80 hover:bg-muted text-muted-foreground hover:text-foreground transition-colors backdrop-blur-sm"
          title={t('chart.download')}
        >
          <Download size={14} />
        </button>
        <button
          onClick={toggleFullscreen}
          className="p-1.5 rounded-md bg-muted/80 hover:bg-muted text-muted-foreground hover:text-foreground transition-colors backdrop-blur-sm"
          title={isFullscreen ? t('chart.exitFullscreen') : t('chart.fullscreen')}
        >
          {isFullscreen ? <Minimize2 size={14} /> : <Maximize2 size={14} />}
        </button>
      </div>

      {/* Fullscreen close overlay */}
      {isFullscreen && (
        <button
          onClick={toggleFullscreen}
          className="absolute top-4 left-4 z-20 px-3 py-1.5 rounded-lg bg-muted text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          {t('chart.fullscreenTip')}
        </button>
      )}

      <ReactECharts
        ref={chartRef}
        option={mergedOption}
        style={{ height: isFullscreen ? 'calc(100vh - 4rem)' : height, width: '100%' }}
        opts={{ renderer: 'canvas' }}
        notMerge={true}
        lazyUpdate={true}
        onEvents={{
          // Enable click interaction
          click: (params: { name?: string; value?: unknown; seriesName?: string }) => {
            console.log('Chart clicked:', params.name, params.value, params.seriesName);
          }
        }}
      />
    </div>
  );

  return (
    <div className="w-full h-full" role="img" aria-label={t('chart.ariaLabel')}>
      {chartContent}
    </div>
  );
}
