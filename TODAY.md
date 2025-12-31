# 今日任务清单（3小时完成）

## ⏰ 13:00 - 14:00: 数据展示页面
**目标：生成一个可以发给潜在客户的 Demo 链接**

### 步骤：
1. 打开 `dashboard/marketplace.html`
2. 修改为 `dashboard/demo.html`
3. 添加内容：
   ```html
   <h1>DiSensor - Real-time Environmental Data</h1>
   <div id="map" style="height: 400px"></div>
   <script>
     // 从 Supabase 拉取最近7天的数据
     // 在地图上显示热力图
   </script>
   ```
4. 一个简单的统计 Dashboard：
   ```
   活跃传感器: 12 台
   数据点: 142,341 条
   覆盖面积: 50 km²
   更新频率: 30秒
   ```

### 完成标志：
- [ ] 可以通过 `http://localhost:3000/demo.html` 访问
- [ ] 显示真实的地图 + 数据点

---

## ⏰ 14:00 - 15:30: 撰写客户邮件
**目标：准备 5 封定制化的冷邮件**

### 找到 5 个潜在客户：
1. Google 搜索："[你的城市] weather app"
2. 找到他们的 Contact/About 页面
3. 找到创始人或 CTO 的邮箱（用 Hunter.io）

### 邮件模板（已在 ACTION_PLAN.md）
关键点：
- 开头提到他们的产品（显示你做了功课）
- 展示具体数字（"12 台传感器，142k 数据点"）
- **免费试用 30 天**（降低门槛）
- 附上 Demo 链接

---

## ⏰ 15:30 - 16:00: 积分系统原型
**目标：Dashboard 显示"潜在收益"**

### 快速实现：
在 `lib/features/debug_dashboard.dart` 添加一个卡片：

```dart
Card(
  child: Column(
    children: [
      Text("💰 Your Points", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text("1,234", style: TextStyle(fontSize: 32, color: Colors.green)),
      Text("≈ \$12.34 if Token = \$0.01", style: TextStyle(fontSize: 12)),
      Text("Rank: #42 / 156", style: TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  ),
)
```

计算逻辑（简化版）：
```dart
int calculatePoints(SensorManager manager) {
  int uptime = manager.totalUptimeSeconds ~/ 3600; // 每小时 10 分
  int hexes = _uniqueHexesVisited.length; // 每个新 Hex 50 分
  int referrals = _referralCount; // 每个推荐 200 分
  
  return uptime * 10 + hexes * 50 + referrals * 200;
}
```

---

## ✅ 完成后的成果

1. **Demo 页面** → 发给 5 个潜在客户
2. **邮件草稿** → 明天早上发送
3. **积分卡片** → 推送新版本给测试用户

**预期：2周内有 1-2 个客户回复对数据感兴趣**

---

## 📧 推荐的第一个目标客户

**Weather Underground (wunderground.com)**
- 为什么选他们：他们本身就是众包天气站网络
- 他们的痛点：需要更密集的气压数据
- 您的优势：手机传感器 >> 家庭气象站 (覆盖密度)
- 联系方式：通过 LinkedIn 找他们的 Product Manager

**邮件标题：**
"Hyperlocal Barometer Network - Complement to PWS"

**正文要点：**
- 我们有 X 台手机每 30 秒上报气压
- 密度是传统气象站的 100 倍
- 免费 API 试用 30 天
- 附上您所在城市的"气压热力图"截图

---

## 🎓 学习资源（今晚睡前看）

1. **Helium 的早期增长策略**
   https://www.helium.com/hnt

2. **DePIN 项目融资案例**
   - DIMO: Raised $9M (卖车辆数据)
   - Hivemapper: Raised $18M (街景地图)
   - 关键：先有收入，再融资

3. **Token 经济学设计**
   - Messari: "Analyzing Helium's Tokenomics"
   - 核心公式：Token 价值 = 网络收入 / 流通量

**记住：在没有客户之前，Token 就是零。先做出有人要的产品！**
