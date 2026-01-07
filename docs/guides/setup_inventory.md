# Sensor Sentinel 环境安装清单 (Installation Inventory)

为了自动化 Flutter 开发环境并支持 Android/iOS 双端测试，我们在当前 Session 中安装了以下软件和组件。你可以参照此清单进行清理或审计。

## 1. 系统级软件 (通过 Homebrew 安装)
*   **Flutter SDK**: 核心开发框架。
    *   路径: `/opt/homebrew/Caskroom/flutter`
    *   安装命令: `brew install --cask flutter`
*   **Android Command Line Tools**: 用于 Android 编译和设备管理 (`adb`, `sdkmanager`)。
    *   路径: `/opt/homebrew/share/android-commandlinetools`
    *   安装命令: `brew install --cask android-commandlinetools`
*   **Temurin (OpenJDK 17)**: Android 编译所需的 Java 环境。
    *   路径: `/Library/Java/JavaVirtualMachines/openjdk-17.jdk` (软链接至 `/opt/homebrew`)
    *   安装命令: `brew install --cask temurin`
*   **CocoaPods**: iOS 插件依赖管理工具。
    *   路径: `/opt/homebrew/bin/pod`
    *   安装命令: `brew install cocoapods`

## 2. Android SDK 组件 (消耗较大磁盘空间)
这些组件由 `sdkmanager` 自动下载，用于支持 Android 36 版本：
*   **Android SDK Platform 36**: 约 1GB+
*   **Android Build-Tools 36.1.0**: 约 500MB+
*   **Platform Tools (adb)**: 约 100MB

## 3. iOS 开发产生的缓存 (位于 ~/Library)
*   **Xcode DerivedData**: 编译过程中产生的中间文件（可能很大，可随时删除）。
    *   路径: `~/Library/Developer/Xcode/DerivedData`
*   **iOS DeviceSupport**: 连接真机后产生的支持文件。
    *   路径: `~/Library/Developer/Xcode/iOS DeviceSupport`
*   **CocoaPods Cache**:
    *   路径: `~/Library/Caches/CocoaPods`

## 4. 本地项目文件
*   **Sensor Sentinel App**: `/Users/erming/AI/pooling/sensor-sentinel`

---

# ⚠️ 磁盘空间“假性满额”解决方案

即使你看到有 58GB 空闲，Xcode 报错“空间不足”通常是因为 macOS 的 **“可清除空间 (Purgeable Space)”** 占据了物理扇区，但 Xcode 无法强制释放它们。

### 推荐清理步骤 (可释放 10GB+ 空间):

1.  **清理 Xcode 编译缓存** (安全且有效):
    `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
2.  **清理 CocoaPods 缓存**:
    `pod cache clean --all`
3.  **清理 Homebrew 下载包**:
    `brew cleanup`
