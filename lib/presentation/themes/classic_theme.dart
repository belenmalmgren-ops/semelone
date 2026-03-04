import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/theme_constants.dart';

/// 经典书籍主题
class ClassicTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: ThemeConstants.classicLightBackground,
      primaryColor: ThemeConstants.classicLightPrimary,
      colorScheme: const ColorScheme.light(
        primary: ThemeConstants.classicLightPrimary,
        secondary: ThemeConstants.classicLightAccent,
        surface: ThemeConstants.classicLightBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeConstants.classicLightBackground,
        foregroundColor: ThemeConstants.classicLightPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'STKaiti',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: ThemeConstants.classicLightPrimary,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'STKaiti',
          fontSize: 72,
          fontWeight: FontWeight.w500,
          color: ThemeConstants.classicLightPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'STSong',
          fontSize: 16,
          height: 1.8,
          color: ThemeConstants.classicLightPrimary,
        ),
      ),
      dividerColor: ThemeConstants.classicLightDivider,
      iconTheme: const IconThemeData(
        color: ThemeConstants.classicLightPrimary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ThemeConstants.classicDarkBackground,
      primaryColor: ThemeConstants.classicDarkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: ThemeConstants.classicDarkPrimary,
        secondary: ThemeConstants.classicDarkAccent,
        surface: ThemeConstants.classicDarkBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeConstants.classicDarkBackground,
        foregroundColor: ThemeConstants.classicDarkPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
