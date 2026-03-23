import React, { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { X, Maximize2, Minimize2 } from 'lucide-react';

interface SettingsPopoverProps {
  isOpen: boolean;
  onClose: () => void;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  triggerRef: React.RefObject<any>;
  children: React.ReactNode;
  title?: string;
}

export function SettingsPopover({ isOpen, onClose, triggerRef, children, title }: SettingsPopoverProps) {
  const popoverRef = useRef<HTMLDivElement>(null);
  const [position, setPosition] = useState<{ top?: number; left?: number; bottom?: number }>({});
  const [isMaximized, setIsMaximized] = useState(false);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      const target = event.target as Element;
      
      // Check if click is inside a dialog (e.g. Radix UI Modal) or other portal content
      if (target.closest('[role="dialog"]') || target.closest('[data-radix-popper-content-wrapper]')) {
        return;
      }

      if (
        popoverRef.current && 
        !popoverRef.current.contains(target) &&
        triggerRef.current &&
        !triggerRef.current.contains(target)
      ) {
        onClose();
      }
    };

    const updatePosition = () => {
      if (!triggerRef.current) return;
      
      const rect = triggerRef.current.getBoundingClientRect();
      const viewportHeight = window.innerHeight;
      
      // Default: Show to the right of the sidebar
      const left = rect.right + 12; // 12px gap
      
      // Try to align bottom with trigger bottom
      // But ensure it doesn't go off top
      const popoverHeight = 400; // Estimated height
      
      const bottom = viewportHeight - rect.bottom;
      
      // If aligning bottom pushes top off screen, align top instead
      if (viewportHeight - bottom - popoverHeight < 0) {
          // Align top with trigger top
          setPosition({
              left,
              top: rect.top,
          });
      } else {
          // Align bottom with trigger bottom
          setPosition({
              left,
              bottom,
          });
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      updatePosition();
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen, onClose, triggerRef]);

  if (!isOpen) return null;

  const maximizedStyle: React.CSSProperties = {
    position: 'fixed',
    top: '20px',
    left: '20px',
    right: '20px',
    bottom: '20px',
    zIndex: 50,
    width: 'auto',
    height: 'auto',
    maxHeight: 'none'
  };

  const normalStyle: React.CSSProperties = {
    position: 'fixed',
    zIndex: 50,
    maxHeight: '80vh',
    ...position
  };

  return createPortal(
    <>
      {isMaximized && (
        <div className="fixed inset-0 bg-background/80 backdrop-blur-sm z-40 animate-in fade-in duration-200" />
      )}
      <div 
        ref={popoverRef}
        style={isMaximized ? maximizedStyle : normalStyle}
        className={`${isMaximized ? 'w-auto' : 'w-[320px]'} bg-background border border-border rounded-xl shadow-xl flex flex-col animate-in fade-in zoom-in-95 ${!isMaximized ? 'slide-in-from-left-2' : ''} duration-200 overflow-hidden transition-all`}
      >
        {title && (
          <div className="flex items-center justify-between px-4 py-3 border-b border-border bg-muted/30">
            <h3 className="font-semibold text-sm">{title}</h3>
            <div className="flex items-center gap-1">
              <button 
                onClick={() => setIsMaximized(!isMaximized)}
                className="text-muted-foreground hover:text-foreground p-1 rounded-md hover:bg-muted transition-colors"
                title={isMaximized ? "Restore" : "Maximize"}
              >
                {isMaximized ? <Minimize2 size={16} /> : <Maximize2 size={16} />}
              </button>
              <button 
                onClick={onClose}
                className="text-muted-foreground hover:text-foreground p-1 rounded-md hover:bg-muted transition-colors"
              >
                <X size={16} />
              </button>
            </div>
          </div>
        )}
        <div className="flex-1 overflow-y-auto custom-scrollbar">
          {children}
        </div>
      </div>
    </>,
    document.body
  );
}
