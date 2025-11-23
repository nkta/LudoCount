import 'package:hive/hive.dart';

part 'game_preset.g.dart';

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

  GamePreset({
    required this.id,
    required this.title,
    required this.isInverseScore,
    this.targetScore,
    this.targetRounds,
    this.isCustom = false,
  });
}
