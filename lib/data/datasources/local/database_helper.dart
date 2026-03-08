import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

/// 数据库帮助类 - 负责初始化和版本管理
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// 获取数据库实例（单例模式）
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Web平台：直接从assets加载到内存数据库
      debugPrint('[DatabaseHelper] Web平台：从assets加载数据库');
      ByteData data = await rootBundle.load('assets/db/xinhua_dict.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      return await databaseFactoryFfiWeb.openDatabase(
        'xinhua_dict.db',
        options: OpenDatabaseOptions(
          version: 1,
          onUpgrade: _onUpgrade,
          singleInstance: true,
        ),
      );
    }

    // 移动/桌面平台：使用文件系统
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'xinhua_dict.db');

    debugPrint('[DatabaseHelper] 数据库路径：$path');

    final exists = await databaseExists(path);

    if (!exists) {
      debugPrint('[DatabaseHelper] 数据库不存在，从assets复制...');
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        debugPrint('[DatabaseHelper] 创建目录失败: $e');
      }

      try {
        ByteData data = await rootBundle.load('assets/db/xinhua_dict.db.gz');
        debugPrint('[DatabaseHelper] 压缩文件加载成功: ${data.lengthInBytes} bytes');
        List<int> compressed = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        List<int> bytes = GZipCodec().decode(compressed);
        debugPrint('[DatabaseHelper] 解压完成: ${bytes.length} bytes');
        await File(path).writeAsBytes(bytes, flush: true);
        debugPrint('[DatabaseHelper] ✓ 数据库复制完成');
      } catch (e) {
        debugPrint('[DatabaseHelper] ❌ 数据库复制失败: $e');
        rethrow;
      }
    } else {
      debugPrint('[DatabaseHelper] 数据库已存在，跳过复制');
    }

    return await openDatabase(
      path,
      version: 1,
      onUpgrade: _onUpgrade,
      singleInstance: true,
    ).then((db) async {
      // 验证数据库
      try {
        final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM characters')
        ) ?? 0;
        debugPrint('[DatabaseHelper] ✓ 数据库打开成功，共 $count 条记录');
      } catch (e) {
        debugPrint('[DatabaseHelper] ❌ 数据库验证失败: $e');
      }
      return db;
    });
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    print('[DatabaseHelper] 开始创建数据库表...');

    // 创建 characters 表（核心词库）
    await db.execute('''
      CREATE TABLE characters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        char TEXT UNIQUE NOT NULL,
        pinyin TEXT NOT NULL,
        radical TEXT,
        stroke_count INTEGER,
        structure TEXT,
        definitions TEXT,
        words TEXT,
        examples TEXT,
        origin TEXT,
        stroke_order TEXT
      )
    ''');
    print('[DatabaseHelper] ✓ characters 表创建完成');

    // 创建索引（优化查询性能）
    await db.execute('CREATE INDEX idx_pinyin ON characters(pinyin)');
    await db.execute('CREATE INDEX idx_radical ON characters(radical)');
    await db.execute('CREATE INDEX idx_stroke ON characters(stroke_count)');
    await db.execute(
        'CREATE INDEX idx_pinyin_stroke ON characters(pinyin, stroke_count)');
    print('[DatabaseHelper] ✓ 索引创建完成');

    // 创建 FTS5 全文检索索引（可选功能，不影响核心功能）
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE characters_fts USING fts5(
          char,
          pinyin,
          definitions,
          content='characters'
        )
      ''');
      print('[DatabaseHelper] ✓ FTS5 全文检索索引创建完成');

      // 创建触发器（自动同步 FTS 索引）
      await db.execute('''
        CREATE TRIGGER characters_ai AFTER INSERT ON characters BEGIN
          INSERT INTO characters_fts(rowid, char, pinyin, definitions)
          VALUES (new.id, new.char, new.pinyin, new.definitions);
        END
      ''');

      await db.execute('''
        CREATE TRIGGER characters_ad AFTER DELETE ON characters BEGIN
          INSERT INTO characters_fts(characters_fts, rowid, char, pinyin, definitions)
          VALUES('delete', old.id, old.char, old.pinyin, old.definitions);
        END
      ''');

      await db.execute('''
        CREATE TRIGGER characters_au AFTER UPDATE ON characters BEGIN
          INSERT INTO characters_fts(characters_fts, rowid, char, pinyin, definitions)
          VALUES('delete', old.id, old.char, old.pinyin, old.definitions);
          INSERT INTO characters_fts(rowid, char, pinyin, definitions)
          VALUES (new.id, new.char, new.pinyin, new.definitions);
        END
      ''');
      print('[DatabaseHelper] ✓ FTS 触发器创建完成');
    } catch (e) {
      print('[DatabaseHelper] ⚠️ FTS5 不可用（设备SQLite不支持），使用基础搜索: $e');
      // FTS5 不可用不影响应用核心功能，继续运行
    }

    print('[DatabaseHelper] 数据库初始化完成！');
  }

  /// 数据库升级处理
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('[DatabaseHelper] 数据库升级：v$oldVersion -> v$newVersion');
    // 未来版本升级逻辑
  }

  /// 重置数据库（用于测试或重新初始化）
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'xinhua_dict.db');
    await deleteDatabase(path);
    print('[DatabaseHelper] 数据库已重置');
  }

  /// 获取数据库统计信息
  Future<Map<String, int>> getStats() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM characters')) ??
        0;
    return {'characters': count};
  }
}
