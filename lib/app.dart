import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'presentation/themes/app_themes.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/pages/pinyin_search_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    ThemeData selectedTheme;
    switch (themeMode) {
      case AppThemeMode.classic:
        selectedTheme = AppThemes.classicTheme;
        break;
      case AppThemeMode.modern:
        selectedTheme = AppThemes.modernTheme;
        break;
      case AppThemeMode.dark:
        selectedTheme = AppThemes.darkTheme;
        break;
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: '小方新华字典',
          debugShowCheckedModeBanner: false,
          theme: selectedTheme,
          home: const PinyinSearchPage(),
        );
      },
    );
  }
}
