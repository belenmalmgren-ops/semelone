import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/character.dart';
import '../../data/repositories/dict_repository.dart';
import 'character_detail_page.dart';

/// 笔画检索页面
class StrokeSearchPage extends StatefulWidget {
  const StrokeSearchPage({super.key});

  @override
  State<StrokeSearchPage> createState() => _StrokeSearchPageState();
}

class _StrokeSearchPageState extends State<StrokeSearchPage> {
  final DictRepository _repository = DictRepository.instance;
  int _selectedStrokeCount = 1;
  List<Character> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);
    try {
      final results = await _repository.searchByStroke(strokeCount: _selectedStrokeCount);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        title: const Text('笔画检索', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildStrokeSelector(),
          _buildResultCount(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildStrokeSelector() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('选择笔画数', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(30, (i) {
              final count = i + 1;
              final isSelected = count == _selectedStrokeCount;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedStrokeCount = count);
                  _search();
                },
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3E2723) : const Color(0xFFF5F1E8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF3E2723)),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isSelected ? Colors.white : const Color(0xFF3E2723),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCount() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        '找到 ${_results.length} 个汉字',
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8D6E63)),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80.w, color: const Color(0xFF8D6E63).withOpacity(0.3)),
            SizedBox(height: 16.h),
            Text('未找到相关汉字', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8D6E63).withOpacity(0.6))),
            SizedBox(height: 8.h),
            Text('试试其他笔画数', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8D6E63).withOpacity(0.4))),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: () => setState(() {
                _selectedStrokeCount = 1;
                _results = [];
              }),
              icon: const Icon(Icons.clear),
              label: const Text('重置'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final char = _results[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CharacterDetailPage(character: char)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                char.char,
                style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
