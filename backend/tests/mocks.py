from langchain_community.llms.fake import FakeListLLM
from langchain_core.messages import AIMessage


class FakeLLMWithTools(FakeListLLM):
    """支持 bind_tools 的 Fake LLM (仅用于测试)"""

    def bind_tools(self, tools, **kwargs):
        return self

    async def ainvoke(self, input, *args, **kwargs):
        # 模拟一个简单的回复
        return AIMessage(content="[Mock] 这是一个模拟回复。请在前端配置 LLM 以获得真实响应。")
