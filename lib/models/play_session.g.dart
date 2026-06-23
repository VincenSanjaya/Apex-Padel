// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaySessionAdapter extends TypeAdapter<PlaySession> {
  @override
  final int typeId = 3;

  @override
  PlaySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaySession(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      location: fields[2] as String,
      isActive: fields[3] as bool,
      matchIds: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PlaySession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.matchIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaySessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
