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
      type: fields[9] as GameType,
      roundLabels: (fields[10] as List?)?.cast<String>(),
      roundData: (fields[11] as Map?)?.map((dynamic k, dynamic v) => MapEntry(
          k as String,
          (v as List)
              .map((dynamic e) => (e as Map?)?.cast<String, int>())
              .toList())),
      fields: (fields[12] as List?)?.cast<ScoreFieldDefinition>(),
      scoreFormula: fields[13] as String?,
      scoringRules: (fields[14] as List?)?.cast<ScoringRule>(),
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(15)
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
      ..write(obj.targetRounds)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.roundLabels)
      ..writeByte(11)
      ..write(obj.roundData)
      ..writeByte(12)
      ..write(obj.fields)
      ..writeByte(13)
      ..write(obj.scoreFormula)
      ..writeByte(14)
      ..write(obj.scoringRules);
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
