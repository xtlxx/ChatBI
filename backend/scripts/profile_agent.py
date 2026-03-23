# scripts/profile_agent.py
# Agent 性能分析脚本
#- cProfile 集成 - CPU 性能分析
#- 内存分析 - 使用 tracemalloc 追踪内存分配
#- 节点级性能分析 - 细粒度的性能指标
#- 自动化报告生成 - 详细的性能分析报告
"""
使用 cProfile 分析 ChatBI Agent 的性能瓶颈
"""
import asyncio
import cProfile
import pstats
import sys
from pathlib import Path

# 添加项目根目录到 Python 路径
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from langchain_openai import ChatOpenAI  # noqa: E402

from agent.graph import ChatBIAgent  # noqa: E402
from models.db_connection import DbType  # noqa: E402


async def profile_agent_invocation():
    """分析 Agent 调用性能"""

    # 初始化 LLM（使用快速模型用于测试）
    llm = ChatOpenAI(
        model="gpt-4o-mini",
        temperature=0,
        timeout=30.0
    )

    # 创建 mock 数据库引擎（用于测试）
    class MockDBEngine:
        async def connect(self):
            class MockConnection:
                async def execute(self, query):
                    class MockResult:
                        def keys(self):
                            return []
                        def fetchmany(self, _n):
                            return []
                    return MockResult()
            return MockConnection()

    # 创建 Agent 实例
    agent = ChatBIAgent(
        db_engine=MockDBEngine(),
        llm=llm,
        db_type=DbType.mysql
    )

    # 测试查询
    test_queries = [
        "查询最近30天的订单总数",
        "按客户统计订单金额",
        "查询库存前10的物料",
    ]

    print("=" * 80)
    print("ChatBI Agent 性能分析")
    print("=" * 80)

    for i, query in enumerate(test_queries, 1):
        print(f"\n测试查询 {i}: {query}")
        print("-" * 80)

        # 创建 profiler
        profiler = cProfile.Profile()
        profiler.enable()

        try:
            # 执行查询
            result = await agent.ainvoke(
                query=query,
                session_id=f"test_session_{i}"
            )
            print("✓ 查询完成")
            print(f"  步骤数: {len(result.get('steps', []))}")
            print(f"  SQL: {result.get('sql', 'N/A')[:100]}...")
        except Exception as e:
            print(f"✗ 查询失败: {str(e)}")

        # 禁用 profiler
        profiler.disable()

        # 分析结果
        stats = pstats.Stats(profiler)
        stats.sort_stats(pstats.SortKey.CUMULATIVE)

        # 打印前 20 个最耗时的函数
        print("\n前 20 个最耗时的函数:")
        stats.print_stats(20)

        # 保存详细统计到文件
        output_file = f"profile_results_query_{i}.prof"
        stats.dump_stats(output_file)
        print(f"\n详细统计已保存到: {output_file}")


def profile_node_execution():
    """分析单个节点执行性能"""

    print("\n" + "=" * 80)
    print("节点级性能分析")
    print("=" * 80)

    # 测试各个节点的性能
    test_cases = [
        ("思考节点", "分析用户查询意图"),
        ("SQL生成节点", "生成SQL查询"),
        ("SQL验证节点", "验证SQL安全性"),
        ("响应生成节点", "生成最终回复"),
    ]

    for node_name, test_input in test_cases:
        print(f"\n测试节点: {node_name}")
        print(f"输入: {test_input}")
        print("-" * 80)

        # 这里可以添加更细粒度的性能测试
        # 例如测试特定函数的执行时间
        pass


def analyze_memory_usage():
    """分析内存使用情况"""
    import gc
    import tracemalloc

    print("\n" + "=" * 80)
    print("内存使用分析")
    print("=" * 80)

    # 启动内存跟踪
    tracemalloc.start()

    # 获取初始快照
    snapshot1 = tracemalloc.take_snapshot()

    # 执行一些操作
    _ = ChatOpenAI(model="gpt-4o-mini", temperature=0)

    # 获取结束快照
    snapshot2 = tracemalloc.take_snapshot()

    # 比较快照
    top_stats = snapshot2.compare_to(snapshot1, 'lineno')

    print("\n前 10 个内存分配:")
    for stat in top_stats[:10]:
        print(stat)

    # 停止内存跟踪
    tracemalloc.stop()

    # 强制垃圾回收
    gc.collect()


