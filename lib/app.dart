import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'presentation/themes/classic_theme.dart';
import 'presentation/pages/pinyin_search_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X 尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: '小方新华字典',
          debugShowCheckedModeBanner: false,
          theme: ClassicTheme.lightTheme,
          darkTheme: ClassicTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const PinyinSearchPage(),
        );
      },
    );
  }
}
