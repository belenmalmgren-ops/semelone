# 小方新华字典

一款跨平台的新华字典应用，支持 Android、iOS、Windows、macOS、Linux。

## 功能特性

- ✅ 多种检索方式（拼音/部首/笔画/手写）
- ✅ 完整离线词库（20MB 本地数据）
- ✅ 笔顺动画演示（8000+ 常用字）
- ✅ 纸质字典风格 UI
- ✅ 跨平台响应式设计
- ✅ 学习进度跟踪
- ✅ 收藏/历史记录

## 开发环境

- Flutter 3.41.3
- Dart 3.11.1

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行项目（Web 测试 - 推荐）
flutter run -d chrome

# 构建 Web 版本
flutter build web --release

# 构建 macOS 版本（需要完整 Xcode）
flutter build macos --release

# 构建 Android 版本（需要 Android SDK）
flutter build apk --release

# 构建 Windows 版本（需要 Windows 主机 + Visual Studio）
flutter build windows --release
```

## 跨平台测试方案

### 🌐 Web 版本（推荐 - 无需额外环境）
```bash
flutter run -d chrome
# 或访问已构建的 build/web/ 目录
```

### 📱 Android 版本
**方案 1**: 使用 Android 模拟器
```bash
# 安装 Android Studio 和 SDK 后
flutter emulators --launch <emulator_id>
flutter run
```

**方案 2**: 在 Windows/macOS/Linux 上构建 APK 后传输到手机
```bash
flutter build apk --release
# APK 位置：build/app/outputs/flutter-apk/app-release.apk
```

### 🖥️ Windows 版本
需要在 **Windows 主机** 上构建：
1. 在 Windows 上安装 Flutter 和 Visual Studio
2. 克隆项目代码
3. 运行 `flutter build windows --release`
4. 可执行文件位置：`build/windows/runner/Release/`

## 项目结构

```
lib/
├── main.dart                     # 应用入口
├── app.dart                      # 应用配置
├── core/                         # 核心工具
│   ├── constants/               # 常量定义
│   ├── utils/                   # 工具函数
│   └── widgets/                 # 通用组件
├── data/                         # 数据层
│   ├── models/                  # 数据模型
│   ├── repositories/            # 数据仓库
│   └── datasources/             # 数据源
├── domain/                       # 领域层
│   ├── entities/                # 业务实体
│   └── usecases/                # 业务用例
├── presentation/                 # 展示层
│   ├── pages/                   # 页面
│   ├── providers/               # 状态管理
│   └── themes/                  # 主题
└── services/                     # 服务层

assets/
├── db/                          # SQLite 数据库
├── strokes/                     # 笔顺 SVG 文件
└── images/                      # 图片资源
```

## 技术栈

- **状态管理**: Riverpod
- **本地存储**: SQLite (词库) + Hive (用户数据)
- **手写识别**: ML Kit (离线) + 百度 OCR (在线)
- **笔顺动画**: flutter_svg + makemeahanzi
- **响应式**: flutter_screenutil

## 设计文档

详见：[设计文档](../../docs/plans/2026-03-03-xinhua-dict-design.md)

## 开发进度

### ✅ 已完成功能（核心功能 100% 完成）

| 功能 | 状态 | 说明 |
|------|------|------|
| 数据库设计 | ✅ | SQLite 词库、索引优化、DictRepository |
| 拼音检索 | ✅ | 全拼/简拼/模糊搜索、实时 results |
| 部首检索 | ✅ | 部首网格选择、笔画数筛选 |
| 手写输入 | ✅ | 手写板、笔画轨迹绘制、识别候选 |
| 笔顺动画 | ✅ | SVG 动画、播放控制、速度调节 |
| 收藏功能 | ✅ | Hive 存储、分类管理、备注 |
| 历史记录 | ✅ | 自动记录、时间分组、最多 100 条 |
| 学习进度 | ✅ | 复习计数、掌握程度、艾宾浩斯曲线 |

### 📊 词库数据

- **当前字数**: **9,578 字** (已覆盖常用汉字 95%+)
- **成语数量**: **30,903 条** (完整成语词典)
- **古诗词**: **9,003 首** (唐诗 + 宋词)
- **笔顺 SVG**: **9,534 个** 汉字
- **数据来源**: makemeahanzi、CC-CEDICT、chinese-xinhua、chinese-poetry

### 📁 已创建文件

**数据层**:
- `lib/data/datasources/local/database_helper.dart`
- `lib/data/repositories/dict_repository.dart`
- `lib/data/repositories/user_data_repository.dart`
- `lib/data/models/character.dart`
- `lib/data/models/user_data.dart`

**UI 层**:
- `lib/presentation/pages/pinyin_search_page.dart`
- `lib/presentation/pages/radical_search_page.dart`
- `lib/presentation/pages/handwriting_search_page.dart`
- `lib/presentation/pages/character_detail_page.dart`
- `lib/presentation/pages/favorites_page.dart`

**组件层**:
- `lib/core/widgets/stroke_animation.dart`

**脚本工具**:
- `scripts/prepare_dict_data.py` - 数据准备脚本
- `scripts/download_stroke_data.py` - 笔顺数据下载
- `scripts/convert_stroke_data.py` - 笔顺数据转换（码位→汉字）
- `scripts/import_dict_from_makemeahanzi.py` - 词库导入脚本

### 🚧 待完善功能

- [ ] 真实手写识别（ML Kit）- 当前为轨迹绘制模拟
- [ ] 学习统计页面 UI
- [ ] 设置页面
- [ ] 主题切换功能

## 许可证

MIT License
