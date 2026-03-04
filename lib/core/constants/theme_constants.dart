import 'package:flutter/material.dart';

/// 主题常量 - 经典书籍风格
class ThemeConstants {
  ThemeConstants._();

  // 经典书籍主题 - 浅色
  static const Color classicLightBackground = Color(0xFFF5F1E8); // 米黄色纸张
  static const Color classicLightPrimary = Color(0xFF3E2723); // 深棕色墨色
  static const Color classicLightAccent = Color(0xFFD32F2F); // 朱红色印章
  static const Color classicLightText = Color(0xFF3E2723);
  static const Color classicLightDivider = Color(0xFF8D6E63);
  
  // 经典书籍主题 - 深色
  static const Color classicDarkBackground = Color(0xFF2C2416); // 深棕色纸张
  static const Color classicDarkPrimary = Color(0xFFE8DCC8); // 浅米色文字
  static const Color classicDarkAccent = Color(0xFFFF6B6B); // 朱红色
  static const Color classicDarkText = Color(0xFFE8DCC8);
  
  // 现代简约主题 - 浅色
  static const Color modernLightBackground = Colors.white;
  static const Color modernLightPrimary = Color(0xFF1976D2);
  
  // 现代简约主题 - 深色
  static const Color modernDarkBackground = Color(0xFF121212);
  static const Color modernDarkPrimary = Color(0xFF90CAF9);
}
