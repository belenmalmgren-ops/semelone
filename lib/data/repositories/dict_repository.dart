import 'package:sqflite/sqflite.dart';
import '../models/character.dart';
import '../datasources/local/database_helper.dart';

/// 字典数据仓库 - 负责汉字数据的增删改查
class DictRepository {
  static final DictRepository instance = DictRepository._init();
  late DatabaseHelper _dbHelper;

  DictRepository._init() {
    _dbHelper = DatabaseHelper.instance;
  }

  /// 获取数据库实例
  Future<Database> get _db => _dbHelper.database;

  /// 初始化数据库
  Future<void> init() async {
    await _db;
    print('[DictRepository] 字典仓库初始化完成');
  }

  // ==================== 拼音检索 ====================

  /// 拼音检索 - 支持全拼、简拼、模糊匹配
  /// [pinyin] 拼音输入（如 "zhang" 或 "zh" 或 "zhan*"）
  Future<List<Character>> searchByPinyin(String pinyin) async {
    final db = await _db;

    // 处理模糊查询：zhan* -> zhan%
    String queryPinyin = pinyin.replaceAll('*', '%');

    // 简拼匹配：zh -> z%h%
    if (pinyin.length <= 2 && !pinyin.contains('*')) {
      queryPinyin = pinyin.split('').join('%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'characters',
      where: 'pinyin LIKE ?',
      whereArgs: ['%$queryPinyin%'],
      orderBy: 'char ASC',
      limit: 100,
    );

    return List.generate(maps.length, (i) {
      return Character(
        id: maps[i]['id'] as int,
        char: maps[i]['char'] as String,
        pinyin: maps[i]['pinyin'] as String,
        radical: maps[i]['radical'] as String?,
        strokeCount: maps[i]['stroke_count'] as int?,
        structure: maps[i]['structure'] as String?,
        definitions: (maps[i]['definitions'] as String?)?.split('|'),
        words: (maps[i]['words'] as String?)?.split('|'),
        examples: (maps[i]['examples'] as String?)?.split('|'),
        origin: maps[i]['origin'] as String?,
        strokeOrder: maps[i]['stroke_order'] as String?,
      );
    });
  }

  /// 根据拼音精确匹配（用于多音字）
  Future<Character?> getByPinyinExact(String char, String pinyin) async {
    final db = await _db;

    final List<Map<String, dynamic>> maps = await db.query(
      'characters',
      where: 'char = ? AND pinyin LIKE ?',
      whereArgs: [char, '%$pinyin%'],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Character(
      id: maps.first['id'] as int,
      char: maps.first['char'] as String,
      pinyin: maps.first['pinyin'] as String,
      radical: maps.first['radical'] as String?,
      strokeCount: maps.first['stroke_count'] as int?,
      structure: maps.first['structure'] as String?,
      definitions: (maps.first['definitions'] as String?)?.split('|'),
      words: (maps.first['words'] as String?)?.split('|'),
      examples: (maps.first['examples'] as String?)?.split('|'),
      origin: maps.first['origin'] as String?,
      strokeOrder: maps.first['stroke_order'] as String?,
    );
  }

  // ==================== 部首检索 ====================

  /// 部首检索
  /// [radical] 部首（如 "氵"）
  /// [strokeCount] 可选的笔画数筛选
  Future<List<Character>> searchByRadical(
      String radical, int? strokeCount) async {
    final db = await _db;

    String where = 'radical = ?';
    List<dynamic> whereArgs = [radical];

    if (strokeCount != null) {
      where += ' AND stroke_count = ?';
      whereArgs.add(strokeCount);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'characters',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'stroke_count ASC, char ASC',
      limit: 100,
    );

    return _mapsToCharacters(maps);
  }

  /// 获取所有部首列表
  Future<List<String>> getAllRadicals() async {
    final db = await _db;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT radical FROM characters WHERE radical IS NOT NULL ORDER BY radical',
    );

    return maps.map((m) => m['radical'] as String).toList();
  }

  // ==================== 笔画检索 ====================

  /// 笔画检索
  /// [strokeCount] 笔画数
  /// [minStroke] 最小笔画数（范围查询）
  /// [maxStroke] 最大笔画数（范围查询）
  Future<List<Character>> searchByStroke(
      {int? strokeCount, int? minStroke, int? maxStroke}) async {
    final db = await _db;

    String? where;
    List<dynamic>? whereArgs;

    if (strokeCount != null) {
      where = 'stroke_count = ?';
      whereArgs = [strokeCount];
    } else if (minStroke != null && maxStroke != null) {
      where = 'stroke_count BETWEEN ? AND ?';
      whereArgs = [minStroke, maxStroke];
    } else if (minStroke != null) {
      where = 'stroke_count >= ?';
      whereArgs = [minStroke];
    } else if (maxStroke != null) {
      where = 'stroke_count <= ?';
      whereArgs = [maxStroke];
    }

    if (where == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'characters',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'stroke_count ASC, char ASC',
      limit: 100,
    );

    return _mapsToCharacters(maps);
  }

  // ==================== 汉字详情 ====================

  /// 根据汉字查询详情
  Future<Character?> getByChar(String char) async {
    final db = await _db;

    final List<Map<String, dynamic>> maps = await db.query(
      'characters',
      where: 'char = ?',
      whereArgs: [char],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return _mapsToCharacter(maps.first);
  }

  /// 根据 ID 查询
  Future<Character?> getById(int id) async {
    final db = await _db;

    final List<Map<String, dynamic>> maps = await db.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return _mapsToCharacter(maps.first);
  }

  // ==================== 全文检索 ====================

  /// 全文检索（FTS5）
  Future<List<Character>> fullTextSearch(String query) async {
    final db = await _db;

    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT c.* FROM characters c
        INNER JOIN characters_fts fts ON c.rowid = fts.rowid
        WHERE characters_fts MATCH ?
        LIMIT 100
      ''', ['$query*']);

      return _mapsToCharacters(maps);
    } catch (e) {
      print('[DictRepository] FTS 搜索失败：$e');
      return [];
    }
  }

  // ==================== 批量操作 ====================

  /// 批量插入汉字（用于初始化词库）
  Future<int> batchInsert(List<Character> characters) async {
    final db = await _db;

    int count = 0;
    await db.transaction((txn) async {
      for (var char in characters) {
        try {
          await txn.insert('characters', char.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          count++;
        } catch (e) {
          print('[DictRepository] 插入失败：${char.char}, 错误：$e');
        }
      }
    });

    print('[DictRepository] 批量插入完成：$count/${characters.length}');
    return count;
  }

  /// 清空词库
  Future<void> clearAll() async {
    final db = await _db;
    await db.delete('characters');
    print('[DictRepository] 词库已清空');
  }

  // ==================== 工具方法 ====================

  Character _mapsToCharacter(Map<String, dynamic> map) {
    return Character(
      id: map['id'] as int,
      char: map['char'] as String,
      pinyin: map['pinyin'] as String,
      radical: map['radical'] as String?,
      strokeCount: map['stroke_count'] as int?,
      structure: map['structure'] as String?,
      definitions: (map['definitions'] as String?)?.split('|'),
      words: (map['words'] as String?)?.split('|'),
      examples: (map['examples'] as String?)?.split('|'),
      origin: map['origin'] as String?,
      strokeOrder: map['stroke_order'] as String?,
    );
  }

  List<Character> _mapsToCharacters(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) => _mapsToCharacter(maps[i]));
  }

  /// 获取词库统计
  Future<Map<String, int>> getStats() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM characters')) ??
        0;
    return {'total': count};
  }
}
