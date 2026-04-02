import { Component, ErrorInfo, ReactNode } from "react";
import { AlertCircle, RefreshCcw } from "lucide-react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = { hasError: false, error: null };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("React Rendering Error:", error, errorInfo);
  }

  private handleRetry = () => {
    this.setState({ hasError: false, error: null });
    window.location.reload(); // 简单处理：刷新页面
  };

  public render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="flex flex-col items-center justify-center p-8 m-4 border-2 border-dashed border-destructive/20 rounded-2xl bg-destructive/5 text-center">
          <AlertCircle className="text-destructive mb-4" size={48} />
          <h3 className="text-lg font-semibold mb-2">渲染遇到一点问题</h3>
          <p className="text-sm text-muted-foreground mb-6 max-w-xs">
            由于数据异常或图表兼容性问题，该区域显示失败。
          </p>
          
          {/* 保留错误详情，方便开发调试，使用 shadcn 风格样式 */}
          <div className="bg-background p-4 rounded-md text-left overflow-auto max-h-32 mb-6 w-full max-w-md border">
             <code className="text-xs text-destructive break-all">
               {this.state.error?.message || 'Unknown Error'}
             </code>
          </div>

          <button
            onClick={this.handleRetry}
            className="flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-full hover:opacity-90 transition-all"
          >
            <RefreshCcw size={16} /> 重试
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}
