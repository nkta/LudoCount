// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 1;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      playersIds: (fields[3] as List).cast<String>(),
      scores: (fields[4] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<int?>())),
      isInverseScore: fields[5] as bool,
      isFinished: fields[6] as bool,
      targetScore: fields[7] as int?,
      targetRounds: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.playersIds)
      ..writeByte(4)
      ..write(obj.scores)
      ..writeByte(5)
      ..write(obj.isInverseScore)
      ..writeByte(6)
      ..write(obj.isFinished)
      ..writeByte(7)
      ..write(obj.targetScore)
      ..writeByte(8)
      ..write(obj.targetRounds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
