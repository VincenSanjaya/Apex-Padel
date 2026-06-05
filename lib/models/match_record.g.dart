// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchRecordAdapter extends TypeAdapter<MatchRecord> {
  @override
  final int typeId = 2;

  @override
  MatchRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      location: fields[2] as String,
      partnerName: fields[3] as String?,
      result: fields[4] as MatchResult,
      scoringFormat: fields[5] as ScoringFormat,
      scoreData: fields[6] as String,
      ratingChange: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MatchRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.partnerName)
      ..writeByte(4)
      ..write(obj.result)
      ..writeByte(5)
      ..write(obj.scoringFormat)
      ..writeByte(6)
      ..write(obj.scoreData)
      ..writeByte(7)
      ..write(obj.ratingChange);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MatchResultAdapter extends TypeAdapter<MatchResult> {
  @override
  final int typeId = 0;

  @override
  MatchResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MatchResult.win;
      case 1:
        return MatchResult.loss;
      case 2:
        return MatchResult.draw;
      default:
        return MatchResult.win;
    }
  }

  @override
  void write(BinaryWriter writer, MatchResult obj) {
    switch (obj) {
      case MatchResult.win:
        writer.writeByte(0);
        break;
      case MatchResult.loss:
        writer.writeByte(1);
        break;
      case MatchResult.draw:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScoringFormatAdapter extends TypeAdapter<ScoringFormat> {
  @override
  final int typeId = 1;

  @override
  ScoringFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScoringFormat.traditional;
      case 1:
        return ScoringFormat.points;
      default:
        return ScoringFormat.traditional;
    }
  }

  @override
  void write(BinaryWriter writer, ScoringFormat obj) {
    switch (obj) {
      case ScoringFormat.traditional:
        writer.writeByte(0);
        break;
      case ScoringFormat.points:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoringFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
