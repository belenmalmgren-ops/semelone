import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/datasources/local/database_helper.dart';

class PoemsPage extends StatefulWidget {
  const PoemsPage({super.key});

  @override
  State<PoemsPage> createState() => _PoemsPageState();
}

class _PoemsPageState extends State<PoemsPage> {
  List<Map<String, dynamic>> _poems = [];
  bool _isLoading = true;
  String _selectedDynasty = '全部';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPoems();
  }

  Future<void> _loadPoems() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (_selectedDynasty != '全部') {
      where = 'dynasty = ?';
      whereArgs = [_selectedDynasty];
    }

    if (_searchController.text.isNotEmpty) {
      where += where.isEmpty ? '' : ' AND ';
      where += '(title LIKE ? OR author LIKE ?)';
      whereArgs.addAll(['%${_searchController.text}%', '%${_searchController.text}%']);
    }

    final poems = await db.query(
      'poems',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: 200,
      orderBy: 'id',
    );
    setState(() {
      _poems = poems;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('古诗词'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F1E8),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索标题或作者',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  onChanged: (_) => _loadPoems(),
                ),
                SizedBox(height: 12.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['全部', '唐', '宋', '元'].map((dynasty) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: Text(dynasty),
                          selected: _selectedDynasty == dynasty,
                          onSelected: (_) {
                            setState(() => _selectedDynasty = dynasty);
                            _loadPoems();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _poems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16.h),
                            Text('未找到诗词', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _poems.length,
                        itemBuilder: (context, index) {
                          final poem = _poems[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12.h),
                            child: ListTile(
                              title: Text(
                                poem['title'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text('${poem['author']} · ${poem['dynasty']}'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _showPoemDetail(poem),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showPoemDetail(Map<String, dynamic> poem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F1E8),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20.w),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                poem['title'] ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                '${poem['dynasty']} · ${poem['author']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Text(
                poem['content'] ?? '',
                style: const TextStyle(fontSize: 18, height: 2, color: Color(0xFF3E2723)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
