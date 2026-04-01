
import { Moon, Sun, Laptop, Palette } from "lucide-react";
import { useChatSettingsStore } from "@/store/chat-settings-store";
import { useThemeStore } from "@/store/theme-store";
import { useSettingsData } from "@/hooks/useSettingsData";
import { DbConnectionManager } from "./settings/DbConnectionManager";
import { LlmConfigManager } from "./settings/LlmConfigManager";
import { useTranslation } from "react-i18next";

export function SidebarSettings() {
    const { t } = useTranslation();
    const { theme, setTheme } = useThemeStore();
    const { 
        selectedConnectionId, 
        selectedLlmConfigId, 
        setSelectedConnectionId, 
        setSelectedLlmConfigId 
    } = useChatSettingsStore();

    const { connections, llmConfigs, fetchData } = useSettingsData();

    return (
        <div className="flex flex-col space-y-6 pb-20 p-2">
           {/* Appearance */}
           <div className="space-y-2">
                <div className="flex items-center justify-between">
                    <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider flex items-center gap-1">
                        <Palette size={12} />
                        {t('settings.appearance')}
                    </label>
                </div>
                <div className="grid grid-cols-3 gap-2 p-1 bg-muted/50 dark:bg-zinc-900/50 rounded-xl border border-border dark:border-zinc-800">
                    {(['light', 'dark', 'system'] as const).map((mode) => (
                        <button
                            key={mode}
                            onClick={() => setTheme(mode)}
                            className={`
                                flex items-center justify-center gap-2 px-3 py-2 text-sm font-medium rounded-lg transition-all
                                ${theme === mode 
                                    ? "bg-background dark:bg-zinc-800 text-foreground dark:text-gray-100 shadow-sm ring-1 ring-border dark:ring-zinc-700" 
                                    : "text-muted-foreground dark:text-zinc-400 hover:text-foreground dark:hover:text-gray-200 hover:bg-background/50 dark:hover:bg-zinc-800/50"}
                            `}
                            aria-label={t(`settings.theme.${mode}`)}
                            aria-pressed={theme === mode}
                        >
                            {mode === 'light' && <Sun size={16} />}
                            {mode === 'dark' && <Moon size={16} />}
                            {mode === 'system' && <Laptop size={16} />}
                            <span className="capitalize">{t(`settings.theme.${mode}`)}</span>
                        </button>
                    ))}
                </div>
           </div>

            {/* Database Connection */}
            <DbConnectionManager 
                connections={connections}
                selectedId={selectedConnectionId}
                onSelect={setSelectedConnectionId}
                onUpdate={fetchData}
            />

            {/* LLM Configuration */}
            <LlmConfigManager 
                configs={llmConfigs}
                selectedId={selectedLlmConfigId}
                onSelect={setSelectedLlmConfigId}
                onUpdate={fetchData}
            />
        </div>
    );
}
