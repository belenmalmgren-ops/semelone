import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('主题设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('经典书籍'),
            subtitle: const Text('米黄纸张风格'),
            value: AppThemeMode.classic,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).setTheme(value);
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('现代简约'),
            subtitle: const Text('清新蓝色'),
            value: AppThemeMode.modern,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).setTheme(value);
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('深色模式'),
            subtitle: const Text('护眼深色'),
            value: AppThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).setTheme(value);
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('关于'),
            subtitle: Text('小方新华字典 v1.0.0'),
          ),
        ],
      ),
    );
  }
}
