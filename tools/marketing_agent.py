import time
import random
import feedparser
import ssl

# 解决旧版 Python SSL 验证问题 (如果遇到)
if hasattr(ssl, '_create_unverified_context'):
    ssl._create_default_https_context = ssl._create_unverified_context

# 目标板块 (RSS URL)
SUBREDDITS = [
    'https://www.reddit.com/r/passiveincome/new/.rss',
    'https://www.reddit.com/r/beermoney/new/.rss',
    'https://www.reddit.com/r/androidapps/new/.rss',
    'https://www.reddit.com/r/DePIN/new/.rss'
]

# 关键词库
KEYWORDS = [
    'passive income app',
    'earn money android',
    'honeygain',
    'helium mobile',
    'depin',
    'wifi map',
    'mining on phone',
    'side hustle'
]

# 排除常见无关词 (垃圾过滤)
EXCLUDE_WORDS = [
    'survey', 'casino', 'gamble', 'betting', 'referral link'
]

# 预设回复模板 (模拟 GPT 生成)
REPLY_TEMPLATES = [
    """[Reply Draft 1]
    "Hey, if you're looking for passive apps on Android, check out **DiSensor**. 
    It mines crypto by mapping WiFi & environmental data. Doesn't drain battery. 
    Still in Beta." """,
    
    """[Reply Draft 2]
    "Have you tried **DiSensor**? It's a new DePIN project competing with Helium. 
    You earn points for contributing signal data. Early stage but looks promising." """
]

class RSSMarketingAgent:
    def __init__(self):
        print("🤖 Initializing RSS Social Listening Agent...")
        self.seen_posts = set() # 简单的去重缓存 (内存中)

    def run_loop(self, interval=60):
        """主循环"""
        print(f"📡 Monitoring {len(SUBREDDITS)} subreddits via RSS...")
        
        while True:
            for url in SUBREDDITS:
                self._check_feed(url)
            
            print(f"😴 Sleeping for {interval}s...")
            time.sleep(interval)

    def _check_feed(self, url):
        try:
            print(f"🔍 Checking: {url}")
            feed = feedparser.parse(url)
            
            if feed.bozo:
                print(f"⚠️ RSS Parse Error: {feed.bozo_exception}")
                return

            for entry in feed.entries:
                # 唯一ID去重
                if entry.id in self.seen_posts:
                    continue
                
                self.seen_posts.add(entry.id)
                self._analyze_post(entry)

        except Exception as e:
            print(f"❌ Error checking feed: {e}")

    def _analyze_post(self, post):
        """分析内容相关性"""
        title = post.get('title', '').lower()
        # RSS 的 description 通常是 HTML，这里简化处理，只看 title 往往足够精准
        # content = post.get('description', '').lower() 
        
        full_text = title 

        # 1. 排除垃圾
        for bad_word in EXCLUDE_WORDS:
            if bad_word in full_text:
                return

        # 2. 匹配关键词
        start_mining = False
        matched_kw = []
        for kw in KEYWORDS:
            if kw in full_text:
                start_mining = True
                matched_kw.append(kw)
        
        if start_mining:
            self._notify_developer(post, matched_kw)

    def _notify_developer(self, post, matched_kw):
        """发现机会！"""
        print("\n" + "="*50)
        print(f"🔔 OPPORTUNITY DETECTED! [Keywords: {matched_kw}]")
        print(f"📌 Subreddit: {post.get('category', 'Unknown')}") # 有些RSS不带category
        print(f"📄 Title: {post.title}")
        print(f"🔗 Link: {post.link}")
        print("-" * 20)
        print("💡 Suggested Action: Post this reply:")
        print(random.choice(REPLY_TEMPLATES))
        print("="*50 + "\n")

if __name__ == "__main__":
    agent = RSSMarketingAgent()
    try:
        # 只跑一次演示，避免卡住终端。实际使用可以去掉 break 让它 while True 跑
        # agent.run_loop() 
        
        # 演示模式：只扫描一次
        print("🚀 One-time scan started...")
        for url in SUBREDDITS:
            agent._check_feed(url)
        print("✅ Scan complete.")
        
    except KeyboardInterrupt:
        print("\n🛑 Agent stopped.")
