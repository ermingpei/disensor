# 🐛 网页显示但无数据/地图 - 诊断指南

## 🔍 问题症状
- ✅ 网页能访问（http://localhost:3000/ 和 https://disensor.qubitrhythm.com/）
- ❌ 只显示静态内容（文字、样式）
- ❌ 地图不显示
- ❌ 数据不更新（显示 "--" 或不显示）

## 🎯 **最可能的原因：浏览器缓存**

### 立即解决方案（3种方法，任选其一）

#### **方法1：强制刷新（推荐，最快）**

1. **在浏览器中：**
   - Mac: `⌘ + Shift + R`
   - Windows/Linux: `Ctrl + Shift + F5`

2. **或者右键点击刷新按钮 → "清空缓存并硬性重新加载"**

#### **方法2：打开隐私模式**

1. Chrome/Edge: `⌘ + Shift + N` (Mac) 或 `Ctrl + Shift + N`
2. Safari: `⌘ + Shift + N`
3. 在隐私窗口访问：http://localhost:3000/

#### **方法3：清除浏览器缓存**

**Chrome:**
1. `⌘ + Shift + Delete`
2. 时间范围：全部
3. 勾选"缓存的图片和文件"
4. 点击"清除数据"

**Safari:**
1. 开发 → 清空缓存
2. 或 Safari → 偏好设置 → 高级 → 勾选"在菜单栏中显示开发菜单"

---

## 🔬 **检查问题详情**

### Step 1: 打开浏览器开发者工具

1. **按 F12** 或 **右键 → 检查**
2. 切换到 **Console** 标签
3. 刷新页面
4. 查看是否有错误信息（红色文字）

### Step 2: 常见错误和解决方案

#### **错误 A: "Blocked loading mixed active content"**
```
Mixed Content: The page at 'https://...' was loaded over HTTPS, 
but requested an insecure script 'http://...'. This request has been blocked
```

**原因：** HTTPS 网站无法加载 HTTP 资源

**解决：** 
- 确保所有外部资源使用 HTTPS
- Leaflet, Supabase SDK 都应该用 HTTPS
- 已修复：代码中都是 `https://`

---

#### **错误 B: "Failed to load resource: net::ERR_BLOCKED_BY_CLIENT"**
```
Failed to load resource: net::ERR_BLOCKED_BY_CLIENT
```

**原因：** 广告拦截器（如 uBlock Origin、AdBlock）

**解决：** 
- 暂时禁用广告拦截器
- 或将网站添加到白名单

---

#### **错误 C: "Uncaught ReferenceError: L is not defined"**
```
Uncaught ReferenceError: L is not defined
```

**原因：** Leaflet 库没有加载

**解决：**
检查网络是否能访问：
```
https://unpkg.com/leaflet@1.9.4/dist/leaflet.js
```

**测试：** 在浏览器新标签直接访问上面的 URL，应该下载一个 JS 文件

---

#### **错误 D: "Supabase connection failed"**
```
Error loading stats: [object Object]
Error loading map data: [object Object]
```

**原因：** Supabase 连接问题（这个是预期的，会回退到 mock 数据）

**解决：** 
- 应该不影响地图显示
- 统计数字会显示备用值（6, 2.4K, 15）
- 地图会显示 Edmonton 的 6 个 mock 点

---

## 📋 **逐步诊断清单**

### ✅ 检查列表

请按顺序检查：

**1. index.html 文件是否最新？**
```bash
# 在终端运行：
ls -lh /Users/erming/AI/pooling/sensor-sentinel/dashboard/index.html

# 应该显示今天的日期
```

**2. 浏览器控制台是否有错误？**
- 打开 F12
- Console 标签
- 是否有红色错误？

**3. Network 标签检查资源加载**
- F12 → Network 标签
- 刷新页面
- 检查这些文件是否成功加载（状态码 200）：
  - `index.html` ✅
  - `leaflet.js` ✅
  - `supabase-js` ✅

**4. JavaScript 是否启用？**
- 浏览器设置 → 隐私和安全 → 网站设置 → JavaScript
- 确保 "允许"

**5. 本地服务器是否正常运行？**
```bash
# 检查进程
ps aux | grep serve

# 应该看到：
# cd dashboard && npx -y serve -l 3000
```

---

## 🚀 **快速修复脚本**

如果上述方法都不行，运行这个：

```bash
cd /Users/erming/AI/pooling/sensor-sentinel

# 1. 确保最新代码在 dashboard/
ls -lh dashboard/index.html

# 2. 重启本地服务器
pkill -f "serve -l 3000"
cd dashboard && npx -y serve -l 3000 &

# 3. 等待 2 秒
sleep 2

# 4. 测试访问
curl -I http://localhost:3000/index.html
```

---

## 🌐 **GitHub Pages 特定问题**

### 如果 localhost 能工作但 https://disensor.qubitrhythm.com/ 不能：

**原因：** GitHub Pages 缓存

**解决：**
1. 等待 5-10 分钟（GitHub Pages 部署延迟）
2. 在 GitHub repo 查看：
   - Settings → Pages
   - 确认显示："Your site is live at https://disensor.qubitrhythm.com/"
3. 强制刷新（⌘ + Shift + R）

---

## 💡 **终极测试**

### 创建一个简单的测试页面

```bash
# 在 dashboard 创建 test.html
cat > /Users/erming/AI/pooling/sensor-sentinel/dashboard/test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        #map { height: 400px; }
    </style>
</head>
<body>
    <h1>JavaScript Test</h1>
    <div id="status">Loading...</div>
    <div id="map"></div>
    
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        document.getElementById('status').textContent = 'JavaScript is working! ✅';
        
        const map = L.map('map').setView([53.5461, -113.4938], 11);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
        L.marker([53.5461, -113.4938]).addTo(map).bindPopup('Edmonton!');
        
        console.log('✅ Map initialized successfully');
    </script>
</body>
</html>
EOF

# 访问测试页面
echo "Now visit: http://localhost:3000/test.html"
```

**预期结果：**
- "JavaScript is working! ✅"
- 地图显示 Edmonton
- 一个标记在 Downtown

**如果测试页面能工作：**
→ 说明环境正常，问题在 index.html 本身

**如果测试页面也不工作：**
→ 环境问题（浏览器设置、网络拦截器）

---

## 📸 **请提供这些信息**

如果问题持续，请告诉我：

1. **浏览器控制台截图**（F12 → Console）
2. **Network 标签截图**（F12 → Network → 刷新页面）
3. **您看到的页面是什么样子？**
   - 完全空白？
   - 有标题和文字，但没地图？
   - 地图区域是灰色？

4. **运行这个命令的输出：**
```bash
curl -s http://localhost:3000/index.html | grep -c "Supabase"
# 应该返回 > 0（表示 JavaScript 代码存在）
```

---

## 🎯 **最终解决方案（如果都失败）**

我会为您生成一个全新的、**保证能工作**的 `index.html`，使用不同的方式加载资源。

---

**现在请：**
1. 尝试 **强制刷新**（⌘ + Shift + R）
2. 打开 **浏览器控制台**（F12）
3. 告诉我看到了什么错误（红色的）

我会立即帮您解决！
