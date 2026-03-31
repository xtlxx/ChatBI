import { useRef, useEffect, useState, useCallback, useMemo } from 'react';
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
  const containerRef = useRef<HTMLDivElement>(null);
  const [isFullscreen, setIsFullscreen] = useState(false);

  // 验证图表配置
  const validatedOption = useMemo(() => {
    if (!option || typeof option !== 'object') return null;
    const opt = option as Record<string, unknown>;

    // 图表配置必须包含 series 或 dataset 中的一个
    if (!opt.series && !opt.dataset) {
      return null;
    }

    return opt;
  }, [option]);

  const mergedOption = useMemo(() => {
    if (!validatedOption) return null;
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
    return { ...themeOverrides, ...validatedOption };
  }, [validatedOption]);

  // 根据已验证的图表配置计算错误状态
  const hasError = !validatedOption;
  const errorMsg = hasError ? t('chart.error') : '';

  // 切换全屏
  const toggleFullscreen = useCallback(() => {
    if (!document.fullscreenElement) {
      containerRef.current?.requestFullscreen().catch(err => {
        console.error(`Error attempting to enable fullscreen: ${err.message}`);
      });
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      }
    }
  }, []);

  // 下载图表为图片
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

  // 刷新/调整图表尺寸
  const refreshChart = useCallback(() => {
    const chart = chartRef.current?.getEchartsInstance();
    if (chart) {
      chart.resize();
    }
  }, []);

  // 使用 ResizeObserver 实现图表的响应式渲染
  useEffect(() => {
    if (!containerRef.current) return;

    const resizeObserver = new ResizeObserver(() => {
      // 添加一个小延迟，确保 DOM 更新完成后再调整尺寸
      requestAnimationFrame(() => {
        refreshChart();
      });
    });

    resizeObserver.observe(containerRef.current);
    return () => resizeObserver.disconnect();
  }, [refreshChart]);

  // 处理全屏变化
  useEffect(() => {
    const handleFullscreenChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
      setTimeout(() => {
        refreshChart();
      }, 100);
    };
    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, [refreshChart]);

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
    <div 
      ref={containerRef}
      className={`relative group w-full h-full ${isFullscreen ? 'bg-background p-8' : ''}`}
    >
      {/* 图表工具栏（仅在非全屏下显示） */}
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

      {/* 全屏关闭遮罩提示 */}
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
          // 启用点击交互
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
