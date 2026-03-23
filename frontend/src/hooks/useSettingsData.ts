import { useState, useCallback, useEffect } from "react";
import { connectionService } from "@/services/connection-service";
import { llmService } from "@/services/llm-service";
import { useChatSettingsStore } from "@/store/chat-settings-store";
import type { DbConnection, LlmConfig } from "@/types/api";

export function useSettingsData() {
    const [connections, setConnections] = useState<DbConnection[]>([]);
    const [llmConfigs, setLlmConfigs] = useState<LlmConfig[]>([]);
    const [isLoading, setIsLoading] = useState(false);
    
    const { 
        selectedConnectionId, 
        selectedLlmConfigId, 
        setSelectedConnectionId, 
        setSelectedLlmConfigId 
    } = useChatSettingsStore();

    const fetchData = useCallback(async () => {
        try {
            setIsLoading(true);
            const [conns, llms] = await Promise.all([
                connectionService.getAll(),
                llmService.getAll()
            ]);
            setConnections(conns);
            setLlmConfigs(llms);
        } catch (error) {
            console.error("Failed to fetch settings data", error);
        } finally {
            setIsLoading(false);
        }
    }, []);

    // Set default selections
    useEffect(() => {
        if (!selectedConnectionId && connections.length > 0) {
            setSelectedConnectionId(connections[0].id);
        }
        if (!selectedLlmConfigId && llmConfigs.length > 0) {
            setSelectedLlmConfigId(llmConfigs[0].id);
        }
    }, [connections, llmConfigs, selectedConnectionId, selectedLlmConfigId, setSelectedConnectionId, setSelectedLlmConfigId]);

    // Initial fetch
    useEffect(() => {
        void fetchData();
    }, [fetchData]);

    return {
        connections,
        llmConfigs,
        fetchData,
        isLoading
    };
}
