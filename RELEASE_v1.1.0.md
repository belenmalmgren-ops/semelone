# 小方新华字典 v1.1.0 发布说明

**发布日期**：2026-03-06
**版本号**：v1.1.0
**提交哈希**：e3934cc

---

## 🎉 新功能

### 1. 语音朗读功能（TTS）⭐

让每个汉字都可发音，辅助学习！

**功能特性**：
- 📢 汉字朗读 - 点击拼音旁的喇叭图标即可听到标准发音
- 🎯 自动中文 - 自动选择中文语言（zh-CN 优先）
- 📚 学习友好 - 语速适中（0.5），适合学生学习
- 🔊 拼音朗读 - 支持拼音发音（去除声调数字）

**使用方式**：
1. 打开任意汉字详情页
2. 点击拼音旁的喇叭图标（🔊）
3. 听到标准中文发音

**技术实现**：
- 集成 `flutter_tts` 跨平台 TTS 库
- 单例模式管理 TTS 资源
- 支持 iOS/Android/Windows/macOS/Linux

---

### 2. 成语词典模块 📖

学习成语，提升词汇量！

**功能特性**：
- 📝 成语浏览 - 滚动浏览成语列表
- 🔍 实时搜索 - 支持按汉字/拼音搜索成语
- 📄 成语详情 - 查看完整释义、例句
- 🔊 成语朗读 - 点击喇叭听成语发音
- 📊 数据统计 - 显示成语总数

**使用方式**：
1. 主页点击"成语词典"快捷按钮
2. 或点击顶部 AppBar 的成语词典图标（📚）
3. 浏览或搜索成语
4. 点击成语查看详情

**数据结构**：
```sql
CREATE TABLE idioms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idiom TEXT UNIQUE NOT NULL,    -- 成语
    pinyin TEXT NOT NULL,          -- 拼音
    definition TEXT,               -- 释义
    example TEXT,                  -- 例句
    tags TEXT,                     -- 标签
    created_at TIMESTAMP           -- 创建时间
)
```

**当前数据**：
- 271 条示例成语（可扩展至 30,000+）
- 100% 有拼音
- 88.6% 有例句

---

## 📝 变更列表

### 新增文件（11 个）

**核心功能**：
- `lib/services/tts_service.dart` - TTS 语音朗读服务
- `lib/data/models/idiom.dart` - 成语数据模型
- `lib/data/repositories/idiom_repository.dart` - 成语数据仓库
- `lib/presentation/pages/idioms_page.dart` - 成语列表/详情页

**数据脚本**：
- `scripts/import_idioms.py` - 基础成语导入脚本
- `scripts/import_idioms_full.py` - 完整成语导入脚本
- `scripts/expand_dict_v2.py` - 词库扩充脚本 v2
- `scripts/expand_dict_v3.py` - 词库扩充脚本 v3
- `scripts/expand_dict_v4.py` - 词库扩充脚本 v4
- `scripts/clean_dict_data.py` - 数据清洗脚本

**数据备份**：
- `assets/db/xinhua_dict.db.backup.20260306` - 数据库备份

### 修改文件（5 个）

- `pubspec.yaml` - 添加 `flutter_tts: ^4.2.1` 依赖
- `lib/presentation/pages/character_detail_page.dart` - 添加朗读按钮和逻辑
- `lib/presentation/pages/home/home_page.dart` - 添加成语词典入口按钮
- `assets/db/xinhua_dict.db` - 新增 `idioms` 表
- `pubspec.lock` - 依赖锁定文件更新

---

## 📊 代码统计

| 指标 | 数值 |
|------|------|
| 新增 Dart 文件 | 4 个 |
| 新增 Python 脚本 | 6 个 |
| 修改文件 | 5 个 |
| 代码行数（Dart） | ~850 行 |
| 代码行数（Python） | ~800 行 |
| 总变更 | 2344 行新增，33 行删除 |
| 成语数据 | 271 条 |

---

## 🔧 技术细节

### 依赖更新

```yaml
dependencies:
  # 新增
  flutter_tts: ^4.2.1
```

### 数据库变更

```sql
-- 新增成语表
CREATE TABLE idioms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idiom TEXT UNIQUE NOT NULL,
    pinyin TEXT NOT NULL,
    definition TEXT,
    example TEXT,
    tags TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 索引
CREATE INDEX idx_idiom_pinyin ON idioms(pinyin);
CREATE INDEX idx_idiom_first_char ON idioms(substring(idiom, 1, 1));
```

### API 变更

**TTS 服务**：
```dart
// 使用方式
final ttsService = TTSService();
await ttsService.init();
await ttsService.speak('你好');         // 朗读汉字
await ttsService.speakPinyin('ni hao'); // 朗读拼音
```

**成语仓库**：
```dart
// 使用方式
final idiomRepo = IdiomRepository.instance;
await idiomRepo.init();
final idioms = await idiomRepo.search('画');      // 搜索成语
final all = await idiomRepo.getAll(limit: 50);    // 分页获取
final count = await idiomRepo.getCount();         // 获取总数
```

---

## 🎨 UI 变更

### 汉字详情页
- 拼音右侧新增喇叭图标（🔊）
- 朗读时图标变为 `volume_up`，禁用防止重复点击
- 保持纸质字典风格，朱红色点缀

### 主页
- 检索方式按钮下方新增"成语词典"快捷入口
- AppBar 新增成语词典图标（📚）
- 点击跳转到成语词典页面

### 成语词典页
- 顶部搜索框，支持实时搜索
- 成语卡片列表，显示成语、拼音、释义摘要
- 每个成语配有朗读按钮
- 点击卡片进入详情页

---

## ✅ 测试验证

### 功能测试
- [x] TTS 服务初始化
- [x] 汉字朗读
- [x] 拼音朗读
- [x] 朗读按钮 UI
- [x] 成语表创建
- [x] 成语数据导入
- [x] 成语列表页
- [x] 成语详情页
- [x] 成语搜索
- [x] 主页入口导航

### 代码质量
- [x] Flutter 分析通过（无错误、无警告）
- [x] 依赖安装成功
- [x] Git 提交成功
- [x] 远程仓库推送成功

---

## 📋 升级指南

### 对于现有用户

1. **拉取最新代码**：
```bash
cd /Volumes/E/daima/openclaw/workspace/xiaofang_dict
git pull origin main
```

2. **安装依赖**：
```bash
flutter pub get
```

3. **运行应用**：
```bash
flutter run
```

### 对于新用户

1. **克隆仓库**：
```bash
git clone https://github.com/belenmalmgren-ops/semelone.git
cd xiaofang_dict
```

2. **安装依赖**：
```bash
flutter pub get
```

3. **运行应用**：
```bash
flutter run
```

---

## 🚀 下一步计划

### P1 功能（建议）
1. **古诗词模块** - 导入 50,000+ 首诗词
2. **成语收藏** - 收藏 favorite 成语
3. **学习进度** - 成语学习进度追踪
4. **成语接龙** - 成语接龙游戏

### P2 功能（可选）
1. **成语分类** - 按主题分类（动物/植物/历史...）
2. **每日成语** - 每日推荐一个成语
3. **成语测验** - 选择题/填空题测试
4. **发音人选择** - 男声/女声/童声

---

## 📞 问题反馈

如遇到问题，请提交 Issue 或联系开发团队。

**已知问题**：
- 无

---

## 📄 许可证

本项目采用 MIT 许可证。

---

_发布人：小刘团队_
_发布日期：2026-03-06_
_GitHub: https://github.com/belenmalmgren-ops/semelone_
