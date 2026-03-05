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
          RadioListTile<UserRole>(
            title: const Text('小学生'),
            subtitle: const Text('大字体、简化释义、拼音标注'),
            value: UserRole.primary,
            groupValue: _currentRole,
            onChanged: (value) {
              if (value != null) _setRole(value);
            },
          ),
          RadioListTile<UserRole>(
            title: const Text('初中生'),
            subtitle: const Text('标准字体、完整释义'),
            value: UserRole.middle,
            groupValue: _currentRole,
            onChanged: (value) {
              if (value != null) _setRole(value);
            },
          ),
          RadioListTile<UserRole>(
            title: const Text('成人'),
            subtitle: const Text('紧凑布局、详细信息'),
            value: UserRole.adult,
            groupValue: _currentRole,
            onChanged: (value) {
              if (value != null) _setRole(value);
            },
          ),
          const Divider(),
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
