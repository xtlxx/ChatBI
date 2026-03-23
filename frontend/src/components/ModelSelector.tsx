import { useRef, useState } from "react";
import { Cpu, ChevronDown, Settings, Check } from "lucide-react";
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
                className={`
                    flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-medium transition-all
                    ${isOpen
                        ? "bg-primary/10 text-primary ring-1 ring-primary/20"
                        : "bg-muted/50 text-muted-foreground hover:bg-muted hover:text-foreground"}
                `}
                title={t('settings.model')}
            >
                <Cpu size={14} className={selectedLlmConfigId ? "text-primary" : ""} />
                <span className="max-w-[100px] md:max-w-[150px] truncate">
                    {selectedConfig
                        ? `${selectedConfig.model_name}`
                        : t('settings.selectModel') || "Select Model"}
                </span>
                <ChevronDown size={12} className={`transition-transform duration-200 ${isOpen ? "rotate-180" : ""}`} />
            </button>

            {isOpen && (
                <div className="absolute top-full left-0 mt-2 w-64 bg-popover border border-border rounded-xl shadow-lg z-50 overflow-hidden animate-in fade-in zoom-in-95 duration-200 origin-top-left">
                    <div className="p-1 max-h-60 overflow-y-auto">
                        <div className="px-2 py-1.5 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                            {t('settings.model')}
                        </div>

                        {llmConfigs.length === 0 ? (
                            <div className="px-2 py-3 text-center text-sm text-muted-foreground">
                                {t('settings.llm.noConfigurations')}
                            </div>
                        ) : (
                            llmConfigs.map(config => (
                                <button
                                    key={config.id}
                                    onClick={() => handleSelect(config.id)}
                                    className={`
                                        w-full text-left flex items-center justify-between px-2 py-2 rounded-lg text-sm transition-colors
                                        ${selectedLlmConfigId === config.id
                                            ? "bg-primary/10 text-primary"
                                            : "hover:bg-muted text-foreground"}
                                    `}
                                >
                                    <div className="flex flex-col truncate">
                                        <span className="font-medium truncate">{config.model_name}</span>
                                        <span className="text-[10px] opacity-70 truncate">{config.provider}</span>
                                    </div>
                                    {selectedLlmConfigId === config.id && <Check size={14} />}
                                </button>
                            ))
                        )}
                    </div>

                    <div className="p-1 border-t border-border bg-muted/20">
                        <button
                            onClick={() => {
                                setIsOpen(false);
                                onOpenSettings();
                            }}
                            className="w-full flex items-center gap-2 px-2 py-2 rounded-lg text-xs font-medium text-muted-foreground hover:text-primary hover:bg-primary/5 transition-colors"
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
