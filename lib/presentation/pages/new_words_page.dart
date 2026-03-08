import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/dict_repository.dart';
import 'character_detail_page.dart';

class NewWordsPage extends StatefulWidget {
  const NewWordsPage({super.key});

  @override
  State<NewWordsPage> createState() => _NewWordsPageState();
}

class _NewWordsPageState extends State<NewWordsPage> {
  List<Map<String, dynamic>> _newWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNewWords();
  }

  Future<void> _loadNewWords() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final words = await db.query('new_words', orderBy: 'added_at DESC');
    setState(() {
      _newWords = words;
      _isLoading = false;
    });
  }

  Future<void> _deleteWord(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('new_words', where: 'id = ?', whereArgs: [id]);
    _loadNewWords();
  }

  Future<void> _viewCharacter(String char) async {
    final character = await DictRepository.instance.getByChar(char);
    if (character != null && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterDetailPage(character: character)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生字本'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F1E8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _newWords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16.h),
                      Text('还没有生字', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _newWords.length,
                  itemBuilder: (context, index) {
                    final word = _newWords[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: ListTile(
                        leading: Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E2723),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            word['char'],
                            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text('掌握度: ${word['mastery_level']}/5'),
                        subtitle: Text('复习${word['review_count']}次'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteWord(word['id']),
                        ),
                        onTap: () => _viewCharacter(word['char']),
                      ),
                    );
                  },
                ),
    );
  }
}
