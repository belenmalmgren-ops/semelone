import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../idioms_page.dart';
import '../favorites_page.dart';
import '../history_page.dart';

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
        actions: [
          // 成语词典入口
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IdiomsPage()),
              );
            },
            tooltip: '成语词典',
          ),
          // 历史记录
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          // 收藏夹
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
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
              onChanged: (value) {
                // TODO: 实时搜索
              },
            ),
            const SizedBox(height: 24),

            // 检索方式切换
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSearchButton('拼音', Icons.keyboard),
                _buildSearchButton('部首', Icons.apps),
                _buildSearchButton('笔画', Icons.draw),
                _buildSearchButton('手写', Icons.edit),
              ],
            ),

            // 成语词典快捷入口
            Container(
              margin: EdgeInsets.only(top: 24.h),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IdiomsPage()),
                  );
                },
                icon: const Icon(Icons.library_books, color: Color(0xFF3E2723)),
                label: const Text(
                  '成语词典',
                  style: TextStyle(color: Color(0xFF3E2723), fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F1E8),
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                ),
              ),
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
                  '项目骨架搭建完成 ✓',
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

  Widget _buildSearchButton(String label, IconData icon) {
    return Column(
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
