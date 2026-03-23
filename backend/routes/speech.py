from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
import logging
from utils.xunfei import XunfeiSpeechRecognition
from utils.jwt_auth import get_current_user_id

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/speech", tags=["Speech"])

@router.post("/recognize")
async def recognize_speech(
    audio: UploadFile = File(...),
    current_user_id: int = Depends(get_current_user_id)
):
    """
    将音频文件转换为文本 (使用讯飞接口)
    音频格式要求: PCM, 16k采样率, 16位, 单声道
    """
    try:
        audio_data = await audio.read()
        
        recognizer = XunfeiSpeechRecognition()
        text = await recognizer.recognize(audio_data)
        
        return {"success": True, "text": text}
    except ValueError as ve:
        logger.error(f"Configuration error: {ve}")
        raise HTTPException(status_code=500, detail="语音识别服务未配置")
    except Exception as e:
        logger.error(f"Speech recognition error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"语音识别失败: {str(e)}")
