## 诊断清单 (Diagnostic Checklist)

### 问题 1: 大头针不移动

**请按以下步骤测试：**

1. **启动采样**
   - 打开 App
   - 点击 "START Sensing" 按钮
   - 确认按钮变为绿色/显示 "STOP"

2. **检查控制台日志**
   - 在 Xcode 或 Android Studio 的控制台查找以下日志：
   ```
   📍 Location Stream Update: ...
   🔄 Poll Update: ...
   ```
   - **如果看不到这些日志** → 位置服务没有启动
   - **如果看到日志** → 位置正在更新，但地图没有监听

3. **测试地图**
   - 点击地图按钮进入地图页面
   - 观察右下角的 Pin 颜色：
     - **绿色** = 正在采样（应该随您移动而移动）
     - **红色** = 未采样（不会移动）

4. **移动测试**
   - 在房间内走动至少 3-5 米
   - 每 3 秒检查一次地图
   - 如果还是不动，请截图控制台输出发给我

---

### 问题 2: iPhone XII Overflow

**已修复方法：**
- 缩短了文本："Go to Empty Hex, walk/bike, stay 5+ min"
- 减小了字体：11pt (from 13pt)
- 如果还溢出，可以手动编辑文件进一步缩短

**临时解决方案：**
打开 `lib/features/hex_map_page.dart`，找到第 268 行附近：
```dart
"Action: Go to an Empty Hex via walking/biking and stay for 5+ min."
```
改为：
```dart
"Walk to empty area, stay 5+ min"
```

---

### 问题 3: Pods_Runner Not Found

**已执行修复：**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

**如果问题持续：**
1. 关闭 Xcode
2. 运行：
```bash
cd /Users/erming/AI/pooling/sensor-sentinel
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
open ios/Runner.xcworkspace  # 注意：打开 .xcworkspace 而不是 .xcodeproj
```

3. 在 Xcode 中：
   - Product → Clean Build Folder (⇧⌘K)
   - Product → Build (⌘B)

---

### 最可能的根本原因

**大头针不动：**
- 您可能点击了地图按钮，但没有先点击 "START Sensing"
- 解决方案：必须先启动采样，然后地图才会实时更新

**建议测试流程：**
1. 启动 App → 点击 "START Sensing"
2. 等待 3 秒（让位置服务初始化）
3. 点击地图按钮
4. 观察 Pin 是否为绿色
5. 走动 3-5 米，等待 3 秒
6. 检查 Pin 是否移动

如果按这个流程还是不工作，请告诉我控制台显示了什么日志！
