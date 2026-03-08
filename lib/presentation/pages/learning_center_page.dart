import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'new_words_page.dart';
import 'difficult_words_page.dart';
import 'learning_stats_page.dart';

/// 学习中心页面
class LearningCenterPage extends StatelessWidget {
  const LearningCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习中心'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F1E8),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildCard(
            context,
            '生字本',
            '记录和复习生字',
            Icons.book,
            const NewWordsPage(),
          ),
          SizedBox(height: 12.h),
          _buildCard(
            context,
            '易错字',
            '标记的难字和易错字',
            Icons.flag,
            const DifficultWordsPage(),
          ),
          SizedBox(height: 12.h),
          _buildCard(
            context,
            '学习统计',
            '查看学习进度和成就',
            Icons.bar_chart,
            const LearningStatsPage(),
          ),
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
