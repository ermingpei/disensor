# DiSensor - 下一步行动计划

## 🎯 本周必做（Week 1）

### 1. 数据可视化 Demo（2天）
**目标：让潜在买家看到数据价值**

- [ ] 在 Dashboard 添加"数据可视化"页面
  - 气压热力图（叠加在地图上）
  - 噪音热力图（颜色编码）
  - 时间序列图表（过去7天的趋势）
  
- [ ] 生成一个可分享的链接
  ```
  https://disensor.app/public/demo?city=yourCity
  ```

**代码位置：** `dashboard/visualization.html`

---

### 2. 客户开发（3天）
**目标：找到第一个愿意测试数据的潜在客户**

#### 潜在客户列表：
- [ ] **本地天气 App/网站**
  - 搜索："[你的城市] weather forecast"
  - 找到 5 个本地天气服务
  - 发冷邮件模板（见下方）

- [ ] **噪音投诉/环保部门**
  - Google: "[你的城市] noise complaint department"
  - 准备一份"噪音热力图"PDF 作为案例

- [ ] **房地产数据公司**
  - Zillow, Redfin, Trulia
  - 定位："安静社区溢价分析"

#### 冷邮件模板：
```
Subject: Hyper-Local Weather Data for [城市名]

Hi [Name],

I noticed [公司名] provides weather forecasts for [城市]. 
I'm building a distributed sensor network that collects real-time 
barometric pressure and noise levels at street-level granularity.

Current coverage: [X] active sensors across [城市]
Update frequency: Every 30 seconds
Accuracy: ±0.1 hPa (better than NOAA stations)

Would you be interested in a free 30-day trial to see if this data 
improves your forecast accuracy?

Live demo: https://disensor.app/demo

Best,
[Your Name]
```

---

### 3. 积分系统 MVP（1天）
**目标：让用户看到"未来收益"**

- [ ] Dashboard 显示累计积分
  ```dart
  // 计算公式
  points = uptime_hours × 10 
         + unique_hexes_visited × 50 
         + referrals × 200
  ```

- [ ] 添加"未来预期"提示
  ```
  "Your 1,234 points = ~$X.XX if token launches at $0.01"
  "Early contributors (top 1000) get 3x airdrop bonus!"
  ```

- [ ] 排行榜（本地先用 Supabase 实现）

**代码位置：** `lib/features/points_system.dart`

---

## 📅 第2-4周：Token 准备

### Week 2: Tokenomics 文档
- [ ] 撰写 Token 白皮书（10页）
  - 总量、分配、释放机制
  - 挖矿算法详解
  - 治理机制
  
- [ ] 法律咨询（$2000-5000）
  - 美国：是否是 Security?
  - 注册 DAO/基金会（开曼群岛）

### Week 3: 技术准备
- [ ] 选择链：Solana (低费用) or Polygon (兼容以太坊)
- [ ] 智能合约开发
  - Token 合约
  - Vesting 合约
  - Staking 合约

### Week 4: 社区建设
- [ ] 创建 Discord/Telegram 群
- [ ] Twitter 账号 + 每日更新
- [ ] 准备 Token 上线 PR

---

## 🎨 UI 改进建议（优先级中）

### Dashboard 新增模块
1. **"我的收益"卡片**
   ```
   ┌─────────────────────┐
   │ 💰 Potential Earnings │
   │ 1,234 Points         │
   │ ≈ $12.34 (if $0.01)  │
   │ Rank: #42 / 156      │
   └─────────────────────┘
   ```

2. **"推荐奖励"强化**
   ```
   ┌──────────────────────┐
   │ 🎁 Referral Boost    │
   │ You: 3 friends       │
   │ Bonus: +60% forever! │
   │ Share: [Copy Link]   │
   └──────────────────────┘
   ```

3. **"任务中心"（游戏化）**
   ```
   Daily Quest:
   ✅ Stay online 1hr → +50 pts
   ⏳ Visit 3 hexes → +100 pts
   ❌ Refer a friend → +500 pts
   ```

---

## 💡 关键指标追踪

### 本月目标（KPI）
- [ ] 活跃设备数: 50+
- [ ] 数据上传成功率: >90%
- [ ] 潜在客户接触: 20+
- [ ] Demo 请求: 5+
- [ ] 付费客户: 1 ($99+)

### 每周监控
```sql
-- 在 Supabase 运行
SELECT 
  COUNT(DISTINCT device_id) as active_devices,
  COUNT(*) as total_readings,
  AVG(accuracy) as avg_accuracy
FROM sensor_readings
WHERE created_at > NOW() - INTERVAL '7 days';
```

---

## 🚨 风险提示

### 法律风险
- ⚠️ Token 可能被 SEC 视为证券
- 解决方案：
  1. 咨询律师 ($5k)
  2. 不向美国用户推广
  3. 或走 Regulation A+ 路径（合规但贵）

### 技术债务
- ⚠️ H3 库还没集成（用的是 Mock 数据）
- ⚠️ 后台采集稳定性未长期测试
- 优先级：先有客户再优化技术

### 竞争风险
- ⚠️ 如果数据很有价值，大公司可能模仿
- 护城河：早期贡献者网络效应 + Token 锁仓

---

## 📞 需要帮助时

1. **代码问题**：随时通过 AI 助手解决
2. **商务拓展**：准备好 Pitch Deck（我可以帮您写）
3. **Token 设计**：参考 Helium 的 HIP (Helium Improvement Proposal)

**记住：先有客户，后有 Token。没有需求的 Token 就是空气币。**
