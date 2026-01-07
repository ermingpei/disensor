# 🎯 网站更新和域名策略方案

## 📊 **问题1解决：显示 Edmonton 真实数据**

### 当前问题
- 地图中心在旧金山 (37.7749, -122.4194)
- 显示的是 mock 数据 (12, 142K, 50)
- 需要改为 Edmonton 真实数据

### 立即修复步骤

**选项A：使用 Edmonton 真实位置的 Mock 数据（推荐，立即可用）**

修改 `dashboard/index.html` 第 335 行和 353-355 行：

```javascript
// 将地图中心改为 Edmonton
const map = L.map('map').setView([53.5461, -113.4938], 11); // Edmonton

// 更新 mock 数据为真实情况
document.getElementById('active-sensors').textContent = '6';
document.getElementById('data-points').textContent = '2.4K'; // 6台 × 24小时 × 30秒
document.getElementById('coverage').textContent = '15'; // Edmonton coverage estimate
```

并且添加 Edmonton 的示例点：
```javascript
const demoPoints = [
    [53.5461, -113.4938], // Downtown Edmonton
    [53.5232, -113.5263], // University of Alberta
    [53.5225, -113.6257], // West Edmonton Mall area
    [53.5710, -113.4912], // Northside
    [53.4665, -113.4925], // Southside
    [53.3900, -113.4685]  // Millwoods
];
```

**选项B：连接真实 Supabase 数据**

1. 登录您的 Supabase Dashboard
2. 项目设置 → API
3. 复制 URL 和 anon key
4. 更新 `index.html` 第 341-342 行
5. 重新推送到 GitHub

---

## 🏢 **问题2 & 问题3：域名架构和品牌策略**

### 您的洞察非常准确！

**当前架构（不合理）：**
```
qubitrhythm.com → DiSensor 项目
```

**应该的架构（合理）：**
```
Qubit Rhythm (母公司)
├── qubitrhythm.com (公司官网)
├── disensor.qubitrhythm.com (这个项目)
├── project2.qubitrhythm.com (未来的项目)
└── project3.qubitrhythm.com
```

### 推荐的域名策略

#### **策略A：子域名架构（推荐）**
```
qubitrhythm.com              → 母公司官网
disensor.qubitrhythm.com     → DiSensor 项目
api.disensor.qubitrhythm.com → DiSensor API
```

**优势：**
✅ 保持品牌统一
✅ 成本低（只需要一个域名）
✅ 灵活扩展（未来加其他项目）
✅ 专业形象

**劣势：**
⚠️ DiSensor 作为子品牌，不够独立

---

#### **策略B：独立域名 + 品牌联系（最灵活）**
```
qubitrhythm.com  → 母公司（项目孵化器）
disensor.ai      → DiSensor 独立品牌
```

**页面底部注明：**
```
"DiSensor is a Qubit Rhythm initiative"
或
"A product by Qubit Rhythm Labs"
```

**优势：**
✅ DiSensor 可独立发展
✅ 品牌更有记忆度
✅ 未来如果融资/出售，独立域名更值钱
✅ SEO 独立优化

**劣势：**
💰 额外成本（$10-20/年）

---

#### **策略C：混合策略（推荐给创业初期）**
```
开发/测试阶段：
disensor.qubitrhythm.com (免费)

正式上线后：
disensor.ai (主域名)
仍然保留 disensor.qubitrhythm.com → 自动跳转
```

---

### 域名选择建议

| 域名 | 年费 | 优势 | 劣势 | 推荐度 |
|------|------|------|------|--------|
| **disensor.ai** | ~$20 | ✅ AI 感强<br>✅ 短且专业 | 💰 稍贵 | ⭐⭐⭐⭐⭐ |
| **disensor.app** | ~$15 | ✅ 适合移动 App | ⚠️ 不够 DePIN 感 | ⭐⭐⭐⭐ |
| **disensor.network** | ~$10 | ✅ 符合 DePIN 定位 | ⚠️ 稍长 | ⭐⭐⭐⭐ |
| **disensor.io** | ~$25 | ✅ 科技感 | 💰 贵且烂大街 | ⭐⭐⭐ |
| **disensor.qubitrhythm.com** | 免费 | ✅ 零成本<br>✅ 品牌关联 | ⚠️ 太长 | ⭐⭐⭐⭐ 启动阶段 |

---

## 🔐 **问题3解决：隐藏 GitHub 用户名**

### 当前问题
```
https://ermingpei.github.io/qubitrhythm/
```
这会暴露您的 GitHub 用户名。

### 解决方案

#### **方案1：使用自定义域名（推荐）**

**如果使用 disensor.qubitrhythm.com：**

