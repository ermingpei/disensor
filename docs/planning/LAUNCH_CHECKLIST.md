# Qubit Rhythm 启动清单

## 🚀 今天完成（1小时）

### 1. 完成 Vercel 部署
- [ ] 在浏览器访问 https://vercel.com/device
- [ ] 输入代码：GDHM-WPGW
- [ ] 回到终端按 ENTER
- [ ] 运行：`npx vercel --prod`
- [ ] 记录部署的 URL：_______________

### 2. 设置 qubitrhythm.com 域名
**在域名注册商（Namecheap/GoDaddy）：**
- [ ] 登录域名管理面板
- [ ] DNS 设置 → 添加 CNAME 记录：
  ```
  Type: CNAME
  Name: @ (或留空)
  Target: cname.vercel-dns.com
  ```
- [ ] 添加 www CNAME：
  ```
  Name: www
  Target: cname.vercel-dns.com
  ```

**在 Vercel Dashboard：**
- [ ] 项目设置 → Domains
- [ ] 添加域名：qubitrhythm.com
- [ ] 添加域名：www.qubitrhythm.com
- [ ] 等待 DNS 生效（5-30分钟）

### 3. 设置企业邮箱（免费）
**选项A: Zoho Mail（推荐）**
1. [ ] 注册 https://zoho.com/mail
2. [ ] 添加域名 qubitrhythm.com
3. [ ] 按照提示添加 DNS 记录（回到域名管理面板）
4. [ ] 创建邮箱：hello@qubitrhythm.com

**选项B: Gmail 转发（快速解决方案）**
1. [ ] 在域名 DNS 添加 Email Forwarding:
   ```
   hello@qubitrhythm.com → your.personal@gmail.com
   ```
2. [ ] Gmail 设置 → "发送邮件为" → 添加别名
   ```
   名称：Qubit Rhythm Team
   邮箱：hello@qubitrhythm.com
   ```

---

## 📧 明天完成（2小时）

### 研究 5 个潜在客户

**天气/环境数据类：**
- [ ] Weather Underground (wunderground.com)
- [ ] OpenWeatherMap
- [ ] Tomorrow.io
- [ ] 本地天气 App/网站

**城市规划/噪音监测类：**
- [ ] Hush City (noise mapping app)
- [ ] 当地环保部门
- [ ] 城市规划局

**房地产/数据分析类：**
- [ ] Zillow/Redfin
- [ ] 房地产数据公司
- [ ] Urban analytics startups

### 准备邮件
对每个客户，记录：
1. [ ] 公司名称：_______________
2. [ ] 他们的产品/服务：_______________
3. [ ] 为什么需要您的数据：_______________
4. [ ] 联系人（CEO/CTO）：_______________
5. [ ] 邮箱（用 hunter.io 查找）：_______________

### 发送第一批邮件（用这个模板）

```
Subject: Hyperlocal Barometer Data for [他们的城市]

Hi [Name],

I came across [Company/Product] and noticed you're working on 
[specific feature they have - 显示你做了功课].

The Qubit Rhythm team operates a distributed sensor network 
collecting real-time environmental data. We currently have:

• 12 active mobile sensors across [Your City]
• Barometric pressure every 30 seconds (±0.1 hPa accuracy)
• Ambient noise levels (±2 dB)
• 100x denser coverage than traditional weather stations

**Potential value for [Company]:**
[个性化这部分 - 比如：]
- Improve micro-climate forecasts in urban canyons
- Detect storm fronts 15-30 minutes earlier
- Altitude-aware pressure modeling

Would you be interested in a free 30-day API trial to evaluate 
data quality for [their specific use case]?

Live demo: https://qubitrhythm.com

Best regards,
Qubit Rhythm Research Team
hello@qubitrhythm.com
```

---

## 📱 关于 App 发布

### 现阶段（Week 1-4）：不公开发布

**原因：**
1. 您已经有足够的测试设备（自己+朋友 = 12台）
2. 客户不需要看到 App，只需要看到数据
3. 避免过早的支持负担

**策略：**
- Demo 网站展示实时数据
- 邀请亲友安装测试版（通过 TestFlight）
- 告诉客户："我们正在 Beta 测试中"

### 触发 Beta 发布的条件

**当满足以下任一条件时，发布 TestFlight：**
- [ ] 有 1 个客户愿意付费（$99+/月）
- [ ] Waitlist 注册 > 50 人，其中 >5 人表示想贡献数据
- [ ] 有投资人/媒体想报道，需要更多用户

### 触发公开发布的条件

**当满足以下所有条件时，发布到 App Store：**
- [ ] 月收入 > $1000（证明有市场需求）
- [ ] Token 经济学确定
- [ ] 法律合规完成（LLC + 律师审核）
- [ ] 准备好处理用户支持（Discord/Telegram 社区）

---

## 🎯 本周目标（可衡量）

- [ ] 网站上线（qubitrhythm.com）
- [ ] 企业邮箱设置完成
- [ ] 发送 5 封客户邮件
- [ ] 收到 1-2 个回复
- [ ] Waitlist 注册 > 10 人

**成功标志：至少 1 个客户回复说"有兴趣了解更多"**

---

## 💡 FAQ

### Q: "qubitrhythm.com 太古怪了吗？"
A: 不！独特 = 让人记住。对比：
- ❌ SensorData.com（烂大街）
- ❌ EnviroNet.com（无聊）
- ✅ Qubit Rhythm（有故事、有科技感）

成功案例：
- Helium（氦气？但现在市值几十亿）
- Hivemapper（蜂巢地图？但拿到 $1800万融资）
- Akash（印度名字？但是头部 DePIN 项目）

### Q: "客户会觉得名字太奇怪吗？"
A: 不会，因为您可以讲故事：
```
"Qubit 代表量子级别的精确传感器
Rhythm 代表环境的脉搏（气压、噪音的波动节奏）
我们用量子时代的技术，测量世界的心跳"
```

### Q: "是否还需要 disensor.app？"
A: 可以保留作为：
1. App 的下载页面（qubitrhythm.com = 企业官网，disensor.app = App 下载）
2. 重定向到主站
3. 或者完全不买（省钱）

推荐：**先用 qubitrhythm.com，如果业务起来了再买 disensor.app**

---

## 🚨 注意事项

### 不要过早优化
- ❌ 现在就花钱买 10 个域名
- ❌ 现在就注册公司
- ❌ 现在就做完美的 App UI

### 专注最重要的事
- ✅ 找到 1 个愿意付费的客户
- ✅ 证明数据有价值
- ✅ 有收入后再扩大规模

**记住：Airbnb 的第一版网站丑得要命，但他们专注于证明需求。**
