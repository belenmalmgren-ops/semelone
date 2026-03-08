import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pinyin_search_page.dart';
import '../radical_search_page.dart';
import '../stroke_search_page.dart';
import '../handwriting_search_page.dart';

/// 主页 - 查字入口
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小方新华字典'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F1E8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜索框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入拼音、汉字或部首...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // 检索方式切换
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSearchButton('拼音', Icons.keyboard, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PinyinSearchPage()));
                }),
                _buildSearchButton('部首', Icons.apps, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RadicalSearchPage()));
                }),
                _buildSearchButton('笔画', Icons.draw, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StrokeSearchPage()));
                }),
                _buildSearchButton('手写', Icons.edit, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HandwritingSearchPage()));
                }),
              ],
            ),

            const Spacer(),

            // 欢迎文字
            const Column(
              children: [
                Icon(Icons.menu_book, size: 64, color: Color(0xFF3E2723)),
                SizedBox(height: 16),
                Text(
                  '小方新华字典',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '9,578字 · 30,903成语 · 84,082诗词',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF3E2723),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
