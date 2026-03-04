/// 汉字数据模型
class Character {
  final int id;
  final String char;
  final String pinyin;
  final String? radical;
  final int? strokeCount;
  final String? structure;
  final List<String>? definitions;
  final List<String>? words;
  final List<String>? examples;
  final String? origin;
  final String? strokeOrder;

  Character({
    required this.id,
    required this.char,
    required this.pinyin,
    this.radical,
    this.strokeCount,
    this.structure,
    this.definitions,
    this.words,
    this.examples,
    this.origin,
    this.strokeOrder,
  });

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'],
      char: map['char'],
      pinyin: map['pinyin'],
      radical: map['radical'],
      strokeCount: map['stroke_count'],
      structure: map['structure'],
      definitions: map['definitions'] != null
          ? (map['definitions'] as String).split('|')
          : null,
      words: map['words'] != null
          ? (map['words'] as String).split('|')
          : null,
      examples: map['examples'] != null
          ? (map['examples'] as String).split('|')
          : null,
      origin: map['origin'],
      strokeOrder: map['stroke_order'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'char': char,
      'pinyin': pinyin,
      'radical': radical,
      'stroke_count': strokeCount,
      'structure': structure,
      'definitions': definitions?.join('|'),
      'words': words?.join('|'),
      'examples': examples?.join('|'),
      'origin': origin,
      'stroke_order': strokeOrder,
    };
  }
}
