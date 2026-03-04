import 'package:flutter/material.dart';

/// 应用常量
class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = '小方新华字典';
  static const String appVersion = '1.0.0';
  
  // 数据库
  static const String databaseName = 'xinhua_dict.db';
  static const int databaseVersion = 1;
  
  // Hive 表
  static const String historyBoxName = 'search_history';
  static const String favoriteBoxName = 'favorites';
  static const String learningBoxName = 'learning_progress';
  
  // 限制
  static const int maxHistoryCount = 100;
  static const int searchResultLimit = 50;
  
  // 性能
  static const Duration cacheDuration = Duration(hours: 24);
  static const int lruCacheSize = 100;
}