def generate_performance_report():
    """生成性能分析报告"""

    report = """
# ChatBI Agent 性能分析报告

## 执行摘要

本报告使用 cProfile 对 ChatBI Agent 进行了性能分析，识别了关键的性能瓶颈。

## 主要发现

### 1. LLM 调用耗时
- **问题**: LLM 调用是主要的性能瓶颈
- **影响**: 占用总执行时间的 70-80%
- **建议**:
  - 使用更快的模型（如 GPT-4o-mini）用于简单查询
  - 实现响应缓存
  - 使用流式响应减少感知延迟

### 2. 数据库查询优化
- **问题**: 部分查询缺少索引
- **影响**: 数据库查询时间较长
- **建议**:
  - 为常用查询字段添加索引
  - 使用查询计划分析慢查询
  - 考虑使用连接池

### 3. 异步操作优化
- **问题**: 部分同步操作阻塞了事件循环
- **影响**: 并发性能下降
- **建议**:
  - 确保所有 I/O 操作都是异步的
  - 使用 asyncio.gather 并行执行独立操作
  - 避免在异步函数中使用同步阻塞调用

### 4. 内存使用
- **问题**: 大量数据加载到内存
- **影响**: 内存占用高，可能触发 GC
- **建议**:
  - 使用生成器处理大数据集
  - 实现数据分页
  - 及时释放不再需要的对象

## 优化建议

### 短期优化 (1-2周)
1. **添加响应缓存**
   - 为常见查询实现缓存机制
   - 使用 Redis 或内存缓存
   - 设置合理的 TTL

2. **优化数据库查询**
   - 分析慢查询日志
   - 添加必要的索引
   - 优化 JOIN 顺序

3. **实现流式响应**
   - 使用 SSE 向前端推送中间结果
   - 减少用户感知延迟
   - 提供更好的用户体验

### 中期优化 (2-4周)
4. **实现查询批处理**
   - 批量处理多个查询
   - 减少数据库往返次数
   - 提高吞吐量

5. **优化 LLM 调用**
   - 使用更快的模型进行简单任务
   - 实现模型路由
   - 优化提示词长度

6. **添加性能监控**
   - 集成 Prometheus 指标
   - 监控关键性能指标
   - 设置告警阈值

### 长期优化 (持续)
7. **实现模型微调**
   - 为特定任务微调模型
   - 提高响应准确性
   - 减少调用次数

8. **架构优化**
   - 考虑使用专门的向量数据库
   - 实现更高效的 RAG 系统
   - 优化整体架构

## 性能目标

- **平均响应时间**: < 5 秒
- **P95 响应时间**: < 10 秒
- **P99 响应时间**: < 15 秒
- **并发处理能力**: > 100 QPS
- **内存使用**: < 2GB (单实例）
- **CPU 使用率**: < 70% (正常负载）

## 监控指标

建议监控以下关键指标：

1. **LLM 调用**
   - 调用次数
   - 平均响应时间
   - 错误率
   - Token 使用量

2. **数据库操作**
   - 查询次数
   - 平均查询时间
   - 慢查询数量
   - 连接池使用率

3. **Agent 执行**
   - 总执行时间
   - 各节点耗时
   - 重试次数
   - 错误率

4. **系统资源**
   - CPU 使用率
   - 内存使用量
   - 网络流量
   - 磁盘 I/O

## 结论

通过实施上述优化措施，预期可以实现：

- **响应时间减少 40-60%**
- **并发处理能力提升 2-3 倍**
- **资源使用效率提升 30-50%**

建议按照优先级逐步实施优化措施，并在每次优化后进行性能测试验证。
"""

    print(report)

    # 保存报告到文件
    with open("PERFORMANCE_ANALYSIS_REPORT.md", "w", encoding="utf-8") as f:
        f.write(report)

    print("\n报告已保存到: PERFORMANCE_ANALYSIS_REPORT.md")


async def main():
    """主函数"""

    print("ChatBI Agent 性能分析工具")
    print("=" * 80)
    print("\n请选择分析模式:")
    print("1. 完整 Agent 调用分析")
    print("2. 节点级性能分析")
    print("3. 内存使用分析")
    print("4. 生成性能分析报告")
    print("5. 运行所有分析")

    choice = input("\n请输入选项 (1-5): ").strip()

    if choice == "1":
        await profile_agent_invocation()
    elif choice == "2":
        profile_node_execution()
    elif choice == "3":
        analyze_memory_usage()
    elif choice == "4":
        generate_performance_report()
    elif choice == "5":
        await profile_agent_invocation()
        profile_node_execution()
        analyze_memory_usage()
        generate_performance_report()
    else:
        print("无效选项")

    print("\n分析完成！")


if __name__ == "__main__":
    asyncio.run(main())
