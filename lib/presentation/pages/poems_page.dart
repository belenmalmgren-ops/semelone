import 'package:flutter/material.dart';
import '../../data/datasources/local/database_helper.dart';

class PoemsPage extends StatefulWidget {
  const PoemsPage({super.key});

  @override
  State<PoemsPage> createState() => _PoemsPageState();
}

class _PoemsPageState extends State<PoemsPage> {
  List<Map<String, dynamic>> _poems = [];

  @override
  void initState() {
    super.initState();
    _loadPoems();
  }

  Future<void> _loadPoems() async {
    final db = await DatabaseHelper.instance.database;
    final poems = await db.query('poems', limit: 100);
    setState(() => _poems = poems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('古诗词')),
      body: ListView.builder(
        itemCount: _poems.length,
        itemBuilder: (context, index) {
          final poem = _poems[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(poem['title'] ?? ''),
              subtitle: Text('${poem['author']} · ${poem['dynasty']}'),
              onTap: () => _showPoemDetail(poem),
            ),
          );
        },
      ),
    );
  }

  void _showPoemDetail(Map<String, dynamic> poem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(poem['title'] ?? ''),
        content: SingleChildScrollView(
          child: Text(poem['content'] ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
