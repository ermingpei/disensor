#!/bin/bash

# Sensor Sentinel 环境一键清理脚本 (Cleanup Script)
# 警告：运行此脚本将移除本 Session 安装的 Flutter, Android SDK, Java 等所有开发工具。

echo "⚠️ 准备开始清理开发环境..."

# 1. 清理本地项目编译出的临时文件
echo "--- 正在清理本地项目缓存 ---"
if [ -d "/Users/erming/AI/pooling/sensor-sentinel" ]; then
    cd /Users/erming/AI/pooling/sensor-sentinel
    flutter clean 2>/dev/null
fi

# 2. 清理 Xcode 产生的超大缓存 (DerivedData)
echo "--- 正在清理 Xcode 编译缓存 (约数 GB) ---"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Developer/Xcode/Archives/*

# 3. 卸载通过 Homebrew 安装的开发软件
echo "--- 正在卸载核心开发工具 ---"
brew uninstall --cask flutter
brew uninstall --cask android-commandlinetools
brew uninstall --cask temurin
brew uninstall cocoapods

# 4. 清理残留的 Android SDK 库文件
echo "--- 正在清理 Android SDK 库文件 ---"
rm -rf /opt/homebrew/share/android-commandlinetools

# 5. 清理 CocoaPods 缓存
echo "--- 正在清理 CocoaPods 缓存 ---"
rm -rf ~/.cocoapods
rm -rf ~/Library/Caches/CocoaPods

# 6. 清理 Homebrew 下载的所有安装包残余
echo "--- 正在清理 Homebrew 存储池 ---"
brew cleanup -s

echo "✅ 清理完成！你的磁盘空间已回收。"
