part of 'user_data.dart';

/// SearchHistory 的 Hive 适配器
class SearchHistoryAdapter extends TypeAdapter<SearchHistory> {
  @override
  final int typeId = 0;

  @override
  SearchHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SearchHistory(
      character: fields[0] as String,
      timestamp: fields[1] as DateTime,
      searchMethod: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.character)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.searchMethod);
  }
}
