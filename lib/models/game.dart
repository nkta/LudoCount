import 'package:hive/hive.dart';

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
  });
}
