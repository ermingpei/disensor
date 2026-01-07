# DiSensor Network: 增长与稳定性综合开发计划 (Growth & Stability Master Plan)

## 1. 核心目标 (Core Objectives)
在正式启动自动化推广（AI Agents）之前，必须确保系统能够承载用户增量。我们将开发分为两个并行轨道：
1.  **基础设施稳固 (Infrastructure Hardening):** 确保 App 不崩、数据不丢、后端能抗压。
2.  **增长引擎准备 (Growth Engine Prep):** 完善邀请机制文案，准备自动化推广的一条龙脚本。

---

## 2. 阶段一：稳定性与核心功能完备 (Stability First) - **当前优先级**
*目标：确保前 10,000 名用户涌入时，系统依然丝般顺滑。*

### 2.1 全面完成 WiFi 指纹采集 (WiFi Fingerprinting)
*   [ ] **功能落地:** 完成 `WifiScannerService` 的 BSSID/RSSI 扫描逻辑（Android/iOS）。
*   [ ] **数据上链:** 确保 WiFi 数据能正确打包并上传至 Supabase。
*   [ ] **电量优化:** 确保后台扫描不会导致手机迅速发烫或耗电过快（这是用户卸载的第一大原因）。

### 2.2 后端抗压准备 (Backend Scalability with Supabase)
*   **现状分析:** Supabase (基于 PostgreSQL) 本身具有很强的弹性。对于 0-10,000 用户阶段，只要索引（Index）建好，不需要复杂的集群架构。
*   [ ] **数据库索引:** 检查 `measurements`, `wifi_readings`, `users` 表，确保查询频繁的字段（如 `user_id`, `geohash`）都有 INDEX。
*   [ ] **行级安全 (RLS) 复查:** 确保用户只能上传数据，不能恶意修改他人数据。
*   [ ] **冷数据归档策略:** 规划当数据量达到百万级时，如何将旧数据归档（Partitioning），保持热数据查询速度。

### 2.3 邀请机制文案升级 (Referral Polish)
*   [ ] **文案回滚与优化:** 将简单的 "Invite Friends" 改回强调 "DePIN", "Science", "Passive Income", "Future Value" 的深度文案。
*   [ ] **功能验证:** 确保邀请码生成、填写、绑定关系的逻辑无 Bug。

---

## 3. 阶段二：自动化代理构建 (AI Agent Deployment) - **准备就绪后启动**
*目标：让 AI 成为你的 Marketing 团队。*

### 3.1 社交监听代理 (Social Listening Agent) - "The Ghost Marketer"
*   **工具栈:** Python + PRAW (Reddit API) + GPT-4.
*   **操作流:**
    1.  **监听:** 24/7 监控 Subreddit (`r/passive_income`, `r/beermoney`, `r/androidapps`)。
    2.  **触发:** 当帖子标题或内容包含 "passive app", "earn money android", "depin" 时触发。
    3.  **生成:** 将帖子内容传给 LLM，生成一段 "开发者视角的、非广告口吻的" 回复。
        *   *示例:* "I'm building a similar DePIN project called DiSensor. It maps WiFi signal strength without draining battery. Still in Beta if you want to test: [Link]"
    4.  **通知:** 通过 Telegram Bot 发送给开发者，点击 "Approve" 即可人工发出（防止被封号）。

### 3.2 内容生成矩阵 (Content Matrix) - "SEO Autopilot"
*   **工具栈:** Python + Google Trends API + Medium API.
*   **内容策略:**
    1.  **关键词猎捕:** 监控长尾词，如 "best crypto mining apps for android 2026", "how to map wifi networks".
    2.  **自动撰写:** 使用 GPT-4 撰写 800字+ 的技术向文章，包含代码片段（增加专业度 ）。
    3.  **分发:** 自动发布到 Medium (利用其高域名权重) 和 Hashnode。
    4.  **转化:** 文章底部统一带有 "Download Sensor Sentinel Beta" 的链接。

### 3.3 目录提交 (Directory Submission)
*   **目标:** 获取高质量外链 (Backlinks)。
*   **执行:** 整理 Top 50 "App Directories" 和 "Web3 Project Lists" (如 DePINscan)，准备统一的提交物料包（Icon, Description, Screenshots），利用脚本或手动填表。

---

## 4. 阶段三：经济模型与兑付控制 (Economic Sustainability) - **防挤兑机制**
*目标：在用户量激增时，确保资金流不断裂，通过机制设计引导用户“延迟满足”。*

### 4.1 资金流出控制 (Outflow Control)
*   **策略 A: 每日全局熔断 (Global Daily Cap)**
    *   *机制:* 设置每日全平台兑换上限（如 $50 USD）。一旦耗尽，前端显示 "Today's Redemptions Sold Out"，引导用户等待明日或选择质押。
    *   *对应的代码工作:* 后端增加 `daily_redemption_counter`，前端增加状态检查。
*   **策略 B: 质押诱导 (Staking & Lock-up)**
    *   *机制:* 在提现页面给予强烈提示 —— "现在提现损耗 0%，但如果锁仓 30 天，未来挖掘速度 +20%"。
    *   *目标:* 诱导 80% 的用户选择锁仓，将由于用户增长带来的支付压力推迟到数月后（届时应已有投资或收入）。
*   **策略 C: 抽奖博弈 (Gamified Burn)**
    *   *机制:* "100 QBIT 兑换一张抽奖券"，有机会赢取 $50 礼品卡。
    *   *数学:* 利用概率论（低中奖率）大量回收并销毁用户手中的积分，降低整体债务。

### 4.2 盈利与造血 (Revenue Generation)
*   **策略 A: 节点许可证销售 (Node License Sale) - 短期现金流**
    *   *产品:* "Genesis Node License" (NFT 或 激活码)。
    *   *权益:* 持有者挖掘速度 x2，且拥有未来 Token 空投的优先权。
    *   *定价:* 早期早鸟价 $9.9 - $19.9。
    *   *执行:* 利用 Galxe 发布任务，OpenSea 发售 NFT。这是支付服务器费用的直接来源。
*   **策略 B: 生态补助金 (Grants) - 中期输血**
    *   *目标:* Solana Foundation, IoTeX, Peaq 等公链的 DePIN 专项基金 ($10k - $50k)。
    *   *筹码:* 我们真实的 WiFi 指纹数据量和用户增长曲线。
    *   *执行:* 无论用户多少，先写好 Proposal 提交申请。

---

## 5. 阶段四：分级发布与商业闭环 (Rollout & Cycle)
1.  **Alpha (当前):** 验证技术稳定性，跑通 WiFi 数据上链。
2.  **Closed Beta (付费/邀请制):**
    *   仅限持有 "Genesis NFT" 或 "早期邀请码" 的用户。
    *   这是验证“有人愿意花钱买算力”的阶段。
3.  **Public Beta (全面开放):**
    *   开启“每日限额”和“抽奖消耗”。
    *   启动 AI Marketing Agents (SEO/Reddit) 大规模引流。

---

## 5. 执行列表 (Action Items)

### 立即执行 (Immediate)
1.  **更新邀请页面文案**：恢复高大上的愿景描述。
2.  **检查 WiFi 扫描代码**：确保 `wifi_scanner_service.dart` 功能完整。
3.  **新建 `wifi_logs` 表**：在 Supabase 中建立存储 WiFi 指纹的表结构。
