import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/repositories/preset_repository.dart';
import 'package:ludocount/data/services/preset_share_service.dart';
import 'package:ludocount/domain/use_cases/export_preset_file_use_case.dart';
import 'package:ludocount/domain/use_cases/import_preset_file_use_case.dart';

class PresetsViewModel extends ChangeNotifier {
  PresetsViewModel({
    required PresetRepository presetRepository,
    required ExportPresetFileUseCase exportPresetFileUseCase,
    required ImportPresetFileUseCase importPresetFileUseCase,
  })  : _repository = presetRepository,
        _exportPresetFile = exportPresetFileUseCase,
        _importPresetFile = importPresetFileUseCase {
    _repository.addListener(notifyListeners);
  }

  final PresetRepository _repository;
  final ExportPresetFileUseCase _exportPresetFile;
  final ImportPresetFileUseCase _importPresetFile;

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

  /// Exporte [preset] dans un fichier et le propose au partage système.
  Future<void> exportPresetToFile(GamePreset preset, {String? subject}) =>
      _exportPresetFile(preset, subject: subject);

  /// Ouvre le sélecteur de fichiers et décode le preset choisi.
  /// Retourne null si l'utilisateur annule.
  Future<GamePreset?> importPresetFromFile({String? dialogTitle}) =>
      _importPresetFile(dialogTitle: dialogTitle);

  /// Titre libre le plus proche de [title], suffixé si un preset porte déjà
  /// ce nom : « Skull King » devient « Skull King (2) ».
  String availableTitle(String title) {
    if (_repository.getByTitle(title).isEmpty) return title;
    var index = 2;
    while (_repository.getByTitle('$title ($index)').isNotEmpty) {
      index++;
    }
    return '$title ($index)';
  }

  /// Ajoute une copie de [original] à la collection et retourne le preset
  /// réellement enregistré, dont le titre peut avoir été suffixé.
  Future<GamePreset> importPreset(GamePreset original) async {
    final newPreset = GamePreset(
      id: const Uuid().v4(),
      title: availableTitle(original.title),
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
    return newPreset;
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}
