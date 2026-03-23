import base64
import hashlib
import hmac
import json
import logging
from datetime import datetime
from email.utils import formatdate
from time import mktime
from urllib.parse import urlencode

import websockets

from config import settings

logger = logging.getLogger(__name__)

class XunfeiSpeechRecognition:
    def __init__(self):
        import os
        from dotenv import load_dotenv
        
        # 强制指定 .env 文件的绝对路径，确保一定能找到
        env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
        load_dotenv(dotenv_path=env_path, override=True)
        
        app_id = os.getenv("XUNFEI_APP_ID") or settings.XUNFEI_APP_ID
        api_key = os.getenv("XUNFEI_API_KEY") or settings.XUNFEI_API_KEY
        api_secret = os.getenv("XUNFEI_API_SECRET") or settings.XUNFEI_API_SECRET

        # 清理可能存在的不可见字符 (如 embedded null character \x00)
        self.app_id = app_id.replace('\x00', '').strip() if app_id else None
        self.api_key = api_key.replace('\x00', '').strip() if api_key else None
        self.api_secret = api_secret.replace('\x00', '').strip() if api_secret else None

        self.host = "iat-api.xfyun.cn"
        self.uri = "/v2/iat"

    def create_url(self):
        """生成鉴权URL"""
        url = f"wss://{self.host}{self.uri}"
        
        # 生成RFC1123格式的时间戳
        now = datetime.now()
        date = formatdate(timeval=mktime(now.timetuple()), localtime=False, usegmt=True)
        
        # 拼接字符串
        signature_origin = f"host: {self.host}\ndate: {date}\nGET {self.uri} HTTP/1.1"
        
        # 进行hmac-sha256进行加密
        signature_sha = hmac.new(
            self.api_secret.encode('utf-8'),
            signature_origin.encode('utf-8'),
            digestmod=hashlib.sha256
        ).digest()
        
        signature_sha = base64.b64encode(signature_sha).decode('utf-8')
        
        authorization_origin = f'api_key="{self.api_key}", algorithm="hmac-sha256", headers="host date request-line", signature="{signature_sha}"'
        authorization = base64.b64encode(authorization_origin.encode('utf-8')).decode('utf-8')
        
        # 将请求的鉴权参数组合为字典
        v = {
            "authorization": authorization,
            "date": date,
            "host": self.host
        }
        
        # 拼接鉴权参数
        url = url + '?' + urlencode(v)
        return url

    async def recognize(self, audio_data: bytes) -> str:
        """
        处理语音识别
        :param audio_data: PCM格式的音频数据, 采样率16000, 16位, 单声道
        """
        if not self.app_id or not self.api_key or not self.api_secret:
            raise ValueError("Xunfei API credentials not configured")

        url = self.create_url()
        result_text = ""
        
        try:
            async with websockets.connect(url) as ws:
                # 构造第一帧请求参数
                d = {
                    "common": {
                        "app_id": self.app_id
                    },
                    "business": {
                        "domain": "iat",
                        "language": "zh_cn",
                        "accent": "mandarin",
                        "vinfo": 0,
                        "vad_eos": 10000
                    },
                    "data": {
                        "status": 0, # 0: 第一帧
                        "format": "audio/L16;rate=16000",
                        "encoding": "raw",
                        "audio": base64.b64encode(audio_data).decode('utf-8')
                    }
                }
                
                # 发送第一帧（包含所有数据）
                await ws.send(json.dumps(d))
                
                # 发送结束帧
                d = {
                    "data": {
                        "status": 2, # 2: 最后一帧
                        "format": "audio/L16;rate=16000",
                        "encoding": "raw",
                        "audio": ""
                    }
                }
                await ws.send(json.dumps(d))
                
                # 接收识别结果
                while True:
                    res = await ws.recv()
                    res_dict = json.loads(res)
                    
                    if res_dict["code"] != 0:
                        logger.error(f"Xunfei API error: {res_dict['code']} - {res_dict['message']}")
                        raise Exception(f"Speech recognition failed: {res_dict['message']}")
                        
                    data = res_dict["data"]
                    ws_result = data["result"]["ws"]
                    
                    for w in ws_result:
                        for cw in w["cw"]:
                            result_text += cw["w"]
                            
                    if data["status"] == 2:
                        break
                        
            return result_text
            
        except Exception as e:
            logger.error(f"Error in Xunfei recognition: {str(e)}")
            raise
