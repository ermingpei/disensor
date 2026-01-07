# GitHub 认证问题修复指南

## 🔑 问题：GitHub 不再支持密码登录

**错误原因：**
```
remote: Invalid username or token. Password authentication is not supported
```

GitHub 已经停止支持密码认证，必须使用以下方式之一：
1. Personal Access Token (PAT) - 推荐，最简单
2. SSH Key

---

## ✅ **方案1：使用 Personal Access Token（推荐）**

### Step 1: 生成 GitHub Token

1. **访问：** https://github.com/settings/tokens
2. 点击 **"Generate new token"** → **"Generate new token (classic)"**
3. 填写信息：
   - Note: `Qubit Rhythm Deployment`
   - Expiration: `90 days`（或 `No expiration` 如果您不想定期更新）
   - 勾选权限：
     - ✅ `repo` (完整的 repo 访问权限)
     - ✅ `workflow` (如果需要 GitHub Actions)
4. 拉到底部，点击 **"Generate token"**
5. **重要：** 复制显示的 token（类似 `ghp_xxxxxxxxxxxx`），离开页面后就看不到了！

### Step 2: 修复 remote 并推送

```bash
cd /tmp/qubit-website

# 1. 删除旧的 remote
git remote remove origin

# 2. 添加新的 remote
git remote add origin https://github.com/ermingpei/qubitrhythm.git

# 3. 推送（会提示输入用户名和密码）
git push -u origin main

# 当提示时：
# Username: ermingpei
# Password: [粘贴刚才复制的 token，不是密码！]
```

### Step 3: 保存凭据（避免每次输入）

```bash
# macOS 使用 Keychain 保存
git config --global credential.helper osxkeychain

# 下次推送时 macOS 会自动记住 token
```

---

## 🔐 **方案2：使用 SSH Key（一劳永逸）**

如果您已经有 SSH key，这是最简单的方式。

### 检查是否有 SSH key

```bash
ls -la ~/.ssh

# 如果看到 id_rsa.pub 或 id_ed25519.pub，说明您已经有了
# 如果没有，需要生成一个
```

### 生成新的 SSH key（如果没有）

```bash
ssh-keygen -t ed25519 -C "ermingpei@github.com"

# 提示时按 Enter（使用默认位置）
# 可以设置密码，也可以留空（按 Enter 跳过）
```

### 添加 SSH key 到 GitHub

```bash
# 复制 public key
cat ~/.ssh/id_ed25519.pub | pbcopy

# 或者手动打印并复制
cat ~/.ssh/id_ed25519.pub
```

1. 访问：https://github.com/settings/keys
2. 点击 **"New SSH key"**
3. Title: `MacBook Air`
4. Key: 粘贴刚才复制的内容
5. 点击 **"Add SSH key"**

### 使用 SSH URL 推送

```bash
cd /tmp/qubit-website

# 删除旧的 remote
git remote remove origin

# 添加 SSH remote（注意是 git@ 开头）
git remote add origin git@github.com:ermingpei/qubitrhythm.git

# 推送（不需要密码！）
git push -u origin main
```

---

## 🎯 **快速对比**

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| Personal Access Token | 简单，5分钟完成 | Token 可能过期 | ⭐⭐⭐⭐⭐ |
| SSH Key | 永久有效，更安全 | 初次设置稍复杂 | ⭐⭐⭐⭐ |

---

## 🚀 **推荐操作（最快）**

### 现在就做（5分钟）：

1. **生成 Token：**
   - 访问 https://github.com/settings/tokens
   - 点击 "Generate new token (classic)"
   - 勾选 `repo`
   - 复制 token（例如 `ghp_1234abcd...`）

2. **运行命令：**
   ```bash
   cd /tmp/qubit-website
   git remote remove origin
   git remote add origin https://github.com/ermingpei/qubitrhythm.git
   git push -u origin main
   
   # 提示时：
   Username: ermingpei
   Password: [粘贴 token]
   ```

3. **保存凭据：**
   ```bash
   git config --global credential.helper osxkeychain
   ```

---

## ✅ **成功后的下一步**

### 启用 GitHub Pages

1. 访问：https://github.com/ermingpei/qubitrhythm
2. Settings → Pages
3. Source:
   - Branch: **main**
   - Folder: **/ (root)**
4. Save

**网站地址：**
```
https://ermingpei.github.io/qubitrhythm/
```

等待 1-2 分钟，网站就上线了！

---

## 🆘 **如果遇到问题**

### "remote origin already exists" 错误
```bash
git remote remove origin
# 然后重新添加
```

### "Permission denied" 错误（SSH）
```bash
# 确保 SSH agent 运行
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### "fatal: refusing to merge unrelated histories"
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

---

## 📝 **TOKEN 安全提示**

✅ **可以做：**
- 保存在 macOS Keychain
- 有效期设置为 90 天自动过期
- 只给必要的权限（repo）

❌ **不要做：**
- 分享给别人
- 提交到代码库
- 写在公开的地方

---

**准备好了吗？** 

请按照上面的步骤：
1. 先生成 Token
2. 告诉我生成好了
3. 我会帮您完成推送并启用 Pages

或者，您也可以直接运行命令并告诉我结果！
