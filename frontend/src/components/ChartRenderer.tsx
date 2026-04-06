import { useRef, useEffect, useState, useCallback, useMemo } from 'react';
import ReactECharts from 'echarts-for-react';
import { Maximize2, Minimize2, Download, RefreshCw } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useThemeStore } from '@/store/theme-store'; // 引入主题 Store
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

  // 获取当前主题
  const { theme } = useThemeStore();
  
  // 计算实际传给 ECharts 的主题（处理 system 逻辑）
  const actualTheme = useMemo(() => {
    if (theme === 'system') {
      return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }
    return theme;
  }, [theme]);

  // 严格验证图表配置，防止 ECharts 内部抛出异常导致白屏
  const validatedOption = useMemo(() => {
    if (!option || typeof option !== 'object') return null;
    const opt = option as ChartOption;

    // ECharts 核心要求：必须有 series 且必须是数组（除非使用了 dataset）
    const hasValidSeries = Array.isArray(opt.series) && opt.series.length > 0;
    const hasValidDataset = opt.dataset !== undefined;

    if (!hasValidSeries && !hasValidDataset) {
      return null;
    }

    return opt;
  }, [option]);

  // 简化 mergedOption，让 ECharts 的 theme 接管颜色，只保留基础布局配置
  const mergedOption = useMemo(() => {
    if (!validatedOption) return null;
    return {
      backgroundColor: 'transparent', // 保持透明以适应外层容器的圆角和背景
      animation: true,
      animationDuration: 1000,
      animationEasing: 'cubicOut',
      grid: { top: 40, right: 20, bottom: 40, left: 20, containLabel: true },
      ...validatedOption
    };
  }, [validatedOption]);

  const hasError = !validatedOption;
  const errorMsg = hasError ? t('chart.error') : '';

  // 切换全屏 (增加跨浏览器兼容)
  const toggleFullscreen = useCallback(() => {
    const elem = containerRef.current as any;
    if (!document.fullscreenElement && !((document as any).webkitFullscreenElement)) {
      if (elem?.requestFullscreen) elem.requestFullscreen();
      else if (elem?.webkitRequestFullscreen) elem.webkitRequestFullscreen();
    } else {
      if (document.exitFullscreen) document.exitFullscreen();
      else if ((document as any).webkitExitFullscreen) (document as any).webkitExitFullscreen();
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

  // 使用 ResizeObserver 实现图表的响应式渲染，增加防抖 (Debounce)
  useEffect(() => {
    if (!containerRef.current) return;

    let timeoutId: ReturnType<typeof setTimeout>;

    const resizeObserver = new ResizeObserver(() => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => {
        requestAnimationFrame(() => {
          refreshChart();
        });
      }, 150); // 150ms 防抖
    });

    // 只监听容器宽度的变化，避免不必要的触发
    resizeObserver.observe(containerRef.current);
    
    return () => {
      clearTimeout(timeoutId);
      resizeObserver.disconnect();
    };
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
        theme={actualTheme} // 👈 关键：直接传入 'dark' 或 'light'
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
