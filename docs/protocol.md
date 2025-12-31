# 通讯协议规范 (Communication Protocol Specification)

## 1. 概述 (Overview)
Orchestrator 与 Agent 之间通过 **WebSocket** 进行双向实时通讯。所有消息均为 JSON 格式。

---

## 2. 基础消息结构 (Base Message Structure)
```json
{
  "type": "STRING",      // 消息类型
  "id": "UUID",          // 消息唯一标识符
  "timestamp": "ISO8601",
  "payload": {}          // 具体数据内容
}
```

---

## 3. 消息类型 (Message Types)

### 3.1 注册与心跳 (Registration & Heartbeat)
- **AGENT_REGISTER**: Agent 启动时向 Orchestrator 注册，包含版本、系统信息及已安装模型。
- **HEARTBEAT**: Agent 每隔 30 秒发送一次，Orchestrator 回应以维持连接。

### 3.2 任务管理 (Task Management)
- **TASK_EXECUTE**: Orchestrator 下发抓取/分析任务。
  ```json
  {
    "url": "https://example.com",
    "script": "extraction_logic_v1",
    "params": { "category": "tech" }
  }
  ```
- **TASK_RESULT**: Agent 提交处理后的结构化数据。
- **TASK_ERROR**: 任务失败时的错误报告。

---

## 4. 边缘 AI 处理指令 (Edge AI Directives)
在 `TASK_EXECUTE` 中，可以指定 `processing_mode`:
- `RAW`: 仅抓取原始 HTML。
- `SUMMARIZE`: 本地生成摘要。
- `DE_IDENTIFY`: 本地隐私脱敏（必需项）。

---
*Created: 2025-12-28*
