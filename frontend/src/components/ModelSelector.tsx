import { useRef, useState } from "react";
import { ChevronDown, Settings, Check } from "lucide-react";
import { useChatSettingsStore } from "@/store/chat-settings-store";
import { useSettingsData } from "@/hooks/useSettingsData";
import { useTranslation } from "react-i18next";
import { useOutsideClick } from "@/hooks/useOutsideClick";

interface ModelSelectorProps {
    onOpenSettings: () => void;
}

export function ModelSelector({ onOpenSettings }: ModelSelectorProps) {
    const { t } = useTranslation();
    const { selectedLlmConfigId, setSelectedLlmConfigId } = useChatSettingsStore();
    const { llmConfigs } = useSettingsData();
    const [isOpen, setIsOpen] = useState(false);
    const ref = useRef<HTMLDivElement>(null);

    useOutsideClick(ref, () => setIsOpen(false));

    const selectedConfig = llmConfigs.find(c => c.id === selectedLlmConfigId);

    const handleSelect = (id: number) => {
        setSelectedLlmConfigId(id);
        setIsOpen(false);
    };

    return ( 
        <div className="relative" ref={ref}> 
            <button 
                onClick={() => setIsOpen(!isOpen)}
                className="flex items-center gap-2 px-4 py-2 rounded-full bg-white dark:bg-zinc-900 border border-black/5 dark:border-white/5 text-zinc-700 dark:text-zinc-300 hover:text-zinc-900 dark:hover:text-white hover:bg-zinc-50 dark:hover:bg-zinc-800 transition-all text-xs font-medium shadow-sm dark:shadow-none"
            > 
                <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" /> 
                <span className="max-w-[100px] md:max-w-[150px] truncate">{selectedConfig?.model_name || 'Select Model'}</span> 
                <ChevronDown size={14} className="opacity-40" /> 
            </button> 
            
            {/* 下拉菜单：增加 Blur 和 Zoom 动画 */} 
            {isOpen && ( 
                <div className="absolute top-full mt-2 w-64 glass-effect rounded-2xl shadow-2xl border border-black/5 dark:border-white/10 p-2 animate-in zoom-in-95 duration-200 z-50 origin-top-left bg-white/90 dark:bg-zinc-950/90"> 
                    <div className="p-1 max-h-60 overflow-y-auto">
                        <div className="px-2 py-1.5 text-[10px] font-bold text-zinc-500 uppercase tracking-wider">
                            {t('settings.model')}
                        </div>

                        {llmConfigs.length === 0 ? (
                            <div className="px-2 py-3 text-center text-sm text-zinc-500">
                                {t('settings.llm.noConfigurations')}
                            </div>
                        ) : (
                            llmConfigs.map(config => (
                                <button
                                    key={config.id}
                                    onClick={() => handleSelect(config.id)}
                                    className={`
                                        w-full text-left flex items-center justify-between px-3 py-2 rounded-xl text-sm transition-colors
                                        ${selectedLlmConfigId === config.id
                                            ? "bg-black/5 dark:bg-white/10 text-zinc-900 dark:text-white"
                                            : "hover:bg-black/5 dark:hover:bg-white/5 text-zinc-600 dark:text-zinc-300 hover:text-zinc-900 dark:hover:text-white"}
                                    `}
                                >
                                    <div className="flex flex-col truncate">
                                        <span className="font-medium truncate">{config.model_name}</span>
                                        <span className="text-[10px] opacity-50 truncate">{config.provider}</span>
                                    </div>
                                    {selectedLlmConfigId === config.id && <Check size={14} className="text-emerald-500 dark:text-emerald-400" />}
                                </button>
                            ))
                        )}
                    </div>

                    <div className="p-1 border-t border-black/5 dark:border-white/10 mt-1">
                        <button
                            onClick={() => {
                                setIsOpen(false);
                                onOpenSettings();
                            }}
                            className="w-full flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-medium text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-200 hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
                        >
                            <Settings size={14} />
                            {t('settings.manage')}
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
}
