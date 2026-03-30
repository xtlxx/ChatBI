import { useState, useEffect } from "react";
import { Outlet, useNavigate } from "react-router-dom";
import { Sidebar } from "./components/Sidebar";
import { useThemeEffect } from "./hooks/useThemeEffect";

type SidebarView = 'nav' | 'settings';

function App() {
  const [isLeftSidebarOpen, setIsLeftSidebarOpen] = useState(true);
  const [sidebarView, setSidebarView] = useState<SidebarView>('nav');
  const navigate = useNavigate();
  
  useThemeEffect();

  useEffect(() => {
    const handleAuthExpired = () => {
      navigate('/login');
    };
    window.addEventListener('unauthorized', handleAuthExpired as EventListener);
    return () => {
      window.removeEventListener('unauthorized', handleAuthExpired as EventListener);
    };
  }, [navigate]);

  return (
    <div className="flex h-screen bg-background overflow-hidden relative">
      {/* 左侧边栏 */}
      <div 
        className={`
          transition-all duration-300 ease-in-out border-r bg-white z-20
          ${isLeftSidebarOpen ? "w-80 translate-x-0" : "w-0 -translate-x-full md:w-0 md:translate-x-0 overflow-hidden opacity-0 md:opacity-100"}
          absolute md:relative h-full
        `}
      >
        <div className="w-80 h-full">
           <Sidebar view={sidebarView} onViewChange={setSidebarView} />
        </div>
      </div>

      {/* 主内容区域 */}
      <div className="flex-1 flex flex-col min-w-0 h-full relative z-10">
        <Outlet context={{ 
            isLeftSidebarOpen, 
            setIsLeftSidebarOpen,
            sidebarView,
            setSidebarView
        }} />
      </div>
      
      {/* 遮罩层 */}
      {isLeftSidebarOpen && (
        <div 
            className="md:hidden fixed inset-0 bg-black/20 z-10"
            onClick={() => setIsLeftSidebarOpen(false)} 
        />
      )}
    </div>
  );
}

export default App;
