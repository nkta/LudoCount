import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/repositories/preset_repository.dart';
import 'package:ludocount/data/services/preset_share_service.dart';

class PresetsViewModel extends ChangeNotifier {
  PresetsViewModel({required PresetRepository presetRepository})
      : _repository = presetRepository {
    _repository.addListener(notifyListeners);
  }

  final PresetRepository _repository;

  List<GamePreset> get presets => _repository.presets;

  Future<void> deletePreset(String id) => _repository.delete(id);

  Future<void> savePreset(GamePreset preset) => _repository.save(preset);

  Future<void> addPreset({
    required String title,
    required bool isInverseScore,
    int? targetScore,
    int? targetRounds,
    GameType type = GameType.standard,
    int? minPlayers,
    int? maxPlayers,
    List<ScoreFieldDefinition>? fields,
    String? scoreFormula,
    List<ScoringRule>? scoringRules,
    List<String>? roundLabels,
  }) =>
      _repository.add(
        title: title,
        isInverseScore: isInverseScore,
        targetScore: targetScore,
        targetRounds: targetRounds,
        type: type,
        minPlayers: minPlayers,
        maxPlayers: maxPlayers,
        fields: fields,
        scoreFormula: scoreFormula,
        scoringRules: scoringRules,
        roundLabels: roundLabels,
      );

  String encodePreset(GamePreset preset) =>
      PresetShareService.encodePreset(preset);

  GamePreset decodePreset(String code) =>
      PresetShareService.decodePreset(code);

  Future<void> importPreset(GamePreset original) async {
    final newPreset = GamePreset(
      id: const Uuid().v4(),
      title: original.title,
      isInverseScore: original.isInverseScore,
      targetScore: original.targetScore,
      targetRounds: original.targetRounds,
      isCustom: original.isCustom,
      type: original.type,
      roundLabels: original.roundLabels,
      fields: original.fields,
      scoreFormula: original.scoreFormula,
      scoringRules: original.scoringRules,
      minPlayers: original.minPlayers,
      maxPlayers: original.maxPlayers,
    );
    await _repository.save(newPreset);
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}