1. 在 GitHub repo Settings → Pages
2. Custom domain: 填写 `disensor.qubitrhythm.com`
3. 在 qubitrhythm.com 的 DNS 设置：
   ```
   Type: CNAME
   Name: disensor
   Value: ermingpei.github.io
   ```
4. 等待 5-30 分钟生效

**结果：**
- ✅ 访问地址：https://disensor.qubitrhythm.com
- ✅ 不显示 GitHub 用户名
- ✅ 完全免费（GitHub Pages + 已有域名）

---

#### **方案2：使用 Cloudflare Pages（完全匿名）**

1. 登录 Cloudflare
2. Pages → Create project → Connect Git
3. 连接 GitHub repo (private 也可以)
4. 部署

**域名：**
```
https://disensor.pages.dev (免费)
```

或绑定自定义域名：
```
https://disensor.qubitrhythm.com
```

**优势：**
✅ 支持 private repo
✅ 更快的 CDN
✅ 不暴露 GitHub 信息
✅ 免费

---

#### **方案3：Netlify（也可考虑）**

类似 Cloudflare，但界面更友好。

---

## 🗂️ **推荐的项目/Repo 命名**

### 当前：`qubitrhythm` → 应该改名

**建议的 repo 名称：**

| Repo名 | 适用场景 | 推荐度 |
|--------|----------|--------|
| **disensor** | 简单直接，项目名 | ⭐⭐⭐⭐⭐ |
| **disensor-network** | 强调网络属性 | ⭐⭐⭐⭐ |
| **disensor-depin** | 强调 DePIN 定位 | ⭐⭐⭐⭐ |
| **pulse** | 呼应 "Measuring the World's Pulse" | ⭐⭐⭐⭐ |
| **sensor-mesh** | 技术感强 | ⭐⭐⭐ |

**最推荐：`disensor`**
- 简洁
- 和域名一致
- 容易记忆

### 如何更改 Repo 名

1. GitHub repo → Settings
2. Repository name → 改为 `disensor`
3. 点击 Rename

**更新本地 remote：**
```bash
cd /tmp/qubit-website
git remote set-url origin https://github.com/ermingpei/disensor.git
```

---

## 📝 **关于 Vercel DNS 的混淆（问题4）**

### 为什么之前文档提到 Vercel？

之前我准备了 **多个部署方案**，给您选择：
1. GitHub Pages（免费，您选了这个 ✅）
2. Vercel（需要验证码，遇到问题了）
3. Cloudflare Pages
4. Netlify

**cname.vercel-dns.com 是 Vercel 的方案，和 GitHub Pages 无关。**

**您现在用的是 GitHub Pages，所以：**
- ❌ 不需要 `cname.vercel-dns.com`
- ✅ 如果用自定义域名，CNAME 指向 `ermingpei.github.io`

---

## 🎯 **推荐的最终架构**

### 阶段1：现在（免费启动）

```
域名架构：
disensor.qubitrhythm.com → GitHub Pages (免费)

Repo 名：
ermingpei/disensor (改名)

品牌：
"DiSensor - A Qubit Rhythm Initiative"
```

### 阶段2：有第一个客户后（$20/年投资）

```
域名架构：
qubitrhythm.com → 母公司官网
disensor.ai → DiSensor (主域名)
api.disensor.ai → DiSensor API

或者保持子域名：
disensor.qubitrhythm.com (如果您喜欢统一品牌)
```

---

## 🚀 **立即行动清单**

### 今天（30分钟）：

- [ ] 修改 `index.html` 改为 Edmonton 坐标和数据
- [ ] GitHub repo 改名为 `disensor`
- [ ] 重新推送代码

### 明天（1小时）：

- [ ] 设置 `disensor.qubitrhythm.com` 子域名
- [ ] 在 DNS 添加 CNAME 记录
- [ ] 在 GitHub Pages 设置自定义域名

### 未来（有客户后）：

- [ ] 评估是否购买 `disensor.ai`
- [ ] 或保持 `disensor.qubitrhythm.com`（更统一）

---

## 💡 **我的最终建议**

**品牌架构：**
```
Qubit Rhythm Labs (母公司)
 ↓ 孵化项目
DiSensor (环境监测网络)
```

**域名策略：**
```
启动阶段（现在）：
disensor.qubitrhythm.com (免费)

增长阶段（有客户后）：
disensor.ai (主域名, $20/年)
** 保留 disensor.qubitrhythm.com 作为备用
```

**Repo 命名：**
```
ermingpei/disensor (公开的网站)
ermingpei/sensor-sentinel (私密的完整项目)
```

**隐私保护：**
```
使用 Cloudflare Pages 或自定义域名
完全隐藏 GitHub 用户名
```

---

需要我帮您：
1. 修复 index.html 的 Edmonton 数据吗？
2. 创建一个修改 repo 名称的步骤指南吗？
3. 设置 disensor.qubitrhythm.com 的 DNS 配置吗？
