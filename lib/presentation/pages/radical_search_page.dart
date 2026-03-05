import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/character.dart';
import '../../data/repositories/dict_repository.dart';
import 'character_detail_page.dart';

/// 部首检索页面
class RadicalSearchPage extends ConsumerStatefulWidget {
  const RadicalSearchPage({super.key});

  @override
  ConsumerState<RadicalSearchPage> createState() =>
      _RadicalSearchPageState();
}

class _RadicalSearchPageState extends ConsumerState<RadicalSearchPage> {
  final DictRepository _repository = DictRepository.instance;

  String? _selectedRadical;
  List<Character> _searchResults = [];
  bool _isLoading = true;
  int? _selectedStrokeCount;

  // 部首按笔画数分组
  final Map<int, List<String>> _radicalsByStroke = {};

  @override
  void initState() {
    super.initState();
    _loadRadicals();
  }

  Future<void> _loadRadicals() async {
    setState(() => _isLoading = true);

    try {
      // 按笔画数分组（简化版：手动映射常用部首）
      _radicalsByStroke.clear();

      // 1 画
      _radicalsByStroke[1] = ['一', '丨', '丿', '乙', '亅'];
      // 2 画
      _radicalsByStroke[2] = ['二', '亠', '人', '儿', '入', '八', '冂', '冖', '冫', '几', '凵', '刀', '力', '勹', '匕', '匚', '匸', '十', '卜', '卩', '厂', '厶', '又'];
      // 3 画
      _radicalsByStroke[3] = ['口', '囗', '土', '士', '夂', '夊', '夕', '大', '女', '子', '宀', '寸', '小', '尢', '尸', '屮', '山', '巛', '工', '己', '巾', '干', '幺', '广', '廴', '廾', '弋', '弓', '彐', '彡', '彳'];
      // 4 画
      _radicalsByStroke[4] = ['戈', '比', '牙', '犬', '王', '木', '欠', '止', '歹', '殳', '毋', '比', '毛', '氏', '气', '水', '火', '爪', '父', '爿', '片', '牙', '牛', '犬'];
      // 5 画
      _radicalsByStroke[5] = ['玄', '玉', '瓜', '瓦', '甘', '生', '用', '田', '疋', '疒', '癶', '白', '皮', '皿', '目', '矛', '矢', '石', '示', '禾'];
      // 6 画
      _radicalsByStroke[6] = ['竹', '米', '糸', '缶', '网', '羊', '羽', '老', '而', '耒', '耳', '聿', '肉', '臣', '自', '至', '臼', '舌', '舛', '舟', '艮', '色', '艸', '虍', '虫', '血', '行', '衣', '襾'];
      // 7 画及以上
      _radicalsByStroke[7] = ['见', '角', '言', '谷', '豆', '豕', '豸', '贝', '赤', '走', '足', '身', '车', '辛', '辰', '辵', '邑', '酉', '釆', '里'];
      _radicalsByStroke[8] = ['金', '长', '门', '阜', '隶', '隹', '雨', '青', '非'];
      _radicalsByStroke[9] = ['面', '革', '韦', '韭', '音', '页', '风', '飞', '食', '首', '香'];
      _radicalsByStroke[10] = ['骨', '高', '髟', '鬯', '鬲', '鬼'];
      _radicalsByStroke[11] = ['鱼', '鸟', '卤', '鹿', '麦', '麻'];
      _radicalsByStroke[12] = ['黄', '黍', '黑', '黹'];
      _radicalsByStroke[13] = ['黾', '鼎', '鼓', '鼠'];
      _radicalsByStroke[14] = ['鼻', '齐'];
      _radicalsByStroke[15] = ['齿'];
      _radicalsByStroke[16] = ['隶', '隹'];
      _radicalsByStroke[17] = ['龠'];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('[RadicalSearch] 加载部首失败：$e');
      setState(() => _isLoading = false);
    }
  }

  /// 搜索指定部首的汉字
  Future<void> _searchRadical(String radical) async {
    setState(() {
      _selectedRadical = radical;
      _searchResults = [];
    });

    try {
      final results = await _repository.searchByRadical(radical, _selectedStrokeCount);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('[RadicalSearch] 搜索失败：$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败：$e')),
      );
    }
  }

  /// 按笔画数筛选
  Future<void> _filterByStroke(int? strokeCount) async {
    setState(() {
      _selectedStrokeCount = strokeCount;
    });

    if (_selectedRadical != null) {
      _searchRadical(_selectedRadical!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildRadicalGrid(),
          _buildStrokeFilter(),
          _buildResults(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF3E2723),
      title: const Text(
        '部首检索',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      actions: [
        if (_selectedRadical != null)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedRadical = null;
                _searchResults = [];
              });
            },
            tooltip: '清除选择',
          ),
      ],
    );
  }

  /// 部首网格
  Widget _buildRadicalGrid() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      color: const Color(0xFF3E2723),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择部首',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _radicalsByStroke.entries.map((entry) {
              return _buildStrokeGroup(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 笔画分组
  Widget _buildStrokeGroup(int strokeCount, List<String> radicals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$strokeCount 画',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: radicals.map((radical) {
            final isSelected = radical == _selectedRadical;
            return GestureDetector(
              onTap: () => _searchRadical(radical),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD32F2F)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFD32F2F)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    radical,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF3E2723),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  /// 笔画数筛选
  Widget _buildStrokeFilter() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '按笔画数筛选',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildStrokeChip('全部', null),
              _buildStrokeChip('1 画', 1),
              _buildStrokeChip('2 画', 2),
              _buildStrokeChip('3 画', 3),
              _buildStrokeChip('4 画', 4),
              _buildStrokeChip('5 画', 5),
              _buildStrokeChip('6 画', 6),
              _buildStrokeChip('7 画', 7),
              _buildStrokeChip('8 画', 8),
              _buildStrokeChip('9 画', 9),
              _buildStrokeChip('10 画 +', 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeChip(String label, int? count) {
    final isSelected = _selectedStrokeCount == count;
    return GestureDetector(
      onTap: () => _filterByStroke(count),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD32F2F)
              : const Color(0xFFF5F1E8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD32F2F)
                : const Color(0xFF8D6E63),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : const Color(0xFF3E2723),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 搜索结果
  Widget _buildResults() {
    if (_selectedRadical == null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_outlined,
                size: 80.w,
                color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                '请选择部首开始搜索',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF8D6E63).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80.w,
                color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                '未找到相关汉字',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF8D6E63).withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '试试其他部首',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF8D6E63).withValues(alpha: 0.4),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedRadical = null;
                    _searchResults = [];
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('清空搜索'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.all(12.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 1,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final char = _searchResults[index];
          return _buildCharacterCard(char);
        },
      ),
    );
  }

  /// 汉字卡片
  Widget _buildCharacterCard(Character char) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterDetailPage(character: char),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF8D6E63),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              char.char,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3E2723),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              char.pinyin,
              style: TextStyle(
                fontSize: 10.sp,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
