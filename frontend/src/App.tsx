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
    <div 
      className={`grid h-screen bg-background overflow-hidden relative transition-[grid-template-columns] duration-300 ease-in-out ${
        isLeftSidebarOpen ? 'grid-cols-1 md:grid-cols-[20rem_1fr]' : 'grid-cols-1 md:grid-cols-[0px_1fr]'
      }`}
    >
      {/* 左侧边栏 */}
      <div 
        className={`
          border-r border-border bg-background z-20 overflow-hidden
          ${isLeftSidebarOpen ? "translate-x-0 w-80 md:w-full" : "-translate-x-full md:translate-x-0 w-0 md:w-full"}
          absolute md:relative h-full transition-transform duration-300 ease-in-out md:transition-none
        `}
      >
        <div className="w-80 h-full">
           <Sidebar view={sidebarView} onViewChange={setSidebarView} />
        </div>
      </div>

      {/* 主内容区域 */}
      <div className="flex flex-col min-w-0 h-full relative z-10">
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
