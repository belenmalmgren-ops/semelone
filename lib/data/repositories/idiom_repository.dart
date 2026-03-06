import 'package:sqflite/sqflite.dart';
import '../models/idiom.dart';
import '../datasources/local/database_helper.dart';

/// 成语数据仓库 - 负责成语数据的增删改查
class IdiomRepository {
  static final IdiomRepository instance = IdiomRepository._init();
  late DatabaseHelper _dbHelper;
  Database? _db;

  IdiomRepository._init() {
    _dbHelper = DatabaseHelper.instance;
  }

  /// 获取数据库实例
  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _dbHelper.database;
    return _db!;
  }

  /// 初始化 - 确保成语表存在
  Future<void> init() async {
    final db = await _database;

    // 创建成语表（如果不存在）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS idioms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idiom TEXT UNIQUE NOT NULL,
        pinyin TEXT NOT NULL,
        definition TEXT,
        example TEXT,
        tags TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX IF NOT EXISTS idx_idiom_pinyin ON idioms(pinyin)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_idiom_first_char ON idioms(substring(idiom, 1, 1))');

    print('[IdiomRepository] 成语仓库初始化完成');
  }

  // ==================== 成语检索 ====================

  /// 成语搜索 - 支持按汉字、拼音搜索
  Future<List<Idiom>> search(String query) async {
    final db = await _database;

    // 支持按成语首字搜索
    final List<Map<String, dynamic>> maps = await db.query(
      'idioms',
      where: 'idiom LIKE ? OR pinyin LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'idiom ASC',
      limit: 100,
    );

    return _mapsToIdioms(maps);
  }

  /// 按首字搜索成语
  Future<List<Idiom>> searchByFirstChar(String char) async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      'idioms',
      where: 'substring(idiom, 1, 1) = ?',
      whereArgs: [char],
      orderBy: 'idiom ASC',
      limit: 100,
    );

    return _mapsToIdioms(maps);
  }

  /// 按拼音搜索成语
  Future<List<Idiom>> searchByPinyin(String pinyin) async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      'idioms',
      where: 'pinyin LIKE ?',
      whereArgs: ['%$pinyin%'],
      orderBy: 'idiom ASC',
      limit: 100,
    );

    return _mapsToIdioms(maps);
  }

  /// 获取所有成语（分页）
  Future<List<Idiom>> getAll({int limit = 50, int offset = 0}) async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      'idioms',
      orderBy: 'idiom ASC',
      limit: limit,
      offset: offset,
    );

    return _mapsToIdioms(maps);
  }

  /// 获取成语总数
  Future<int> getCount() async {
    final db = await _database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM idioms');
    return result.first['count'] as int? ?? 0;
  }

  /// 获取按首字分组的成语列表
  Future<Map<String, List<Idiom>>> getGroupByIdioms() async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      'idioms',
      orderBy: 'idiom ASC',
    );

    final idioms = _mapsToIdioms(maps);
    final Map<String, List<Idiom>> grouped = {};

    for (var idiom in idioms) {
      final firstChar = idiom.firstChar;
      if (!grouped.containsKey(firstChar)) {
        grouped[firstChar] = [];
      }
      grouped[firstChar]!.add(idiom);
    }

    return grouped;
  }

  // ==================== 工具方法 ====================

  List<Idiom> _mapsToIdioms(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) => Idiom.fromMap(maps[i]));
  }

  /// 获取统计信息
  Future<Map<String, int>> getStats() async {
    final count = await getCount();
    return {'total': count};
  }
}
