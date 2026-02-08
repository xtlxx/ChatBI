import * as Dialog from '@radix-ui/react-dialog';
import { X } from 'lucide-react';
import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: ReactNode;
  description?: string;
}

export function Modal({ isOpen, onClose, title, children, description }: ModalProps) {
  const { t } = useTranslation();
  return (
    <Dialog.Root open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-background/80 backdrop-blur-sm data-[state=open]:animate-overlayShow fixed inset-0 z-50" />
        <Dialog.Content className="fixed left-[50%] top-[50%] max-h-[85vh] w-[90vw] max-w-[500px] translate-x-[-50%] translate-y-[-50%] rounded-[6px] bg-background p-[25px] shadow-lg border border-border focus:outline-none z-50 data-[state=open]:animate-contentShow overflow-y-auto">
          <Dialog.Title className="text-foreground m-0 text-[17px] font-medium mb-2">
            {title}
          </Dialog.Title>
          {description && (
             <Dialog.Description className="text-muted-foreground text-sm mb-4">
                {description}
             </Dialog.Description>
          )}
          
          {children}

          <Dialog.Close asChild>
            <button
              className="text-muted-foreground hover:bg-accent hover:text-accent-foreground absolute top-[10px] right-[10px] inline-flex h-[25px] w-[25px] appearance-none items-center justify-center rounded-full focus:shadow-[0_0_0_2px] focus:shadow-ring focus:outline-none transition-colors"
              aria-label={t('common.close')}
              onClick={onClose}
            >
              <X size={16} />
            </button>
          </Dialog.Close>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
