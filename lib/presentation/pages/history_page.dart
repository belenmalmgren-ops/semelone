import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/repositories/user_data_repository.dart';
import '../../data/repositories/dict_repository.dart';
import 'character_detail_page.dart';

/// 历史记录页面
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final UserDataRepository _userRepo = UserDataRepository.instance;
  final DictRepository _dictRepo = DictRepository.instance;
  List<String> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = _userRepo.getHistory();
    setState(() {
      _history = history.map((h) => h.character).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        title: const Text('历史记录', style: TextStyle(color: Colors.white)),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _clearHistory,
              tooltip: '清空',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64.w, color: const Color(0xFF8D6E63).withValues(alpha: 0.5)),
          SizedBox(height: 16.h),
          Text('暂无历史记录', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8D6E63))),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final char = _history[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F1E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(char, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              ),
            ),
            title: Text(char, style: TextStyle(fontSize: 18.sp)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openDetail(char),
          ),
        );
      },
    );
  }

  Future<void> _openDetail(String char) async {
    final character = await _dictRepo.getByChar(char);
    if (character != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CharacterDetailPage(character: character)),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有历史记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('确定')),
        ],
      ),
    );
    if (confirm == true) {
      await _userRepo.clearHistory();
      _loadHistory();
    }
  }
}
