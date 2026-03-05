import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/character.dart';
import '../../data/repositories/dict_repository.dart';
import 'character_detail_page.dart';
import 'settings_page.dart';
import 'radical_search_page.dart';
import 'stroke_search_page.dart';
import 'handwriting_search_page.dart';
import 'history_page.dart';
import 'favorites_page.dart';

/// 拼音搜索页面 - 主页面
class PinyinSearchPage extends ConsumerStatefulWidget {
  const PinyinSearchPage({super.key});

  @override
  ConsumerState<PinyinSearchPage> createState() => _PinyinSearchPageState();
}

class _PinyinSearchPageState extends ConsumerState<PinyinSearchPage> {
  final DictRepository _repository = DictRepository.instance;
  final TextEditingController _controller = TextEditingController();
  List<Character> _searchResults = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    await _repository.init();
    final stats = await _repository.getStats();
    print('[PinyinSearch] 词库加载完成：${stats['total']} 个汉字');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 执行搜索
  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _lastQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _repository.searchByPinyin(query.toLowerCase());
      setState(() {
        _searchResults = results;
        _lastQuery = query;
      });
    } catch (e) {
      print('[PinyinSearch] 搜索失败：$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败：$e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8), // 米黄色纸张背景
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBox(),
          _buildMethodSwitcher(),
          _buildSearchResults(),
        ],
      ),
    );
  }

  /// 顶部标题栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF3E2723), // 深棕色墨色
      elevation: 2,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '小方',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '新华字典',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            );
          },
          tooltip: '收藏',
        ),
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          },
          tooltip: '历史',
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          tooltip: '设置',
        ),
      ],
    );
  }

  /// 搜索框区域
  Widget _buildSearchBox() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 搜索输入框
            TextField(
              controller: _controller,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: '输入拼音搜索（如：zhang）',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              textInputAction: TextInputAction.search,
              onChanged: _search,
            ),
            SizedBox(height: 12.h),
            // 搜索提示
            Row(
              children: [
                _buildQuickSearchChip('zh', '简拼'),
                const SizedBox(width: 8),
                _buildQuickSearchChip('zhang*', '模糊'),
                const SizedBox(width: 8),
                _buildQuickSearchChip('zhang', '全拼'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSearchChip(String text, String label) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _search(text);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F), // 朱红色
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 搜索结果列表
  Widget _buildSearchResults() {
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E2723)),
              ),
              SizedBox(height: 16.h),
              Text(
                '搜索中...',
                style: TextStyle(
                  color: const Color(0xFF3E2723),
                  fontSize: 16.sp,
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
                color: const Color(0xFF3E2723).withOpacity(0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                _lastQuery.isEmpty ? '输入拼音开始搜索' : '未找到相关汉字',
                style: TextStyle(
                  color: const Color(0xFF3E2723).withOpacity(0.5),
                  fontSize: 16.sp,
                ),
              ),
              if (_lastQuery.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  '试试其他拼音或检查拼写',
                  style: TextStyle(
                    color: const Color(0xFF3E2723).withOpacity(0.4),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                TextButton.icon(
                  onPressed: () {
                    _controller.clear();
                    _search('');
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('清空搜索'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(12.w),
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
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: const Color(0xFF8D6E63).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterDetailPage(character: char),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // 汉字
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1E8),
                  border: Border.all(
                    color: const Color(0xFF3E2723),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    char.char,
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // 拼音和释义
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      char.pinyin,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD32F2F),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (char.radical != null)
                      Text(
                        '【${char.radical}部】${char.strokeCount ?? '?'}画',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF3E2723).withOpacity(0.6),
                        ),
                      ),
                    SizedBox(height: 4.h),
                    if (char.definitions != null && char.definitions!.isNotEmpty)
                      Text(
                        char.definitions!.take(2).join(' | '),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF3E2723),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // 箭头
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF3E2723).withOpacity(0.5),
                size: 24.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 查询方法切换器
  Widget _buildMethodSwitcher() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMethodButton('拼音', Icons.text_fields, true, null),
          _buildMethodButton('部首', Icons.grid_on, false, () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RadicalSearchPage()));
          }),
          _buildMethodButton('笔画', Icons.edit, false, () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StrokeSearchPage()));
          }),
          _buildMethodButton('手写', Icons.draw, false, () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HandwritingSearchPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildMethodButton(String label, IconData icon, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD32F2F) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? Colors.white : const Color(0xFF3E2723), size: 24.w),
            SizedBox(height: 4.h),
            Text(label, style: TextStyle(color: isActive ? Colors.white : const Color(0xFF3E2723), fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
