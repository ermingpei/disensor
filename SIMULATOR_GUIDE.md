# 模拟器开发指南

## ✅ 已自动打开 iOS 模拟器

我已经为您启动了 iOS 模拟器（iPhone 16 Plus）。

---

## 🚀 快速开始

### 在模拟器上运行 App

```bash
# iOS 模拟器（推荐用于UI开发）
flutter run -d "iPhone 16 Plus"

# 或者让 Flutter 自动选择模拟器
flutter run
```

---

## 💡 开发工作流建议

### UI 调整时使用模拟器
- ✅ **修改颜色、字体、布局** → 模拟器即时看效果
- ✅ **测试导航、动画** → 模拟器足够
- ✅ **调试逻辑错误** → 模拟器更快
- ⏱ **编译时间**：模拟器 ~10秒 vs 真机 ~40秒

### 真机测试时机
- 📍 **需要GPS定位** → 真机
- 🌡️ **需要气压计/陪音传感器** → 真机
- 🎯 **重要里程碑/发布前** → 真机全面测试
- 📊 **性能测试** → 真机

---

## 🎮 模拟器功能

### 模拟位置
```bash
# 在模拟器菜单中：
Features → Location → Custom Location...
# 输入经纬度：53.5461, -113.4938 (Edmonton)
```

### 热重载（Hot Reload）
```bash
# 在 flutter run 运行时，按键：
r - 热重载（保留状态）
R - 热重启（重置状态）
q - 退出
```

---

## 🔄 完整工作流示例

### 场景：修改Dashboard颜色

```bash
# 1. 启动模拟器
flutter run

# 2. 修改代码（例如把背景色从黑色改为深蓝）
# lib/features/debug_dashboard.dart
backgroundColor: Color(0xFF1A1A2E)  // 改这里

# 3. 在终端按 "r" 热重载
# 立即看到效果，无需重新编译！

# 4. 满意后，再推送到真机测试
flutter run -d 00008101-000A60A60E11001E
```

---

## 📱 当前可用设备

根据 `flutter devices` 的输出：

**模拟器：**
- ✅ iPhone 16 Plus (simulator) - **推荐用于开发**

**真机：**
- iPhone XII (wireless)
- iPhone 12 (wireless)
- SM A037W (Android, 需要USB连接)

---

## 🛠 传感器 Mock 策略

在模拟器上，真实传感器不可用。我们已经在代码中做了 fallback：

```dart
// core/sensor_manager.dart 已经包含：
try {
  _pressureSub = barometerEventStream().listen(...);
} catch (e) {
  _startMockPressure(); // 自动启用 Mock 数据
}
```

**模拟器上的行为：**
- 气压：自动生成 1013 ± 5 hPa
- 噪音：可能报错但不影响UI
- GPS：可以手动设置位置

---

## 💰 时间成本对比

| 操作 | 模拟器 | iPhone XII 真机 |
|------|--------|----------------|
| 冷启动编译 | 15秒 | 45秒 |
| 热重载 | 1秒 | 3秒 |
| 安装APK | - | 10秒 |
| UI调试循环 | 5次/分钟 | 1次/分钟 |

**结论：UI开发用模拟器可以节省 80% 时间！**

---

## 🎯 建议的开发节奏

### 第1阶段：UI打磨（100% 模拟器）
- 修复黑屏问题 ✅
- 调整颜色、字体、间距
- 完善动画
- 布局响应式测试

### 第2阶段：功能测试（80% 模拟器）
- 导航流程
- 状态管理
- 积分计算逻辑

### 第3阶段：传感器集成（50% 真机）
- GPS 定位
- 气压计读数
- 噪音采集

### 第4阶段：发布前（100% 真机）
- 全功能测试
- 性能测试
- 多设备兼容性

---

## 🚨 常见问题

### Q: 模拟器上 GPS 不工作？
A: 模拟器菜单 → Features → Location → Custom Location

### Q: 热重载后状态丢失？
A: 用 `r`（小写）而不是 `R`（大写）

### Q: 模拟器卡顿？
A: 
```bash
# 重启模拟器
killall Simulator
open -a Simulator
```

---

## ✅ 现在您可以

1. 在终端运行：`flutter run`
2. Flutter 会自动选择 iPhone 16 Plus 模拟器
3. 修改代码后按 `r` 立即看到效果
4. 满意后再推送到真机验证

**准备好了吗？运行 `flutter run` 开始开发！**
