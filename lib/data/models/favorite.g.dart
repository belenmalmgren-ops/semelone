part of 'user_data.dart';

/// Favorite 的 Hive 适配器
class FavoriteAdapter extends TypeAdapter<Favorite> {
  @override
  final int typeId = 1;

  @override
  Favorite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Favorite(
      character: fields[0] as String,
      category: fields[1] as String,
      addedAt: fields[2] as DateTime,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Favorite obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.character)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.addedAt)
      ..writeByte(3)
      ..write(obj.note);
  }
}
