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

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
      };

  factory ScoreFieldDefinition.fromJson(Map<String, dynamic> json) {
    return ScoreFieldDefinition(
      key: json['key'] as String,
      label: json['label'] as String,
    );
  }
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

  @HiveField(11)
  final int? minPlayers;

  @HiveField(12)
  final int? maxPlayers;

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
    this.minPlayers,
    this.maxPlayers,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isInverseScore': isInverseScore,
        'targetScore': targetScore,
        'targetRounds': targetRounds,
        'isCustom': isCustom,
        'type': type.index,
        'roundLabels': roundLabels,
        'fields': fields?.map((f) => f.toJson()).toList(),
        'scoreFormula': scoreFormula,
        'scoringRules': scoringRules?.map((r) => r.toJson()).toList(),
        'minPlayers': minPlayers,
        'maxPlayers': maxPlayers,
      };

  factory GamePreset.fromJson(Map<String, dynamic> json) {
    return GamePreset(
      id: json['id'] as String,
      title: json['title'] as String,
      isInverseScore: json['isInverseScore'] as bool,
      targetScore: json['targetScore'] as int?,
      targetRounds: json['targetRounds'] as int?,
      isCustom: json['isCustom'] as bool? ?? false,
      type: GameType.values[json['type'] as int? ?? 0],
      roundLabels: (json['roundLabels'] as List<dynamic>?)?.cast<String>(),
      fields: (json['fields'] as List<dynamic>?)
          ?.map((e) => ScoreFieldDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      scoreFormula: json['scoreFormula'] as String?,
      scoringRules: (json['scoringRules'] as List<dynamic>?)
          ?.map((e) => ScoringRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      minPlayers: json['minPlayers'] as int?,
      maxPlayers: json['maxPlayers'] as int?,
    );
  }
}

@HiveType(typeId: 5)
class ScoringRule extends HiveObject {
  @HiveField(0)
  final String condition;

  @HiveField(1)
  final String formula;

  ScoringRule({required this.condition, required this.formula});

  Map<String, dynamic> toJson() => {
        'condition': condition,
        'formula': formula,
      };

  factory ScoringRule.fromJson(Map<String, dynamic> json) {
    return ScoringRule(
      condition: json['condition'] as String,
      formula: json['formula'] as String,
    );
  }
}
