# 项目演示：Pooling MVP (Walkthrough: Pooling MVP)

## 1. 核心功能演示 (Core Features)

### A. 分布式任务分发 (Distributed Task Dispatch)
我们实现了基于 WebSocket 的**编排器 (Orchestrator)**，它可以向全球分布的**边缘分身 (Worker Agent)** 下发任务。

**运行流程:**
1. Orchestrator 启动并监听 8080 (API) 和 8081 (WS) 端口。
2. Agent 启动并向 Orchestrator 注册自己。
3. 用户调用 REST API 触发抓取任务。

### B. 边缘 AI 隐私脱敏 (Edge AI PII Redaction)
在 Agent 本地，我们集成了 AI 模块。在数据回传前，系统会自动识别并抹除隐私信息（邮箱、电话）。

**测试案例结果 (Result):**
- **原始数据:** `Contact: john.doe@example.com, Phone: +1-555-0199-2345`
- **处理后数据:** `Contact: [EMAIL], Phone: [PHONE]`

### C. 本地内容摘要 (Local Summarization)
对于长篇大论的网页，Agent 会利用 `Transformers.js` 在本地运行 `distilbart-cnn` 模型，仅回传精简化后的结论，极大节省了带宽。

---

## 2. 代码架构 (Code Structure)

```text
pooling/
└── trend-prediction/  # 电商趋势预测子项目
    ├── orchestrator/  # 中央编排器 (Node.js)
    │   └── main.js    # 任务分发与 WebSocket 服务
    ├── agent/         # 分身节点 (Node.js + Playwright)
    │   ├── main.js    # 节点入口逻辑
    │   └── core/
    │       ├── ai.js      # 本地 AI 处理 (PII + Summary)
    │       └── trends.js  # 趋势分析算法
    ├── test.html      # 基础测试网页
    └── tiktok-test.html # TikTok 模拟测试网页
```

---

## 3. 验证结果 (Verification Results)

我们成功执行了以下测试命令：
`curl -X POST -d '{"url": "file:///path/to/test.html"}' http://localhost:8080/tasks`

**返回结果 (Response):**
```json
{
  "taskId": "...",
  "result": {
    "title": "PII Test Page",
    "summary": "Leading AI textbooks define the field as the study of \"intelligent agents\"...",
    "timestamp": "2025-12-28..."
  }
}
```

---
*Pooling - 让数据采集更智能、更安全。*
