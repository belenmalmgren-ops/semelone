/// 成语模型
class Idiom {
  final int id;
  final String idiom;
  final String pinyin;
  final String definition;
  final String example;
  final String tags;

  Idiom({
    required this.id,
    required this.idiom,
    required this.pinyin,
    required this.definition,
    required this.example,
    this.tags = '',
  });

  /// 从 Map 创建 Idiom 实例
  factory Idiom.fromMap(Map<String, dynamic> map) {
    return Idiom(
      id: map['id'] as int,
      idiom: map['idiom'] as String,
      pinyin: map['pinyin'] as String,
      definition: map['definition'] as String? ?? '',
      example: map['example'] as String? ?? '',
      tags: map['tags'] as String? ?? '',
    );
  }

  /// 首个汉字
  String get firstChar => idiom.isNotEmpty ? idiom[0] : '';

  /// 释义列表（按句号分割）
  List<String> get definitions {
    if (definition.isEmpty) return [];
    return definition.split(RegExp("[,.]")).where((s) => s.trim().isNotEmpty).toList();
  }

  @override
  String toString() => 'Idiom(${idiom}: ${pinyin})';
}
