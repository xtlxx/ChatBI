// frontend/src/workers/audio-worker.ts

// 监听主线程发来的消息
self.onmessage = async (e: MessageEvent) => {
    try {
        const { audioBuffer } = e.data;

        // 这里接收到的 audioBuffer 是一个 Float32Array 的通道数据
        const channelData = new Float32Array(audioBuffer);
        
        // 转换为 Int16Array PCM 数据
        const pcmData = new Int16Array(channelData.length);
        for (let i = 0; i < channelData.length; i++) {
            let s = Math.max(-1, Math.min(1, channelData[i]));
            pcmData[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
        }

        // 创建 Blob 并返回给主线程
        const pcmBlob = new Blob([pcmData], { type: 'audio/pcm' });
        
        self.postMessage({ success: true, blob: pcmBlob });
    } catch (error) {
        self.postMessage({ 
            success: false, 
            error: error instanceof Error ? error.message : '音频转换过程中出现未知错误'
        });
    }
};
