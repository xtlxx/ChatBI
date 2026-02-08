import { Info, ChevronDown, X, Database, Cpu } from "lucide-react";
import * as Switch from "@radix-ui/react-switch";
import { useEffect, useState } from "react";
import { useChatSettingsStore } from "@/store/chat-settings-store";
import { connectionService } from "@/services/connection-service";
import { llmService } from "@/services/llm-service";
import type { DbConnection, LlmConfig } from "@/types/api";
import { DbConnectionManager } from "./settings/DbConnectionManager";
import { LlmConfigManager } from "./settings/LlmConfigManager";
import { useTranslation } from "react-i18next";

interface SettingsPanelProps {
    onClose?: () => void;
}

export function SettingsPanel({ onClose }: SettingsPanelProps) {
    const { t } = useTranslation();
    const { 
        selectedConnectionId, 
        selectedLlmConfigId, 
        setSelectedConnectionId, 
        setSelectedLlmConfigId 
    } = useChatSettingsStore();

    const [connections, setConnections] = useState<DbConnection[]>([]);
    const [llmConfigs, setLlmConfigs] = useState<LlmConfig[]>([]);

    const fetchData = async () => {
        try {
            const [conns, llms] = await Promise.all([
                connectionService.getAll(),
                llmService.getAll()
            ]);
            setConnections(conns);
            setLlmConfigs(llms);

            // Set default selections if none
            if (!selectedConnectionId && conns.length > 0) {
                setSelectedConnectionId(conns[0].id);
            }
            if (!selectedLlmConfigId && llms.length > 0) {
                setSelectedLlmConfigId(llms[0].id);
            }
        } catch (error) {
            console.error("Failed to fetch settings data", error);
            // toast.error("Failed to load settings options"); 
            // Avoid annoying toast on initial load if just one fails or auth issue
        }
    };

    // Re-fetch when panel is opened (mounted)
    useEffect(() => {
        fetchData();
    }, []);

    // Also allow managers to trigger refresh - for now we just poll or refresh on mount
    // Ideally we would have a query client like TanStack Query, but simple state is fine.
    
    return (
    <div className="w-full h-full flex flex-col bg-background overflow-y-auto">
      <div className="p-4 space-y-6 pb-20">
         {/* Mobile Close Button */}
         <div className="md:hidden flex justify-end mb-2">
            <button onClick={onClose} className="p-2 text-muted-foreground hover:bg-accent hover:text-accent-foreground rounded-md transition-colors" aria-label={t('common.close')}>
                <X size={20} />
            </button>
         </div>

        {/* Database Connection Selection */}
        <div className="space-y-2">
            <div className="flex items-center justify-between">
                 <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider flex items-center gap-1">
                    <Database size={12} />
                    {t('settings.database')}
                </label>
                <DbConnectionManager onUpdate={fetchData} />
            </div>
            
            <div className="relative">
                <select 
                    className="w-full appearance-none bg-background border border-input rounded-md px-3 py-2 pr-8 text-sm font-medium text-foreground hover:border-ring focus:outline-none focus:ring-2 focus:ring-ring transition-shadow cursor-pointer"
                    value={selectedConnectionId || ''}
                    onChange={(e) => setSelectedConnectionId(Number(e.target.value) || null)}
                    aria-label={t('settings.selectDatabase')}
                >
                    <option value="" disabled>{t('settings.selectDatabase')}</option>
                    {connections.map(conn => (
                        <option key={conn.id} value={conn.id}>{conn.name} ({conn.type})</option>
                    ))}
                </select>
                <ChevronDown className="absolute right-3 top-2.5 text-muted-foreground pointer-events-none" size={16} />
            </div>
        </div>

        {/* Model Selection */}
        <div className="space-y-2">
             <div className="flex items-center justify-between">
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider flex items-center gap-1">
                    <Cpu size={12} />
                    {t('settings.model')}
                </label>
                <LlmConfigManager onUpdate={fetchData} />
            </div>
            <div className="relative">
                <select 
                    className="w-full appearance-none bg-background border border-input rounded-md px-3 py-2 pr-8 text-sm font-medium text-foreground hover:border-ring focus:outline-none focus:ring-2 focus:ring-ring transition-shadow cursor-pointer"
                    value={selectedLlmConfigId || ''}
                    onChange={(e) => setSelectedLlmConfigId(Number(e.target.value) || null)}
                    aria-label={t('settings.selectModel')}
                >
                    <option value="" disabled>{t('settings.selectModel')}</option>
                     {llmConfigs.map(cfg => (
                        <option key={cfg.id} value={cfg.id}>{cfg.provider} / {cfg.model_name}</option>
                    ))}
                </select>
                <ChevronDown className="absolute right-3 top-2.5 text-muted-foreground pointer-events-none" size={16} />
            </div>
        </div>

        <div className="h-px bg-border"></div>

        {/* System Instructions */}
        <div className="space-y-2">
            <div className="flex items-center justify-between">
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">{t('settings.systemInstructions')}</label>
                <button className="text-muted-foreground hover:text-foreground transition-colors" aria-label="Info">
                     <Info size={14} />
                </button>
            </div>
            <textarea 
                className="w-full h-32 border border-input rounded-md p-3 text-sm resize-none focus:outline-none focus:ring-2 focus:ring-ring transition-shadow placeholder:text-muted-foreground font-mono bg-muted/30 text-foreground"
                placeholder={t('settings.systemInstructionsPlaceholder')}
                aria-label={t('settings.systemInstructions')}
            />
        </div>

        <div className="h-px bg-border"></div>

        {/* Tools */}
        <div className="space-y-4">
            <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">{t('settings.tools')}</label>
            
            <ToolToggle label={t('settings.toolsStructuredOutputs')} defaultChecked />
            <ToolToggle label={t('settings.toolsCodeExecution')} defaultChecked />
            <ToolToggle label={t('settings.toolsFunctionCalling')} />
            <ToolToggle label={t('settings.toolsGrounding')} />
        </div>
        
      </div>
    </div>
  );
}

function ToolToggle({ label, defaultChecked }: { label: string; defaultChecked?: boolean }) {
    return (
        <div className="flex items-center justify-between group">
            <label className="text-sm text-foreground group-hover:text-foreground/80 transition-colors cursor-pointer">{label}</label>
            <Switch.Root
                className="w-[36px] h-[20px] bg-input rounded-full relative shadow-inner focus:shadow-[0_0_0_2px] focus:shadow-ring data-[state=checked]:bg-primary outline-none cursor-pointer transition-colors"
                defaultChecked={defaultChecked}
                aria-label={label}
            >
                <Switch.Thumb className="block w-[16px] h-[16px] bg-background rounded-full shadow-[0_2px_2px] shadow-black/10 transition-transform duration-100 translate-x-0.5 will-change-transform data-[state=checked]:translate-x-[18px]" />
            </Switch.Root>
        </div>
    )
}
