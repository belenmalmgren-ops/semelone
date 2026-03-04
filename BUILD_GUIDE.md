# 小方字典 - 跨平台构建指南

> 本文档说明如何在不同平台上构建和测试小方字典应用。

---

## 📋 环境要求总览

| 平台 | 必需环境 | 可选工具 |
|------|----------|----------|
| Web | Flutter SDK | Chrome 浏览器 |
| macOS | Xcode (完整版) | - |
| Android | Android SDK + JDK | Android Studio |
| Windows | Visual Studio 2022 | - |
| Linux | GCC + CMake | - |

---

## 🌐 Web 版本（最简单）

### 环境要求
- Flutter SDK 3.0+
- Chrome 浏览器（可选，用于调试）

### 构建步骤
```bash
# 1. 获取依赖
flutter pub get

# 2. 调试运行
flutter run -d chrome

# 3. 发布构建
flutter build web --release
```

### 输出位置
```
build/web/
├── index.html
├── main.dart.js
├── flutter.js
└── assets/
```

### 部署建议
- 可使用任何静态文件托管服务（GitHub Pages、Vercel、Netlify）
- 或使用 Python 快速启动本地服务器：
  ```bash
  cd build/web
  python3 -m http.server 8080
  ```

---

## 🍎 macOS 版本

### 环境要求
- macOS 10.15+
- **Xcode 完整版**（不仅是命令行工具）
- CocoaPods

### 安装 Xcode
```bash
# 从 App Store 下载 Xcode（约 12GB）
# 下载地址：https://apps.apple.com/app/xcode/id497799835

# 安装后设置
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# 同意许可协议
sudo xcodebuild -license accept

# 安装 CocoaPods
sudo gem install cocoapods
```

### 构建步骤
```bash
# 1. 获取依赖
flutter pub get

# 2. 调试运行
flutter run -d macos

# 3. 发布构建
flutter build macos --release
```

### 输出位置
```
build/macos/Build/Products/Release/小方字典.app
```

---

## 📱 Android 版本

### 环境要求
- Android SDK
- JDK 11+
- Android Studio（推荐）

### 安装 Android SDK
```bash
# 方法 1: 使用 Android Studio
# 1. 下载 Android Studio
# 2. 安装时勾选 Android SDK
# 3. 在设置中安装 Android SDK Platform 和 Build Tools

# 方法 2: 命令行安装（高级用户）
sdkmanager "platform-tools" "platforms;android-34"
```

### 配置环境变量
```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### 构建步骤
```bash
# 1. 获取依赖
flutter pub get

# 2. 连接设备或启动模拟器
flutter devices

# 3. 调试运行
flutter run

# 4. 构建调试版 APK
flutter build apk --debug

# 5. 构建发布版 APK
flutter build apk --release
```

### 输出位置
```
build/app/outputs/flutter-apk/
├── app-debug.apk
└── app-release.apk
```

### 安装到手机
```bash
# USB 调试模式下
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🪟 Windows 版本

### 环境要求
- Windows 10/11
- **Visual Studio 2022**（社区版免费）
- Flutter SDK（Windows 版本）

### 安装 Visual Studio
1. 下载 Visual Studio 2022 Community
2. 安装时勾选 **"使用 C++ 的桌面开发"**
3. 确保勾选 **Windows 10/11 SDK**

### 构建步骤
```powershell
# 1. 获取依赖
flutter pub get

# 2. 调试运行
flutter run

# 3. 发布构建
flutter build windows --release
```

### 输出位置
```
build/windows/runner/Release/
├── 小方字典.exe
├── data/
└── flutter_windows.dll
```

### 打包发布
```powershell
# 创建发布文件夹
$releaseDir = "build/windows/runner/Release"
$publishDir = "build/dist/xiaofang_dict_windows"

New-Item -ItemType Directory -Force -Path $publishDir
Copy-Item -Path "$releaseDir\*" -Destination $publishDir -Recurse

# 压缩
Compress-Archive -Path "$publishDir\*" -DestinationPath "build/xiaofang_dict_windows.zip" -Force
```

---

## 🐧 Linux 版本

### 环境要求
- Ubuntu 20.04+ / Fedora 33+ / 其他现代 Linux 发行版
- GCC / Clang
- CMake
- Ninja build

### 安装依赖（Ubuntu/Debian）
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

### 构建步骤
```bash
# 1. 获取依赖
flutter pub get

# 2. 调试运行
flutter run -d linux

# 3. 发布构建
flutter build linux --release
```

### 输出位置
```
build/linux/x64/release/bundle/
├── 小方字典
├── data/
└── lib/
```

---

## 📊 构建对比

| 平台 | 构建时间 | 包大小 | 测试难度 |
|------|----------|--------|----------|
| Web | ~30 秒 | ~5MB | ⭐⭐⭐⭐⭐ |
| macOS | ~2 分钟 | ~50MB | ⭐⭐⭐⭐ |
| Android | ~3 分钟 | ~40MB | ⭐⭐⭐ |
| Windows | ~3 分钟 | ~60MB | ⭐⭐ |
| Linux | ~2 分钟 | ~50MB | ⭐⭐⭐ |

---

## 🔧 常见问题

### Web 版本无法加载
- 检查 `pubspec.yaml` 中的 assets 配置
- 确保使用 `flutter build web` 而非手动复制文件

### macOS 构建失败
- 确认安装了完整版 Xcode（不仅是命令行工具）
- 运行 `sudo xcode-select --reset`

### Android 找不到设备
- 启用手机开发者选项和 USB 调试
- 运行 `adb devices` 检查连接
- 使用 `flutter emulators` 启动模拟器

### Windows 构建缺少 DLL
- 确保安装了 Visual Studio 2022
- 安装 "使用 C++ 的桌面开发" 工作负载

---

## 📦 分发包制作

### macOS
```bash
# 创建 DMG
create-dmg \
  --volname "小方字典" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --app-pos 100 150 \
  --app-drop-link 400 150 \
  "build/xiaofang_dict.dmg" \
  "build/macos/Build/Products/Release/小方字典.app"
```

### Android
```bash
# 构建 AAB（Google Play 发布）
flutter build appbundle --release

# 输出：build/app/outputs/bundle/release/app-release.aab
```

### Windows
```bash
# 使用 Inno Setup 创建安装包
# 或使用简单的 ZIP 打包
```

---

## 📝 更新日志

- **2026-03-04**: 初始版本，支持 Web/macOS
- 后续将添加 Android/Windows/Linux 官方构建

---

## 📞 技术支持

如有问题，请查看：
- Flutter 官方文档：https://docs.flutter.dev
- 项目 Issues: [提交问题](../../issues)
