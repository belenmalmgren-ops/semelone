import 'package:flutter/material.dart';

/// 应用主题配置
class AppThemes {
  // 经典书籍主题（米黄纸张风格）
  static ThemeData classicTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3E2723), // 深棕色
    scaffoldBackgroundColor: const Color(0xFFF5F1E8), // 米黄色纸张
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3E2723),
      secondary: Color(0xFFD32F2F), // 朱红色
      surface: Color(0xFFF5F1E8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F1E8),
      foregroundColor: Color(0xFF3E2723),
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFFFFBF0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    ),
  );

  // 现代简约主题
  static ThemeData modernTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1976D2),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1976D2),
      secondary: Color(0xFF42A5F5),
    ),
  );

  // 深色模式
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFBB86FC),
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFBB86FC),
      secondary: Color(0xFF03DAC6),
    ),
  );
}
