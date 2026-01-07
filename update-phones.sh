#!/bin/bash

# 定义设备 ID
# 1. iPhone 12 (旧)
IPHONE_12_ID="00008101-001854C61105001E"

# 2. iPhone XII (新)
IPHONE_XII_ID="00008101-000A60A60E11001E"

# 3. iPhone 14 (Weiting)
IPHONE_14_ID="00008110-000230560252801E"

# 4. Samsung (使用 TLS 连接)
SAMSUNG_ID="adb-R9WT70JXLGK-6lPYEo._adb-tls-connect._tcp"

echo "📱 Sentinel Fleet Commander v2.1 🚀"
echo "================================="

# --- 启动所有 Agent ---

# 1. Samsung
echo "🚀 Launching Samsung Agent..."
osascript -e "tell application \"Terminal\" to do script \"cd $(pwd) && echo '📱 SAMSUNG AGENT' && flutter run -d $SAMSUNG_ID\""

# 2. iPhone 12
echo "🚀 Launching iPhone 12 Agent..."
osascript -e "tell application \"Terminal\" to do script \"cd $(pwd) && echo '🍏 iPHONE 12 AGENT' && flutter run -d $IPHONE_12_ID\""

# 3. iPhone XII
echo "🚀 Launching iPhone XII Agent..."
osascript -e "tell application \"Terminal\" to do script \"cd $(pwd) && echo '🍏 iPHONE XII AGENT' && flutter run -d $IPHONE_XII_ID\""

# 4. iPhone 14
echo "🚀 Launching iPhone 14 Agent..."
osascript -e "tell application \"Terminal\" to do script \"cd $(pwd) && echo '🍏 iPHONE 14 AGENT' && flutter run -d $IPHONE_14_ID\""

echo "================================="
echo "✅ Deployment commands sent to 4 devices!"
echo "👉 Check the emerging terminal windows."
