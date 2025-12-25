// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_preset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreFieldDefinitionAdapter extends TypeAdapter<ScoreFieldDefinition> {
  @override
  final int typeId = 4;

  @override
  ScoreFieldDefinition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreFieldDefinition(
      key: fields[0] as String,
      label: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScoreFieldDefinition obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreFieldDefinitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GamePresetAdapter extends TypeAdapter<GamePreset> {
  @override
  final int typeId = 2;

  @override
  GamePreset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GamePreset(
      id: fields[0] as String,
      title: fields[1] as String,
      isInverseScore: fields[2] as bool,
      targetScore: fields[3] as int?,
      targetRounds: fields[4] as int?,
      isCustom: fields[5] as bool,
      type: fields[6] as GameType,
      roundLabels: (fields[7] as List?)?.cast<String>(),
      fields: (fields[8] as List?)?.cast<ScoreFieldDefinition>(),
      scoreFormula: fields[9] as String?,
      scoringRules: (fields[10] as List?)?.cast<ScoringRule>(),
      minPlayers: fields[11] as int?,
      maxPlayers: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, GamePreset obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isInverseScore)
      ..writeByte(3)
      ..write(obj.targetScore)
      ..writeByte(4)
      ..write(obj.targetRounds)
      ..writeByte(5)
      ..write(obj.isCustom)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.roundLabels)
      ..writeByte(8)
      ..write(obj.fields)
      ..writeByte(9)
      ..write(obj.scoreFormula)
      ..writeByte(10)
      ..write(obj.scoringRules)
      ..writeByte(11)
      ..write(obj.minPlayers)
      ..writeByte(12)
      ..write(obj.maxPlayers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScoringRuleAdapter extends TypeAdapter<ScoringRule> {
  @override
  final int typeId = 5;

  @override
  ScoringRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoringRule(
      condition: fields[0] as String,
      formula: fields[1] as String?,
      rules: (fields[2] as List?)?.cast<ScoringRule>(),
      id: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScoringRule obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.condition)
      ..writeByte(1)
      ..write(obj.formula)
      ..writeByte(2)
      ..write(obj.rules)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoringRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameTypeAdapter extends TypeAdapter<GameType> {
  @override
  final int typeId = 3;

  @override
  GameType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameType.standard;
      case 1:
        return GameType.sevenWonders;
      case 2:
        return GameType.skullKing;
      default:
        return GameType.standard;
    }
  }

  @override
  void write(BinaryWriter writer, GameType obj) {
    switch (obj) {
      case GameType.standard:
        writer.writeByte(0);
        break;
      case GameType.sevenWonders:
        writer.writeByte(1);
        break;
      case GameType.skullKing:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
