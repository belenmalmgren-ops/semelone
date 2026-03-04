# 小方字典 - Android 和 Windows 版本构建说明

## ⚠️ 当前环境限制

您当前在 **macOS** 上，存在以下限制：

| 平台 | 状态 | 原因 |
|------|------|------|
| Android | ❌ 需要 Android SDK | Java/Android SDK 未安装 |
| Windows | ❌ 无法跨平台编译 | 必须在 Windows 主机上构建 |

---

## 📱 方案一：Android APK 构建

### 方法 A：在 macOS 上配置 Android SDK（推荐）

#### 步骤 1：安装 Android Command Line Tools

```bash
# 1. 下载 Android 命令行工具
cd ~/Library/Android
mkdir -p cmdline-tools
cd cmdline-tools

# 2. 下载（使用浏览器下载以下 URL）
# https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip

# 3. 解压后重命名
# 解压到 cmdline-tools/latest/ 目录

# 4. 添加到环境变量（~/.zshrc）
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc

# 5. 接受许可并安装 SDK
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

#### 步骤 2：构建 APK

```bash
cd /Volumes/E/daima/openclaw/workspace/xiaofang_dict

# 调试版本
flutter build apk --debug

# 发布版本（需要签名）
flutter build apk --release

# 输出位置
# build/app/outputs/flutter-apk/app-release.apk
```

### 方法 B：使用在线构建服务

#### 1. Codemagic（免费 CI/CD）
```yaml
# codemagic.yaml
workflows:
  android-workflow:
    name: Android Build
    max_build_duration: 30
    environment:
      flutter: stable
    scripts:
      - flutter pub get
      - flutter build apk --release
    artifacts:
      - build/app/outputs/flutter-apk/*.apk
```

#### 2. GitHub Actions
```yaml
# .github/workflows/android.yml
name: Android Build
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

### 方法 C：在 Windows 上构建（如果有 Windows 电脑）

1. 在 Windows 上安装 Flutter
2. 克隆项目代码
3. 运行 `flutter build apk --release`
4. 将 APK 文件传输到 macOS

---

## 🪟 方案二：Windows 安装包构建

### 必须在 Windows 上构建

Windows 应用**无法**在 macOS 上交叉编译，必须：

#### 选项 1：使用 Windows 电脑
1. 在 Windows 上安装 Flutter
2. 安装 Visual Studio 2022（社区版）
   - 勾选"使用 C++ 的桌面开发"
   - 安装 Windows 10/11 SDK
3. 克隆项目代码
4. 运行：
   ```powershell
   flutter build windows --release
   ```

#### 选项 2：使用 Windows 虚拟机（Parallels/VMware）
1. 在 macOS 上安装 Parallels Desktop 或 VMware Fusion
2. 安装 Windows 11 ARM 虚拟机
3. 在虚拟机中安装 Flutter 和 Visual Studio
4. 构建 Windows 版本

#### 选项 3：使用云构建服务
- **Codemagic**：支持 Windows 构建（付费）
- **GitHub Actions**：使用 Windows runner
  ```yaml
  # .github/workflows/windows.yml
  name: Windows Build
  on: push
  jobs:
    build:
      runs-on: windows-latest
      steps:
        - uses: actions/checkout@v4
        - uses: subosito/flutter-action@v2
        - run: flutter pub get
        - run: flutter build windows --release
        - uses: actions/upload-artifact@v4
          with:
            name: windows-build
            path: build/windows/runner/Release/
  ```

---

## 📦 Windows 安装包制作

构建完成后，使用 Inno Setup 制作安装包：

```innosetup
; setup.iss
[Setup]
AppName=小方字典
AppVersion=1.0.0
DefaultDirName={pf}\XiaoFangDict
DefaultGroupName=小方字典
OutputDir=output

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\小方字典"; Filename: "{app}\小方字典.exe"
```

---

## 🚀 最快方案（无额外环境）

### 使用 Web 版本 + 打包为 PWA

小方字典已支持 Web，可直接使用：

1. **部署 Web 版本**
   ```bash
   flutter build web --release
   # 部署到 GitHub Pages / Vercel / Netlify
   ```

2. **用户安装为 PWA**
   - Chrome/Edge: 地址栏出现安装图标
   - 可离线使用，类似原生应用
   - 支持 Android、Windows、macOS、iOS

---

## 📊 构建输出对比

| 方式 | 优点 | 缺点 | 时间 |
|------|------|------|------|
| 原生 APK | 性能最佳 | 需要 SDK 配置 | ~30 分钟设置 |
| GitHub Actions | 无需本地环境 | 需要 GitHub | ~10 分钟构建 |
| Web/PWA | 即刻可用 | 功能略有限 | ~2 分钟部署 |

---

## 📞 快速帮助

**需要 Android APK?**
```bash
# 最简单的方案：使用 GitHub Actions
# 1. 创建 .github/workflows/android.yml
# 2. 推送到 GitHub
# 3. 在 Actions 标签下载 APK
```

**需要 Windows 安装包?**
```bash
# 方案 1: 使用 GitHub Actions (Windows runner)
# 方案 2: 在 Windows 电脑上构建
# macOS 无法直接生成 Windows 可执行文件
```

---

## 🔗 相关资源

- [Flutter Android 部署文档](https://docs.flutter.dev/deployment/android)
- [Flutter Windows 部署文档](https://docs.flutter.dev/deployment/windows)
- [Codemagic Flutter CI](https://codemagic.io/flutter/)
- [GitHub Actions for Flutter](https://github.com/marketplace?query=flutter)
