import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/character.dart';
import '../../core/widgets/stroke_animation.dart';
import '../../services/preferences_service.dart';
import '../../data/models/user_preferences.dart';

/// 汉字详情页 - 纸质字典风格
class CharacterDetailPage extends ConsumerStatefulWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  @override
  ConsumerState<CharacterDetailPage> createState() =>
      _CharacterDetailPageState();
}

class _CharacterDetailPageState extends ConsumerState<CharacterDetailPage> {
  bool _isFavorite = false;
  bool _isLoading = true;
  final PreferencesService _prefsService = PreferencesService.instance;
  UserPreferences _userPrefs = const UserPreferences();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    // TODO: 检查是否已收藏
    _isLoading = false;
  }

  Future<void> _loadPreferences() async {
    await _prefsService.init();
    setState(() {
      _userPrefs = _prefsService.preferences;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // TODO: 保存到数据库
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '已收藏' : '已取消收藏'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final char = widget.character;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8), // 米黄色纸张背景
      appBar: _buildAppBar(char),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 汉字大字区域
            _buildCharacterHeader(char),
            // 笔顺演示区域
            _buildStrokeSection(char),
            // 释义区域
            _buildDefinitionSection(char),
            // 组词区域
            _buildWordsSection(char),
            // 造字本义
            if (char.origin != null) _buildOriginSection(char),
          ],
        ),
      ),
    );
  }

  /// 顶部导航栏
  PreferredSizeWidget _buildAppBar(Character char) {
    return AppBar(
      backgroundColor: const Color(0xFF3E2723), // 深棕色墨色
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        char.char,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20 * _userPrefs.fontScale,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // 收藏按钮
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.star : Icons.star_border,
            color: _isFavorite ? const Color(0xFFFFD700) : Colors.white,
          ),
          onPressed: _toggleFavorite,
          tooltip: _isFavorite ? '取消收藏' : '收藏',
        ),
        // 更多选项
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFFF5F1E8),
          onSelected: (value) {
            switch (value) {
              case 'share':
                // TODO: 分享
                break;
              case 'copy':
                // TODO: 复制
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, color: Color(0xFF3E2723)),
                  SizedBox(width: 8),
                  Text('分享', style: TextStyle(color: Color(0xFF3E2723))),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  Icon(Icons.copy, color: Color(0xFF3E2723)),
                  SizedBox(width: 8),
                  Text('复制', style: TextStyle(color: Color(0xFF3E2723))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 汉字大字头部区域
  Widget _buildCharacterHeader(Character char) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3E2723),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 大字
          Text(
            char.char,
            style: TextStyle(
              fontSize: 80.sp * _userPrefs.fontScale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E2723),
              height: 1.2,
            ),
          ),
          SizedBox(height: 16.h),
          // 拼音
          Text(
            char.pinyin,
            style: TextStyle(
              fontSize: 24.sp * _userPrefs.fontScale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD32F2F), // 朱红色
            ),
          ),
          SizedBox(height: 12.h),
          // 部首和笔画
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1E8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8D6E63),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (char.radical != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E2723),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '【${char.radical}】部',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * _userPrefs.fontScale,
                      ),
                    ),
                  ),
                SizedBox(width: 12.w),
                Text(
                  '${char.strokeCount ?? '?'}画',
                  style: TextStyle(
                    fontSize: 16 * _userPrefs.fontScale,
                    color: Color(0xFF3E2723),
                  ),
                ),
                if (char.structure != null) ...[
                  SizedBox(width: 12.w),
                  Text(
                    '${char.structure}',
                    style: TextStyle(
                      fontSize: 14 * _userPrefs.fontScale,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 笔顺演示区域
  Widget _buildStrokeSection(Character char) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // 米黄色背景
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '笔顺',
                style: TextStyle(
                  fontSize: 18 * _userPrefs.fontScale,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 笔顺动画组件
          SizedBox(
            height: 200.h,
            child: StrokeAnimationWidget(
              character: char.char,
              svgPath: 'assets/strokes/${char.char}.svg',
              autoPlay: false,
              strokeCount: char.strokeCount,
            ),
          ),
        ],
      ),
    );
  }

  /// 释义区域
  Widget _buildDefinitionSection(Character char) {
    if (char.definitions == null || char.definitions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8.w),
              const Text(
                '释义',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...(_userPrefs.simplifyDefinitions
              ? char.definitions!.take(2).toList()
              : char.definitions!).asMap().entries.map((entry) {
            final index = entry.key;
            final definition = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * _userPrefs.fontScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      definition,
                      style: TextStyle(
                        fontSize: 16 * _userPrefs.fontScale,
                        color: Color(0xFF3E2723),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 组词区域
  Widget _buildWordsSection(Character char) {
    if (char.words == null || char.words!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '组词',
                style: TextStyle(
                  fontSize: 18 * _userPrefs.fontScale,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: char.words!.map((word) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1E8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF8D6E63),
                    width: 1,
                  ),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    fontSize: 14 * _userPrefs.fontScale,
                    color: Color(0xFF3E2723),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 造字本义区域
  Widget _buildOriginSection(Character char) {
    if (char.origin == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '造字本义',
                style: TextStyle(
                  fontSize: 18 * _userPrefs.fontScale,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            char.origin!,
            style: TextStyle(
              fontSize: 14 * _userPrefs.fontScale,
              color: Color(0xFF3E2723),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
