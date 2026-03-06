import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/idiom.dart';
import '../../data/repositories/idiom_repository.dart';
import '../../services/tts_service.dart';
import '../../data/models/user_preferences.dart';
import '../../services/preferences_service.dart';

/// 成语列表页 Provider
final idiomsProvider = FutureProvider<List<Idiom>>((ref) async {
  final repository = IdiomRepository.instance;
  await repository.init();
  return repository.getAll(limit: 100);
});

/// 成语词典页面 - 支持浏览和搜索
class IdiomsPage extends ConsumerStatefulWidget {
  const IdiomsPage({super.key});

  @override
  ConsumerState<IdiomsPage> createState() => _IdiomsPageState();
}

class _IdiomsPageState extends ConsumerState<IdiomsPage> {
  final IdiomRepository _idiomRepository = IdiomRepository.instance;
  final TTSService _ttsService = TTSService();
  final PreferencesService _prefsService = PreferencesService.instance;
  final TextEditingController _searchController = TextEditingController();

  UserPreferences _userPrefs = const UserPreferences();
  List<Idiom> _idioms = [];
  bool _isLoading = true;
  String? _error;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    try {
      await _idiomRepository.init();
      await _prefsService.init();
      setState(() {
        _userPrefs = _prefsService.preferences;
      });
      await _loadIdioms();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadIdioms() async {
    try {
      final idioms = await _idiomRepository.getAll(limit: 100);
      final count = await _idiomRepository.getCount();
      setState(() {
        _idioms = idioms;
        _totalCount = count;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _searchIdioms(String query) async {
    if (query.isEmpty) {
      await _loadIdioms();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _idiomRepository.search(query);
      setState(() {
        _idioms = results;
        _totalCount = results.length;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDetail(Idiom idiom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdiomDetailPage(idiom: idiom),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF3E2723),
      elevation: 2,
      title: Text(
        '成语词典',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20 * _userPrefs.fontScale,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // 统计信息
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('成语总数：$_totalCount'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16.h),
            Text('加载失败：$_error'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _initData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 搜索框
        _buildSearchBar(),
        // 成语列表
        Expanded(
          child: _idioms.isEmpty
              ? _buildEmptyState()
              : _buildIdiomList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索成语...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF3E2723)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF3E2723)),
                  onPressed: () {
                    _searchController.clear();
                    _loadIdioms();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFF8D6E63)),
          ),
          filled: true,
          fillColor: const Color(0xFFF5F1E8),
        ),
        onChanged: _searchIdioms,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            '暂无成语',
            style: TextStyle(
              fontSize: 18 * _userPrefs.fontScale,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdiomList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _idioms.length,
      itemBuilder: (context, index) {
        final idiom = _idioms[index];
        return _buildIdiomCard(idiom);
      },
    );
  }

  Widget _buildIdiomCard(Idiom idiom) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          // 成语和拼音
          Row(
            children: [
              Expanded(
                child: Text(
                  idiom.idiom,
                  style: TextStyle(
                    fontSize: 24.sp * _userPrefs.fontScale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E2723),
                  ),
                ),
              ),
              // 朗读按钮
              IconButton(
                icon: const Icon(Icons.volume_off, color: Color(0xFFD32F2F)),
                onPressed: () => _ttsService.speak(idiom.idiom),
                tooltip: '朗读',
              ),
            ],
          ),
          // 拼音
          Text(
            idiom.pinyin,
            style: TextStyle(
              fontSize: 16.sp * _userPrefs.fontScale,
              color: const Color(0xFFD32F2F),
            ),
          ),
          SizedBox(height: 8.h),
          // 释义（截断显示）
          if (idiom.definition.isNotEmpty)
            Text(
              idiom.definition,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp * _userPrefs.fontScale,
                color: const Color(0xFF3E2723),
              ),
            ),
          // 点击查看详情
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _navigateToDetail(idiom),
              child: const Text(
                '详情',
                style: TextStyle(color: Color(0xFF3E2723)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 成语详情页
class IdiomDetailPage extends ConsumerStatefulWidget {
  final Idiom idiom;

  const IdiomDetailPage({super.key, required this.idiom});

  @override
  ConsumerState<IdiomDetailPage> createState() => _IdiomDetailPageState();
}

class _IdiomDetailPageState extends ConsumerState<IdiomDetailPage> {
  final TTSService _ttsService = TTSService();
  final PreferencesService _prefsService = PreferencesService.instance;
  UserPreferences _userPrefs = const UserPreferences();

  @override
  void initState() {
    super.initState();
    _prefsService.init().then((_) {
      setState(() {
        _userPrefs = _prefsService.preferences;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final idiom = widget.idiom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: _buildAppBar(idiom),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildIdiomHeader(idiom),
            _buildDefinitionSection(idiom),
            if (idiom.example.isNotEmpty) _buildExampleSection(idiom),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Idiom idiom) {
    return AppBar(
      backgroundColor: const Color(0xFF3E2723),
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        idiom.idiom,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20 * _userPrefs.fontScale,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // 朗读按钮
        IconButton(
          icon: const Icon(Icons.volume_off, color: Colors.white),
          onPressed: () => _ttsService.speak(idiom.idiom),
          tooltip: '朗读',
        ),
      ],
    );
  }

  Widget _buildIdiomHeader(Idiom idiom) {
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
      ),
      child: Column(
        children: [
          // 成语大字
          Text(
            idiom.idiom,
            style: TextStyle(
              fontSize: 56.sp * _userPrefs.fontScale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E2723),
            ),
          ),
          SizedBox(height: 16.h),
          // 拼音
          Text(
            idiom.pinyin,
            style: TextStyle(
              fontSize: 20.sp * _userPrefs.fontScale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionSection(Idiom idiom) {
    if (idiom.definition.isEmpty) return const SizedBox.shrink();

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
          Text(
            idiom.definition,
            style: TextStyle(
              fontSize: 16 * _userPrefs.fontScale,
              color: Color(0xFF3E2723),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleSection(Idiom idiom) {
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
              const Text(
                '例句',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            idiom.example,
            style: TextStyle(
              fontSize: 16 * _userPrefs.fontScale,
              color: Color(0xFF3E2723),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
