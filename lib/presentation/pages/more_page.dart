import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'idioms_page.dart';
import 'poems_page.dart';
import 'settings_page.dart';

/// 更多页面
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更多'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F1E8),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildCard(context, '成语词典', '30,000+成语查询', Icons.library_books, const IdiomsPage()),
          SizedBox(height: 12.h),
          _buildCard(context, '古诗词', '84,000+诗词鉴赏', Icons.auto_stories, const PoemsPage()),
          SizedBox(height: 12.h),
          _buildCard(context, '设置', '个性化设置', Icons.settings, const SettingsPage()),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle, IconData icon, Widget page) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF3E2723), size: 32),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
