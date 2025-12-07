import 'package:hive/hive.dart';

part 'game_preset.g.dart';

@HiveType(typeId: 3)
enum GameType {
  @HiveField(0)
  standard,
  @HiveField(1)
  sevenWonders,
  @HiveField(2)
  skullKing,
}

@HiveType(typeId: 4)
class ScoreFieldDefinition extends HiveObject {
  @HiveField(0)
  final String key; // ex: 'bid', 'tricks'

  @HiveField(1)
  final String label; // ex: 'Pari', 'Plis'

  ScoreFieldDefinition({required this.key, required this.label});
}

@HiveType(typeId: 2)
class GamePreset extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isInverseScore;

  @HiveField(3)
  final int? targetScore;

  @HiveField(4)
  final int? targetRounds;

  @HiveField(5)
  final bool isCustom;

  @HiveField(6)
  final GameType type;

  @HiveField(7)
  final List<String>? roundLabels;

  @HiveField(8)
  final List<ScoreFieldDefinition>? fields;

  @HiveField(9)
  final String? scoreFormula;

  @HiveField(10)
  final List<ScoringRule>? scoringRules;

  GamePreset({
    required this.id,
    required this.title,
    required this.isInverseScore,
    this.targetScore,
    this.targetRounds,
    this.isCustom = false,
    this.type = GameType.standard,
    this.roundLabels,
    this.fields,
    this.scoreFormula,
    this.scoringRules,
  });
}

@HiveType(typeId: 5)
class ScoringRule extends HiveObject {
  @HiveField(0)
  final String condition;

  @HiveField(1)
  final String formula;

  ScoringRule({required this.condition, required this.formula});
}
