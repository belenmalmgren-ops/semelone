import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/repositories/user_data_repository.dart';
import '../../data/repositories/dict_repository.dart';
import 'character_detail_page.dart';

class DifficultWordsPage extends StatefulWidget {
  const DifficultWordsPage({super.key});

  @override
  State<DifficultWordsPage> createState() => _DifficultWordsPageState();
}

class _DifficultWordsPageState extends State<DifficultWordsPage> {
  final UserDataRepository _userDataRepo = UserDataRepository.instance;
  final DictRepository _dictRepo = DictRepository.instance;
  List<Map<String, dynamic>> _difficultWords = [];

  @override
  void initState() {
    super.initState();
    _loadDifficultWords();
  }

  Future<void> _loadDifficultWords() async {
    await _userDataRepo.init();
    await _dictRepo.init();
    final difficultList = _userDataRepo.getDifficultWords();
    final words = <Map<String, dynamic>>[];
    for (var progress in difficultList) {
      final char = await _dictRepo.getByChar(progress.character);
      if (char != null) {
        words.add({
          'character': char,
          'progress': progress,
        });
      }
    }
    setState(() {
      _difficultWords = words;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        title: const Text('生字本', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _difficultWords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80.w, color: const Color(0xFF3E2723).withOpacity(0.3)),
                  SizedBox(height: 16.h),
                  Text('暂无难字', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF3E2723).withOpacity(0.5))),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: _difficultWords.length,
              itemBuilder: (context, index) {
                final item = _difficultWords[index];
                final char = item['character'];
                final progress = item['progress'];
                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListTile(
                    leading: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1E8),
                        border: Border.all(color: const Color(0xFF3E2723), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(char.char, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold))),
                    ),
                    title: Text(char.pinyin, style: TextStyle(fontSize: 16.sp, color: const Color(0xFFD32F2F))),
                    subtitle: Text('复习${progress.reviewCount}次 | 掌握${progress.masteryLevel}/5', style: TextStyle(fontSize: 12.sp)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterDetailPage(character: char)));
                    },
                  ),
                );
              },
            ),
    );
  }
}
