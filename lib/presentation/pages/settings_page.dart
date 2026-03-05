import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import 'learning_stats_page.dart';
import '../../data/models/user_preferences.dart';
import '../../services/preferences_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferencesService _prefsService = PreferencesService.instance;
  UserRole _currentRole = UserRole.primary;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _prefsService.init();
    setState(() {
      _currentRole = _prefsService.preferences.role;
    });
  }

  Future<void> _setRole(UserRole role) async {
    await _prefsService.setRole(role);
    setState(() {
      _currentRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('用户角色', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(
              _currentRole == UserRole.primary ? Icons.check_circle : Icons.circle_outlined,
              color: _currentRole == UserRole.primary ? const Color(0xFFD32F2F) : Colors.grey,
            ),
            title: const Text('小学生'),
            subtitle: const Text('大字体、简化释义、拼音标注'),
            onTap: () => _setRole(UserRole.primary),
          ),
          ListTile(
            leading: Icon(
              _currentRole == UserRole.middle ? Icons.check_circle : Icons.circle_outlined,
              color: _currentRole == UserRole.middle ? const Color(0xFFD32F2F) : Colors.grey,
            ),
            title: const Text('初中生'),
            subtitle: const Text('标准字体、完整释义'),
            onTap: () => _setRole(UserRole.middle),
          ),
          ListTile(
            leading: Icon(
              _currentRole == UserRole.adult ? Icons.check_circle : Icons.circle_outlined,
              color: _currentRole == UserRole.adult ? const Color(0xFFD32F2F) : Colors.grey,
            ),
            title: const Text('成人'),
            subtitle: const Text('紧凑布局、详细信息'),
            onTap: () => _setRole(UserRole.adult),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('主题设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(
              currentTheme == AppThemeMode.classic ? Icons.check_circle : Icons.circle_outlined,
              color: currentTheme == AppThemeMode.classic ? const Color(0xFFD32F2F) : Colors.grey,
            ),
            title: const Text('经典书籍'),
            subtitle: const Text('米黄纸张风格'),
            onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeMode.classic),
          ),
          ListTile(
            leading: Icon(
              currentTheme == AppThemeMode.modern ? Icons.check_circle : Icons.circle_outlined,
              color: currentTheme == AppThemeMode.modern ? const Color(0xFFD32F2F) : Colors.grey,
            ),
            title: const Text('现代简约'),
            subtitle: const Text('清新蓝色'),
            onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeMode.modern),
          ),
          ListTile(
            leading: Icon(
              currentTheme == AppThemeMode.dark ? Icons.check_circle : Icons.circle_outlined,
              color: currentTheme == AppThemeMode.dark ? const Color(0xFFD32F2F) : Colors.grey,
            ),
            title: const Text('深色模式'),
            subtitle: const Text('护眼深色'),
            onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('学习统计'),
            subtitle: const Text('查看学习进度和复习计划'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LearningStatsPage()),
              );
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
      },
    );
  }
}
