// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayEntryAdapter extends TypeAdapter<DayEntry> {
  @override
  final int typeId = 1;

  @override
  DayEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayEntry(
      dateKey: fields[0] as String,
      dailyNote: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DayEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.dailyNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
