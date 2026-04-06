export interface LayoutContext {
    isLeftSidebarOpen: boolean;
    setIsLeftSidebarOpen: (v: boolean) => void;
    sidebarView: 'nav' | 'settings';
    setSidebarView: (v: 'nav' | 'settings') => void;
}
