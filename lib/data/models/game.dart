import 'package:hive/hive.dart';
import 'game_preset.dart';

part 'game.g.dart';

@HiveType(typeId: 1)
class Game extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final List<String> playersIds;

  @HiveField(4)
  final Map<String, List<int?>> scores;

  @HiveField(5)
  final bool isInverseScore;

  @HiveField(6)
  bool isFinished;

  @HiveField(7)
  int? targetScore;

  @HiveField(8)
  int? targetRounds;

  @HiveField(9)
  final GameType type;

  @HiveField(10)
  final List<String>? roundLabels;

  @HiveField(11)
  Map<String, List<Map<String, int>?>>? roundData;

  @HiveField(12)
  final List<ScoreFieldDefinition>? fields;

  @HiveField(13)
  final String? scoreFormula;

  @HiveField(14)
  final List<ScoringRule>? scoringRules;

  Game({
    required this.id,
    required this.title,
    required this.date,
    required this.playersIds,
    required this.scores,
    this.isInverseScore = false,
    this.isFinished = false,
    this.targetScore,
    this.targetRounds,
    this.type = GameType.standard,
    this.roundLabels,
    this.roundData,
    this.fields,
    this.scoreFormula,
    this.scoringRules,
  });
}
