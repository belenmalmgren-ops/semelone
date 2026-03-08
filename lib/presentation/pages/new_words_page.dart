import 'package:flutter/material.dart';
import '../../data/datasources/local/database_helper.dart';

class NewWordsPage extends StatefulWidget {
  const NewWordsPage({super.key});

  @override
  State<NewWordsPage> createState() => _NewWordsPageState();
}

class _NewWordsPageState extends State<NewWordsPage> {
  List<Map<String, dynamic>> _newWords = [];

  @override
  void initState() {
    super.initState();
    _loadNewWords();
  }

  Future<void> _loadNewWords() async {
    final db = await DatabaseHelper.instance.database;
    final words = await db.query('new_words', orderBy: 'added_at DESC');
    setState(() => _newWords = words);
  }

  Future<void> _addWord(String char) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('new_words', {'char': char});
    _loadNewWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生字本')),
      body: ListView.builder(
        itemCount: _newWords.length,
        itemBuilder: (context, index) {
          final word = _newWords[index];
          return ListTile(
            title: Text(word['char'], style: const TextStyle(fontSize: 24)),
            subtitle: Text('掌握度: ${word['mastery_level']}/5'),
            trailing: Text('复习${word['review_count']}次'),
          );
        },
      ),
    );
  }
}
