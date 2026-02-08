import { ChevronDown, Database, Cpu } from "lucide-react";
import { useEffect, useState } from "react";
import { useChatSettingsStore } from "@/store/chat-settings-store";
import { connectionService } from "@/services/connection-service";
import { llmService } from "@/services/llm-service";
import type { DbConnection, LlmConfig } from "@/types/api";
import { DbConnectionManager } from "./settings/DbConnectionManager";
import { LlmConfigManager } from "./settings/LlmConfigManager";
import { useTranslation } from "react-i18next";

export function SidebarSettings() {
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
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    return (
        <div className="flex flex-col space-y-6 pb-20 p-2">
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
        </div>
    );
}
