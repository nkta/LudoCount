import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/game_preset.dart';
import '../services/preset_service.dart';

class PresetRepository extends ChangeNotifier {
  PresetRepository({required PresetService presetService})
      : _service = presetService;

  final PresetService _service;
  final _uuid = const Uuid();

  List<GamePreset> get presets => _service.getAll();

  GamePreset? get(String id) => _service.get(id);

  bool containsKey(String id) => _service.containsKey(id);

  List<GamePreset> getByTitle(String title) =>
      _service.getAll().where((p) => p.title == title).toList();

  Future<void> add({
    required String title,
    required bool isInverseScore,
    int? targetScore,
    int? targetRounds,
    GameType type = GameType.standard,
    List<String>? roundLabels,
    List<ScoreFieldDefinition>? fields,
    String? scoreFormula,
    List<ScoringRule>? scoringRules,
    bool isCustom = true,
    int? minPlayers,
    int? maxPlayers,
  }) async {
    final preset = GamePreset(
      id: _uuid.v4(),
      title: title,
      isInverseScore: isInverseScore,
      targetScore: targetScore,
      targetRounds: targetRounds,
      isCustom: isCustom,
      type: type,
      roundLabels: roundLabels,
      fields: fields,
      scoreFormula: scoreFormula,
      scoringRules: scoringRules,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
    );
    await _service.put(preset.id, preset);
    notifyListeners();
  }

  Future<void> save(GamePreset preset) async {
    await _service.put(preset.id, preset);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    if (_service.containsKey(id)) {
      await _service.delete(id);
      notifyListeners();
    }
  }
}
