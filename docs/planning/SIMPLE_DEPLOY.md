# 超简单部署方案 - GitHub Pages (5分钟完成)

## 🚀 为什么选择 GitHub Pages？

✅ **完全免费** - 永久免费托管
✅ **无需登录验证码** - 用 GitHub 账号就行
✅ **自动 HTTPS** - 安全加密
✅ **稳定可靠** - GitHub 的基础设施

---

## 📝 部署步骤（跟着做）

### Step 1: 准备 GitHub 仓库（2分钟）

```bash
cd /Users/erming/AI/pooling/sensor-sentinel

# 初始化 git（如果还没有）
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit - Qubit Rhythm launch"
```

### Step 2: 创建 GitHub 仓库

1. 浏览器访问：https://github.com/new
2. Repository name: `qubit-rhythm` 或 `disensor`
3. 设置为 **Public**
4. **不要勾选** "Initialize with README"（因为我们已经有文件了）
5. 点击 "Create repository"

### Step 3: 推送代码

```bash
# 替换成你的 GitHub 用户名
git remote add origin https://github.com/YOUR_USERNAME/qubit-rhythm.git

# 推送
git branch -M main
git push -u origin main
```

### Step 4: 启用 GitHub Pages

1. 在 GitHub repo 页面，点击 **Settings**
2. 左侧菜单找到 **Pages**
3. Source: 选择 **Deploy from a branch**
4. Branch: 选择 **main**，文件夹选择 **/dashboard**
5. 点击 **Save**
6. 等待 30-60 秒

### Step 5: 访问网站

你的网站地址：
```
https://YOUR_USERNAME.github.io/qubit-rhythm/
```

**就这么简单！** 🎉

---

## 🎯 后续设置（可选）

### 绑定自定义域名（qubitrhythm.com）

如果想用 qubitrhythm.com 而不是 GitHub 的域名：

1. **在 GitHub Pages 设置中：**
   - Custom domain: 输入 `qubitrhythm.com`
   - 勾选 "Enforce HTTPS"

2. **在域名注册商（如 Namecheap）：**
   - DNS 设置 → 添加 A 记录：
   ```
   Type: A
   Host: @
   Value: 185.199.108.153
   ```
   - 再添加 3 个 A 记录：
   ```
   185.199.109.153
   185.199.110.153
   185.199.111.153
   ```
   - 添加 CNAME 记录：
   ```
   Type: CNAME
   Host: www
   Value: YOUR_USERNAME.github.io
   ```

3. 等待 DNS 生效（5-30分钟）

---

## 🔄 更新网站

以后如果修改了代码，只需：

```bash
cd /Users/erming/AI/pooling/sensor-sentinel
git add .
git commit -m "Update website"
git push

# GitHub Pages 会自动重新部署（1-2分钟）
```

---

## ⚡ Supabase 配置

记得更新 `dashboard/index.html` 中的 Supabase 配置：

```javascript
// 找到这两行，替换成你的实际值
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key-here';
```

获取方式：
1. 登录 https://supabase.com
2. 选择你的项目
3. Settings → API
4. 复制 URL 和 anon/public key

---

## 🎊 完成后的效果

**你会拥有：**
- ✅ 专业的网站：https://YOUR_USERNAME.github.io/qubit-rhythm/
- ✅ 实时数据展示（从 Supabase）
- ✅ Waitlist 注册表单
- ✅ 可以发给客户的 Demo 链接

**总成本：** $0
**总时间：** 5 分钟

---

## 🆚 GitHub Pages vs Vercel

| 特性 | GitHub Pages | Vercel |
|------|--------------|--------|
| 价格 | 免费 | 免费（有限制） |
| 设置难度 | ⭐⭐ 简单 | ⭐⭐⭐ 需要验证码 |
| 部署速度 | 1-2分钟 | 30秒 |
| 自定义域名 | ✅ 支持 | ✅ 支持 |
| HTTPS | ✅ 自动 | ✅ 自动 |
| 分析功能 | ❌ | ✅ |

**结论：对于你的需求，GitHub Pages 完全够用！**

---

## 🚨 如果还是想用 Vercel

重新运行：
```bash
cd /Users/erming/AI/pooling/sensor-sentinel/dashboard
npx vercel login

# 会生成新的验证码
# 这次在 1 分钟内输入（验证码会过期）
```

但我强烈建议先用 GitHub Pages，它更简单可靠！
