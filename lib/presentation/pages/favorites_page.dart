import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/repositories/user_data_repository.dart';
import '../../data/repositories/dict_repository.dart';
import 'character_detail_page.dart';

/// 收藏夹页面
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage>
    with SingleTickerProviderStateMixin {
  final UserDataRepository _userData = UserDataRepository.instance;
  final DictRepository _dictRepo = DictRepository.instance;

  late TabController _tabController;
  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = _userData.getCategories();
    setState(() {
      _categories = ['全部', ...categories];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFavoritesList(),
                _buildCategoriesList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: const Color(0xFFD32F2F),
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF3E2723),
      title: const Text(
        '收藏夹',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: '收藏'),
          Tab(text: '分类'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep, color: Colors.white),
          onPressed: _clearAll,
          tooltip: '清空收藏',
        ),
      ],
    );
  }

  /// 分类筛选
  Widget _buildCategoryFilter() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: const Color(0xFF3E2723),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = category == _selectedCategory ||
                (_selectedCategory == null && category == '全部');
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category == '全部' ? null : category;
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD32F2F)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.white : const Color(0xFF3E2723),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 收藏列表
  Widget _buildFavoritesList() {
    final favorites = _selectedCategory != null
        ? _userData.getFavoritesByCategory(_selectedCategory!)
        : _userData.getFavorites();

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80.w,
              color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              '暂无收藏',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF8D6E63).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return _buildCharacterCard(favorite.character, favorite);
      },
    );
  }

  /// 分类列表
  Widget _buildCategoriesList() {
    final categories = _userData.getCategories();

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 80.w,
              color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              '暂无分类',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF8D6E63).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final count = _userData.getFavoritesByCategory(category).length;

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: const Icon(Icons.folder, color: Color(0xFFD32F2F)),
            title: Text(category),
            subtitle: Text('$count 个字'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editCategory(category),
                  tooltip: '编辑分类',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteCategory(category),
                  tooltip: '删除分类',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacterCard(String character, dynamic favorite) {
    return GestureDetector(
      onTap: () async {
        final result = await _dictRepo.getByChar(character);
        if (result != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterDetailPage(character: result),
            ),
          );
        }
      },
      onLongPress: () => _showFavoriteOptions(character),
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
              character,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3E2723),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              favorite.category,
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

  void _showFavoriteOptions(String character) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('修改分类'),
              onTap: () {
                Navigator.pop(context);
                _editFavoriteCategory(character);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('添加备注'),
              onTap: () {
                Navigator.pop(context);
                _addNote(character);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('取消收藏', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _removeFavorite(character);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeFavorite(String character) async {
    await _userData.removeFavorite(character);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已取消收藏')),
      );
    }
  }

  Future<void> _editFavoriteCategory(String character) async {
    final categories = _userData.getCategories();
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: categories.map((category) {
          return ListTile(
            title: Text(category),
            onTap: () => Navigator.pop(context, category),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      await _userData.addFavorite(character, selected);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已移至「$selected」')),
        );
      }
    }
  }

  Future<void> _addNote(String character) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加备注'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入备注内容'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (note != null && note.isNotEmpty) {
      await _userData.updateNote(character, note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备注已保存')),
        );
      }
    }
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建分类'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '分类名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name != null && name.isNotEmpty) {
      await _userData.addCategory(name);
      _loadCategories();
    }
  }

  void _editCategory(String category) async {
    final controller = TextEditingController(text: category);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑分类'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName != null && newName.isNotEmpty && newName != category) {
      final favorites = _userData.getFavoritesByCategory(category);
      for (var fav in favorites) {
        await _userData.addFavorite(fav.character, newName);
      }
      _loadCategories();
      setState(() {});
    }
  }

  void _deleteCategory(String category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定删除「$category」分类吗？该分类下的收藏将被移至「默认」分类。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final favorites = _userData.getFavoritesByCategory(category);
      for (var fav in favorites) {
        await _userData.addFavorite(fav.character, '默认');
      }
      _loadCategories();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('分类已删除')),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有收藏吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _userData.clearFavorites();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
