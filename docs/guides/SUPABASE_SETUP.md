# Supabase 数据库表设置

## 创建 Waitlist 表

在 Supabase Dashboard 中运行以下 SQL：

```sql
-- 1. 创建 waitlist 表
CREATE TABLE waitlist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL UNIQUE,
    interest TEXT NOT NULL, -- 'data-api', 'contributor', 'both'
    organization TEXT,
    use_case TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    contacted BOOLEAN DEFAULT FALSE,
    notes TEXT
);

-- 2. 创建索引
CREATE INDEX idx_waitlist_created ON waitlist(created_at DESC);
CREATE INDEX idx_waitlist_interest ON waitlist(interest);

-- 3. 设置 Row Level Security (RLS)
ALTER TABLE waitlist ENABLE ROW LEVEL SECURITY;

-- 4. 允许匿名插入（用于网站表单）
CREATE POLICY "Allow anonymous inserts" ON waitlist
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- 5. 只有认证用户可以查看（你自己查看 waitlist）
CREATE POLICY "Authenticated users can view" ON waitlist
    FOR SELECT
    TO authenticated
    USING (true);
```

## 更新网站的 Supabase 配置

在 `dashboard/index.html` 中，找到：
```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

替换为你的 Supabase 项目信息：
1. 登录 Supabase Dashboard
2. 项目设置 → API
3. 复制 URL 和 anon/public key

## 查看 Waitlist 注册

### 方法 1: Supabase Dashboard
1. 进入项目
2. Table Editor → waitlist

### 方法 2: SQL 查询
```sql
-- 查看所有注册
SELECT * FROM waitlist ORDER BY created_at DESC;

-- 统计不同兴趣的人数
SELECT interest, COUNT(*) 
FROM waitlist 
GROUP BY interest;

-- 查看带组织的注册（可能是潜在客户）
SELECT * FROM waitlist 
WHERE organization IS NOT NULL 
  AND interest IN ('data-api', 'both')
ORDER BY created_at DESC;
```

## 自动邮件通知（可选）

使用 Supabase Edge Functions + Resend:

```javascript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { email, interest, organization } = await req.json()
  
  // 发送感谢邮件
  await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from: 'hello@disensor.app',
      to: email,
      subject: 'Welcome to DiSensor Network',
      html: `<p>Thanks for joining the waitlist! We'll contact you soon with early access details.</p>`
    })
  })
  
  // 通知你自己有新注册
  await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from: 'hello@disensor.app',
      to: 'your-email@gmail.com',
      subject: 'New Waitlist Signup!',
      html: `
        <h3>New signup:</h3>
        <p>Email: ${email}</p>
        <p>Interest: ${interest}</p>
        <p>Organization: ${organization || 'N/A'}</p>
      `
    })
  })
  
  return new Response('OK')
})
```
