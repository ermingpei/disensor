# 任务清单: Pooling MVP 开发 (Task List: Pooling MVP Development)

## 阶段 1：基础架构 (Phase 1: Foundation)
- [x] **[设计]** 系统架构图与通讯协议 (Orchestrator <-> Worker)
- [x] **[开发]** 节点代理程序 (Worker Node) 基础功能
    - [x] 容器化的浏览器环境 (Playwright/Puppeteer)
    - [x] 基础的反指纹配置 (Stealth Mode)
- [x] **[开发]** 中央编排器 (Orchestrator) MVP
    - [x] 任务分发 API
    - [x] 节点心跳与状态管理

## 阶段 2：边缘 AI 集成 (Phase 2: Edge AI Integration)
- [x] **[研发]** 本地脱敏与提取脚本 (Local PII & Extraction)
    - [x] 使用 Transformers.js 或 WebGPU 实现端侧文本摘要
- [x] **[测试]** 验证边缘处理后的数据带宽节省率

## 阶段 3：业务逻辑 - 电商趋势 (Phase 3: E-commerce Trend Logic)
- [x] **[脚本]** TikTok/Amazon 实时数据采集流量池实现
- [x] **[算法]** 趋势评分模型 (Trend Scoring Engine)
- [x] **[UI]** 卖家仪表盘 (Dashboard) 演示

## 阶段 4：验证与发布 (Phase 4: Validation & Launch)
- [x] **[验证]** 模拟全球分布式节点运行压力测试
- [x] **[文档]** 编写节点部署指南
