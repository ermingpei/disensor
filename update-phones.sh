#!/bin/bash

# 定义设备 ID
# 1. iPhone 12 (旧)
IPHONE_12_ID="00008101-001854C61105001E"

# 2. iPhone XII (新)
IPHONE_XII_ID="00008101-000A60A60E11001E"

# 3. Samsung (无线 IP)
SAMSUNG_IP="192.168.1.152:5555"

echo "📱 Sentinel Fleet Commander v2.0 🚀"
echo "================================="

# --- 检查 Android 连接 ---
echo "🔍 Checking Samsung connection..."
ADB_DEVICES=$(adb devices | grep "$SAMSUNG_IP")
if [ -z "$ADB_DEVICES" ]; then
    echo "⚠️ Samsung wireless connection lost. Attempting to reconnect..."
    adb connect $SAMSUNG_IP
else
    echo "✅ Samsung connected ($SAMSUNG_IP)"
fi

# --- 启动所有 Agent ---

# 1. Samsung
echo "🚀 Launching Samsung Agent..."
osascript -e "tell application \"Terminal\" to do script \"cd $(pwd) && echo '📱 SAMSUNG AGENT' && flutter run -d $SAMSUNG_IP\""

# 2. iPhone 12
echo "🚀 Launching iPhone 12 Agent..."
osascript -e "tell application \"Terminal\" to do script \"cd $(pwd) && echo '🍏 iPHONE 12 AGENT' && flutter run -d $IPHONE_12_ID\""

# 3. iPhone XII
echo "🚀 Launching iPhone XII Agent..."
osascript -e "tell application \"Terminal\" to do script \"cd $(pwd) && echo '🍏 iPHONE XII AGENT' && flutter run -d $IPHONE_XII_ID\""

echo "================================="
echo "✅ Deployment commands sent to 3 devices!"
echo "👉 Check the emerging terminal windows."
