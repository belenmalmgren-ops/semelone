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
          Row(
            children: [
              Icon(Icons.edit, color: const Color(0xFF3E2723), size: 20.w),
              SizedBox(width: 8.w),
              Text(
                '数一数这个字有几画？',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildStrokeGroup('1-5画（常用字）', 1, 5, const Color(0xFF4CAF50)),
          SizedBox(height: 12.h),
          _buildStrokeGroup('6-10画（中等复杂）', 6, 10, const Color(0xFF2196F3)),
          SizedBox(height: 12.h),
          _buildStrokeGroup('11-15画（复杂字）', 11, 15, const Color(0xFFFF9800)),
          SizedBox(height: 12.h),
          _buildStrokeGroup('16-20画（生僻字）', 16, 20, const Color(0xFFE91E63)),
          SizedBox(height: 12.h),
          _buildStrokeGroup('21-30画（极生僻）', 21, 30, const Color(0xFF9C27B0)),
        ],
      ),
    );
  }

  Widget _buildStrokeGroup(String label, int start, int end, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: List.generate(end - start + 1, (i) {
            final count = start + i;
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
                  color: isSelected ? color : const Color(0xFFF5F1E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color, width: 2),
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
            Icon(Icons.search_off, size: 80.w, color: const Color(0xFF8D6E63).withValues(alpha: 0.3)),
            SizedBox(height: 16.h),
            Text('未找到相关汉字', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8D6E63).withValues(alpha: 0.6))),
            SizedBox(height: 8.h),
            Text('试试其他笔画数', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8D6E63).withValues(alpha: 0.4))),
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
