import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

// 手写适配器文件，无需使用 build_runner 生成
part 'search_history.g.dart';
part 'favorite.g.dart';
part 'learning_progress.g.dart';

/// 搜索历史记录
class SearchHistory {
  final String character;
  final DateTime timestamp;
  final String searchMethod;

  SearchHistory({
    required this.character,
    required this.timestamp,
    required this.searchMethod,
  });

  /// 是否今天搜索的
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// 是否昨天搜索的
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day;
  }

  /// 格式化显示时间
  String get formattedTime {
    if (isToday) {
      return '今天 ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (isYesterday) {
      return '昨天 ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month}-${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// 收藏记录
class Favorite {
  final String character;
  final String category;
  final DateTime addedAt;
  String? note;

  Favorite({
    required this.character,
    required this.category,
    required this.addedAt,
    this.note,
  });
}

/// 学习进度
class LearningProgress {
  final String character;
  int reviewCount;
  DateTime lastReview;
  bool isMarkedDifficult;
  int masteryLevel;

  LearningProgress({
    required this.character,
    this.reviewCount = 0,
    required this.lastReview,
    this.isMarkedDifficult = false,
    this.masteryLevel = 0,
  });

  /// 增加复习次数
  void addReview() {
    reviewCount++;
    lastReview = DateTime.now();
    if (masteryLevel < 5) {
      masteryLevel++;
    }
  }

  /// 标记为难字
  void markAsDifficult() {
    isMarkedDifficult = true;
  }

  /// 是否需要复习（艾宾浩斯曲线）
  bool get needsReview {
    final now = DateTime.now();
    final diff = now.difference(lastReview);

    // 根据掌握程度决定复习间隔
    final reviewIntervals = [
      const Duration(minutes: 5), // 0: 5 分钟后
      const Duration(hours: 1), // 1: 1 小时后
      const Duration(hours: 3), // 2: 3 小时后
      const Duration(days: 1), // 3: 1 天后
      const Duration(days: 3), // 4: 3 天后
      const Duration(days: 7), // 5: 7 天后
    ];

    if (masteryLevel >= reviewIntervals.length) {
      return false; // 已完全掌握
    }

    return diff > reviewIntervals[masteryLevel];
  }

  /// 掌握程度描述
  String get masteryDescription {
    const descriptions = [
      '未学习',
      '初学',
      '熟悉',
      '掌握',
      '熟练',
      '精通',
    ];
    if (masteryLevel >= descriptions.length) {
      return descriptions.last;
    }
    return descriptions[masteryLevel];
  }
}
