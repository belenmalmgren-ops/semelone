# 🚀 小方字典 - 立即生成 Android 和 Windows 安装包

## 无需本地环境，云端自动构建！

---

## ⚡ 3 步获取安装包

### 第 1 步：推送到 GitHub

**方法 A：使用一键部署脚本（推荐）**

```bash
cd /Volumes/E/daima/openclaw/workspace/xiaofang_dict
./deploy-to-github.sh
```

**方法 B：手动命令**

```bash
cd /Volumes/E/daima/openclaw/workspace/xiaofang_dict

# 初始化 git
git init
git add .
git commit -m "Initial commit"

# 在 GitHub 创建仓库后推送
git remote add origin https://github.com/YOUR_USERNAME/xiaofang-dict.git
git push -u origin main
```

### 第 2 步：等待云端构建

推送成功后，GitHub Actions 自动开始构建：

1. 访问：`https://github.com/YOUR_USERNAME/xiaofang-dict/actions`
2. 点击左侧的 **Android APK Build** 和 **Windows EXE Build**
3. 等待 10-15 分钟

### 第 3 步：下载安装包

构建完成后：

1. 点击完成的构建记录
2. 滚动到页面底部 **Artifacts** 区域
3. 点击下载：
   - 📱 **Android**: `xiaofang_dict-android-release` → `app-release.apk`
   - 🪟 **Windows**: `xiaofang_dict-windows-zip` → 解压后运行

---

## 📥 安装包信息

| 平台 | 文件名 | 大小 | 安装方式 |
|------|--------|------|----------|
| Android | app-release.apk | ~45 MB | 传输到手机点击安装 |
| Windows | xiaofang_dict_windows.zip | ~65 MB | 解压后运行 exe |

---

## 📱 安卓安装

1. 下载 `app-release.apk`
2. 传输到手机（微信/QQ/数据线）
3. 点击 APK 安装（允许未知来源）
4. 打开"小方字典"应用

## 🪟 Windows 安装

1. 下载 `xiaofang_dict_windows.zip`
2. 右键解压到文件夹
3. 双击 `xiaofang_dict.exe` 运行
4. 可创建桌面快捷方式

---

## 🔄 更新版本

代码修改后：

```bash
git add .
git commit -m "更新说明"
git push
```

Actions 会自动重新构建！

---

## ⚙️ 手动触发构建

随时可以手动触发：

1. GitHub 仓库 → **Actions** 标签
2. 选择工作流（Android/Windows）
3. 点击 **Run workflow**
4. 选择分支 → **Run workflow**

---

## ❓ 遇到问题？

### 推送时提示权限错误
- 使用 GitHub Personal Access Token 代替密码
- 生成 Token：GitHub Settings → Developer settings → Personal access tokens

### 构建失败
- 点击构建记录查看详细日志
- 检查代码是否有语法错误

### Artifacts 找不到
- 确保构建成功完成（绿色对勾）
- Artifacts 保留 30 天

---

## 📖 详细文档

- `CLOUD_BUILD.md` - 云端构建完整指南
- `BUILD_GUIDE.md` - 跨平台构建说明
- `.github/workflows/` - 构建配置文件

---

**🎉 开始构建你的专属字典应用吧！**
