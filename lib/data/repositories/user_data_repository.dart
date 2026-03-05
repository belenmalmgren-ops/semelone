import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_data.dart';

/// 用户数据仓库 - 管理收藏、历史记录、学习进度
class UserDataRepository {
  static final UserDataRepository instance = UserDataRepository._init();

  late Box<SearchHistory> _historyBox;
  late Box<Favorite> _favoriteBox;
  late Box<LearningProgress> _progressBox;

  UserDataRepository._init();

  /// 初始化 Hive 数据库
  Future<void> init() async {
    // 注册适配器
    await Hive.initFlutter();

    Hive.registerAdapter(SearchHistoryAdapter());
    Hive.registerAdapter(FavoriteAdapter());
    Hive.registerAdapter(LearningProgressAdapter());

    // 打开数据库
    _historyBox = await Hive.openBox<SearchHistory>('search_history');
    _favoriteBox = await Hive.openBox<Favorite>('favorites');
    _progressBox = await Hive.openBox<LearningProgress>('learning_progress');

    print('[UserDataRepository] 初始化完成');
  }

  // ==================== 历史记录管理 ====================

  /// 添加搜索记录
  Future<void> addSearchHistory(String character, String method) async {
    final history = SearchHistory(
      character: character,
      timestamp: DateTime.now(),
      searchMethod: method,
    );

    // 添加到 box，使用 character 作为 key 避免重复
    await _historyBox.put(character, history);

    // 限制最多 100 条记录
    if (_historyBox.length > 100) {
      final keys = _historyBox.keys.toList();
      // 删除最早的记录
      await _historyBox.delete(keys.first);
    }
  }

  /// 获取所有历史记录（按时间倒序）
  List<SearchHistory> getHistory() {
    final histories = _historyBox.values.toList();
    histories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return histories;
  }

  /// 获取今天的历史记录
  List<SearchHistory> getTodayHistory() {
    return getHistory().where((h) => h.isToday).toList();
  }

  /// 获取最近 N 条记录
  List<SearchHistory> getRecentHistory({int limit = 10}) {
    return getHistory().take(limit).toList();
  }

  /// 清除历史记录
  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  /// 清除所有收藏
  Future<void> clearFavorites() async {
    await _favoriteBox.clear();
  }

  /// 删除单条记录
  Future<void> deleteHistory(String character) async {
    await _historyBox.delete(character);
  }

  // ==================== 收藏管理 ====================

  /// 添加收藏
  Future<void> addFavorite(String character, String category) async {
    final favorite = Favorite(
      character: character,
      category: category,
      addedAt: DateTime.now(),
    );
    await _favoriteBox.put(character, favorite);
  }

  /// 取消收藏
  Future<void> removeFavorite(String character) async {
    await _favoriteBox.delete(character);
  }

  /// 检查是否已收藏
  bool isFavorite(String character) {
    return _favoriteBox.containsKey(character);
  }

  /// 获取所有收藏
  List<Favorite> getFavorites() {
    final favorites = _favoriteBox.values.toList();
    favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return favorites;
  }

  /// 按分类获取收藏
  List<Favorite> getFavoritesByCategory(String category) {
    return _favoriteBox.values
        .where((f) => f.category == category)
        .toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  /// 获取所有分类
  List<String> getCategories() {
    final categories = _favoriteBox.values.map((f) => f.category).toSet();
    return categories.toList();
  }

  /// 添加自定义分类
  Future<void> addCategory(String category) async {
    // 分类信息可以存储在单独的 box 中
    // 这里简化处理，直接使用
  }

  /// 更新收藏备注
  Future<void> updateNote(String character, String note) async {
    final favorite = _favoriteBox.get(character);
    if (favorite != null) {
      // 由于 Favorite 不再是 HiveObject，需要重新创建对象并保存
      final updated = Favorite(
        character: character,
        category: favorite.category,
        addedAt: favorite.addedAt,
        note: note,
      );
      await _favoriteBox.put(character, updated);
    }
  }

  // ==================== 学习进度管理 ====================

  /// 更新学习进度
  Future<void> updateProgress(String character, {
    int? reviewCount,
    bool? isMarkedDifficult,
    int? masteryLevel,
  }) async {
    final existing = _progressBox.get(character);

    final progress = LearningProgress(
      character: character,
      reviewCount: reviewCount ?? existing?.reviewCount ?? 0,
      lastReview: existing?.lastReview ?? DateTime.now(),
      isMarkedDifficult: isMarkedDifficult ?? existing?.isMarkedDifficult ?? false,
      masteryLevel: masteryLevel ?? existing?.masteryLevel ?? 0,
    );

    await _progressBox.put(character, progress);
  }

  /// 添加复习记录
  Future<void> addReview(String character) async {
    final progress = _progressBox.get(character);

    if (progress != null) {
      // 由于 LearningProgress 不再是 HiveObject，需要重新创建对象并保存
      progress.addReview();
      await _progressBox.put(character, progress);
    } else {
      await updateProgress(character, reviewCount: 1, masteryLevel: 1);
    }
  }

  /// 标记为难字
  Future<void> markAsDifficult(String character) async {
    final progress = _progressBox.get(character);

    if (progress != null) {
      progress.markAsDifficult();
      await _progressBox.put(character, progress);
    } else {
      await updateProgress(character, isMarkedDifficult: true);
    }
  }

  /// 获取学习进度
  LearningProgress? getProgress(String character) {
    return _progressBox.get(character);
  }

  /// 获取所有学习进度
  List<LearningProgress> getAllProgress() {
    return _progressBox.values.toList();
  }

  /// 获取需要复习的字
  List<LearningProgress> getNeedsReview() {
    return _progressBox.values.where((p) => p.needsReview).toList();
  }

  /// 获取难字列表
  List<LearningProgress> getDifficultWords() {
    return _progressBox.values.where((p) => p.isMarkedDifficult).toList();
  }

  /// 获取学习统计
  Map<String, int> getStats() {
    final allProgress = getAllProgress();
    final totalLearned = allProgress.length;
    final mastered = allProgress.where((p) => p.masteryLevel >= 4).length;
    final needsReview = getNeedsReview().length;
    final difficult = getDifficultWords().length;

    return {
      'totalLearned': totalLearned,
      'mastered': mastered,
      'needsReview': needsReview,
      'difficult': difficult,
    };
  }

  /// 清除所有学习进度
  Future<void> clearProgress() async {
    await _progressBox.clear();
  }
}
