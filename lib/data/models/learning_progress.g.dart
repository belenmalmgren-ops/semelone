part of 'user_data.dart';

/// LearningProgress 的 Hive 适配器
class LearningProgressAdapter extends TypeAdapter<LearningProgress> {
  @override
  final int typeId = 2;

  @override
  LearningProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return LearningProgress(
      character: fields[0] as String,
      reviewCount: fields[1] as int,
      lastReview: fields[2] as DateTime,
      isMarkedDifficult: fields[3] as bool,
      masteryLevel: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LearningProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.character)
      ..writeByte(1)
      ..write(obj.reviewCount)
      ..writeByte(2)
      ..write(obj.lastReview)
      ..writeByte(3)
      ..write(obj.isMarkedDifficult)
      ..writeByte(4)
      ..write(obj.masteryLevel);
  }
}
