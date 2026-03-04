# 小方字典 - 云端构建指南

## 📱🪟 一键云端构建 Android 和 Windows 版本

无需在本地安装任何开发环境，所有构建都在 GitHub 云端服务器完成！

---

## 🚀 快速开始（5 分钟）

### 步骤 1：推送到 GitHub

```bash
# 进入项目目录
cd /Volumes/E/daima/openclaw/workspace/xiaofang_dict

# 初始化 git（如果还没有）
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit - 小方字典"

# 在 GitHub 上创建新仓库（访问 https://github.com/new）
# 仓库名：xiaofang-dict
# 可见性：Public 或 Private

# 添加远程仓库（替换为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/xiaofang-dict.git

# 推送代码
git branch -M main
git push -u origin main
```

### 步骤 2：触发自动构建

推送代码后，GitHub Actions 会**自动开始构建**！

查看构建进度：
1. 进入你的 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择 **Android APK Build** 或 **Windows EXE Build**
4. 查看实时日志

### 步骤 3：下载安装包

构建完成后（约 10-15 分钟）：

1. 在 Actions 页面点击已完成的构建记录
2. 滚动到页面底部 **Artifacts** 区域
3. 点击下载：
   - **Android**: `xiaofang_dict-android-release` (约 40-50 MB)
   - **Windows**: `xiaofang_dict-windows-zip` (约 60-70 MB)

---

## 📥 下载的文件

### Android APK
```
xiaofang_dict-android-release/
└── app-release.apk    # 安卓安装包
```

### Windows 安装包
```
xiaofang_dict-windows-zip/
├── xiaofang_dict.exe      # 主程序
├── data/                   # 数据文件
├── flutter_windows.dll    # Flutter 运行时
└── ... (其他依赖文件)
```

---

## 📲 安装说明

### 安卓手机安装

1. **传输 APK 到手机**
   - USB 数据线传输
   - 微信/QQ 发送到手机
   - 云盘下载

2. **安装**
   - 点击 APK 文件
   - 如果提示"未知来源"，允许安装
   - 完成安装

3. **使用**
   - 打开"小方字典"应用
   -  enjoy!

### Windows 电脑安装

1. **解压 ZIP 包**
   - 右键点击下载的 ZIP 文件
   - 选择"全部解压缩"
   - 选择安装目录（如 `C:\Program Files\XiaoFangDict`）

2. **创建快捷方式**（可选）
   - 右键 `xiaofang_dict.exe`
   - 发送到 → 桌面快捷方式

3. **运行**
   - 双击 `xiaofang_dict.exe` 或桌面快捷方式
   - enjoy!

---

## 🔄 更新版本

当代码更新后，自动重新构建：

```bash
# 修改代码后
git add .
git commit -m "更新说明"
git push

# GitHub Actions 会自动构建新版本
```

---

## ⚙️ 手动触发构建

可以随时手动触发构建：

1. 进入 GitHub 仓库 → **Actions** 标签
2. 选择 **Android APK Build** 或 **Windows EXE Build**
3. 点击 **Run workflow** 按钮
4. 选择分支（main）
5. 点击 **Run workflow**

---

## 📊 构建时间预估

| 阶段 | 时间 |
|------|------|
| 设置环境 | ~2 分钟 |
| 安装依赖 | ~3 分钟 |
| 编译构建 | ~8-12 分钟 |
| 上传产物 | ~1 分钟 |
| **总计** | **~15-20 分钟** |

---

## 🎯 构建产物保留期限

- Artifacts 保留 **30 天**
- 过期后需重新构建下载

---

## ⚠️ 常见问题

### Q: 构建失败怎么办？
A: 点击失败的构建记录，查看日志中的错误信息。常见原因：
- 代码有语法错误 → 修复后重新推送
- 依赖问题 → 检查 pubspec.yaml

### Q: 如何分享安装包？
A: 直接分享下载的 APK/ZIP 文件即可：
- Android: 分享 `app-release.apk`
- Windows: 分享整个解压后的文件夹或重新压缩

### Q: 可以自动发布 Release 吗？
A: 可以！使用 git tag 触发发布构建，见下方高级用法。

---

## 🔥 高级用法：自动发布 Release

创建 `release.yml` 工作流，打标签时自动创建 GitHub Release：

```yaml
# .github/workflows/release.yml
name: Release Build

on:
  push:
    tags:
      - 'v*'  # v1.0.0, v1.1.0, etc.

jobs:
  build-and-release:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2

      - name: Build
        run: |
          flutter pub get
          if [ "$RUNNER_OS" == "Linux" ]; then
            flutter build apk --release
          else
            flutter build windows --release
          fi

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            build/app/outputs/flutter-apk/app-release.apk
            build/xiaofang_dict_windows.zip
```

使用：
```bash
git tag v1.0.0
git push origin v1.0.0
# 自动构建并创建 GitHub Release
```

---

## 📞 需要帮助？

- GitHub Actions 文档：https://docs.github.com/en/actions
- Flutter 部署指南：https://docs.flutter.dev/deployment

---

**🎉 享受云端构建的便利！**
