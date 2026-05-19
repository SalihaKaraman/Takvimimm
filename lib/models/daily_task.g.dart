// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyTaskAdapter extends TypeAdapter<DailyTask> {
  @override
  final int typeId = 0;

  @override
  DailyTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyTask(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      dateKey: fields[3] as String,
      hour: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.dateKey)
      ..writeByte(4)
      ..write(obj.hour);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
