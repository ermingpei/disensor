# 实现计划：Pooling MVP (Implementation Plan: Pooling MVP)

## 1. 目标 (Goal)
构建一个最小可行性产品（MVP），能够通过全球分布的节点（模拟）抓取电商平台的关键信号，并在本地完成 PII 脱敏和数据概括。

## 2. 系统方案 (System Design)

### 2.1 技术栈选择 (Tech Stack)
- **中央编排器 (Orchestrator):** Node.js (与 Agent 保持一致，便于快速开发)。
- **节点代理 (Worker Node):** Node.js (与 Playwright/Puppeteer 天然集成)。
- **通讯层:** WebSocket (实时指令) + libp2p (用于后续 P2P 扩展)。
- **边缘 AI:** Transformers.js (在浏览器/Node 进程中直接运行小型 LLM，如 MiniLM)。

### 2.2 核心架构组件 (Core Components)

#### A. 协同编排器 (Orchestrator)
- **主要职责:** 接收用户任务，将其分解为子任务，下发给空闲节点，并聚合结果。
- **存储:** Redis (缓存任务状态) + PostgreSQL (结果长期存储)。

#### B. 边缘分身 (Worker Agent) [NEW]
- **模块 1: Browser Manager** - 负责管理浏览器实例的生命周期。
- **模块 2: Fingerprint Spoofer** - 动态注入指纹，对抗检测。
- **模块 3: Extraction Engine (Edge AI)** - 核心模块，运行在浏览器 Context 中，直接从 DOM 中提取干净的知识点。

---

## 3. 拟议更改 (Proposed Changes)

### [Component] Worker Agent (Node.js)
#### [NEW] `agent/main.js`
- 建立与控制中心的长连接。
- 监听 `TASK_EXECUTE` 事件。

#### [NEW] `agent/core/browser.js`
- 封装 Playwright Stealth。
- 实现 IP 轮换逻辑接口。

### [Component] Edge Logic
#### [NEW] `edge/extractor.js`
- 运行在浏览器内部。
- **功能:** 识别网页中的价格、评论数，并使用本地模型生成摘要。

---

## 4. 验证计划 (Verification Plan)

### 自动测试 (Automated Tests)
- `npm test agent`: 验证节点是否能成功启动无痕浏览器并访问目标页面。
- `go test orchestrator`: 验证任务分发逻辑。

---
> [!IMPORTANT]
> **法律合规提醒**: MVP 初期仅针对没有任何登录墙的公开电商页面进行测试，严禁用于任何形式的暴力破解。
