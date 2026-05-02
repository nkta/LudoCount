import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/repositories/preset_repository.dart';

class ExpertPresetConfigViewModel extends ChangeNotifier {
  ExpertPresetConfigViewModel({
    required PresetRepository presetRepository,
    GamePreset? preset,
  })  : _repository = presetRepository,
        _existingId = preset?.id,
        _existingType = preset?.type ?? GameType.standard {
    if (preset != null) _initFromPreset(preset);
  }

  final PresetRepository _repository;
  final String? _existingId;
  final GameType _existingType;

  final List<ScoreFieldDefinition> fields = [];
  final List<ScoringRule> rules = [];
  bool useConditionalRules = false;
  bool isInverseScore = false;
  bool useCustomRoundLabels = false;
  int? targetRounds;
  int? minPlayers;
  int? maxPlayers;
  List<String>? initialRoundLabels;

  void _initFromPreset(GamePreset p) {
    if (p.fields != null) fields.addAll(p.fields!);
    if (p.scoringRules != null && p.scoringRules!.isNotEmpty) {
      rules.addAll(p.scoringRules!);
      useConditionalRules = true;
    }
    isInverseScore = p.isInverseScore;
    targetRounds = p.targetRounds;
    minPlayers = p.minPlayers;
    maxPlayers = p.maxPlayers;
    if (p.roundLabels != null && p.roundLabels!.isNotEmpty) {
      useCustomRoundLabels = true;
      initialRoundLabels = p.roundLabels;
    }
  }

  void addField(String key, String label) {
    fields.add(ScoreFieldDefinition(key: key, label: label));
    notifyListeners();
  }

  void removeField(int index) {
    fields.removeAt(index);
    notifyListeners();
  }

  void addDefaultFields() {
    var changed = false;
    if (!fields.any((f) => f.key == 'bid')) {
      fields.add(ScoreFieldDefinition(key: 'bid', label: 'Pari'));
      changed = true;
    }
    if (!fields.any((f) => f.key == 'tricks')) {
      fields.add(ScoreFieldDefinition(key: 'tricks', label: 'Plis'));
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void addRule() {
    rules.add(ScoringRule(condition: '', formula: ''));
    notifyListeners();
  }

  void removeRule(int index) {
    rules.removeAt(index);
    notifyListeners();
  }

  void updateRule(int index, ScoringRule rule) {
    rules[index] = rule;
  }

  void setUseConditionalRules(bool value) {
    useConditionalRules = value;
    notifyListeners();
  }

  void setIsInverseScore(bool value) {
    isInverseScore = value;
    notifyListeners();
  }

  void setUseCustomRoundLabels(bool value) {
    useCustomRoundLabels = value;
    notifyListeners();
  }

  Future<void> save({
    required String title,
    required String formula,
    required List<String>? roundLabels,
  }) async {
    await _repository.save(GamePreset(
      id: _existingId ?? const Uuid().v4(),
      title: title,
      isInverseScore: isInverseScore,
      targetRounds: targetRounds,
      fields: fields,
      scoreFormula: useConditionalRules ? null : formula,
      scoringRules: useConditionalRules ? rules : null,
      roundLabels: roundLabels,
      isCustom: true,
      type: _existingType,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
    ));
  }
}
