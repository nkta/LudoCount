import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/models/player.dart';
import 'package:ludocount/data/repositories/game_repository.dart';
import 'package:ludocount/data/repositories/player_repository.dart';
import 'package:ludocount/data/repositories/preset_repository.dart';
import 'package:ludocount/l10n/app_localizations.dart';

class GameConfigViewModel extends ChangeNotifier {
  GameConfigViewModel({
    required PlayerRepository playerRepository,
    required GameRepository gameRepository,
    required PresetRepository presetRepository,
  })  : _playerRepo = playerRepository,
        _gameRepo = gameRepository,
        _presetRepo = presetRepository {
    _playerRepo.addListener(notifyListeners);
    _presetRepo.addListener(notifyListeners);
    _initDefaultSelection();
  }

  final PlayerRepository _playerRepo;
  final GameRepository _gameRepo;
  final PresetRepository _presetRepo;

  final List<String> selectedPlayerIds = [];
  bool _initialized = false;

  String? selectedPresetId;
  bool isInverseScore = false;
  GameType selectedGameType = GameType.standard;
  List<String>? roundLabels;
  List<ScoreFieldDefinition>? fields;
  String? scoreFormula;
  List<ScoringRule>? scoringRules;
  int? minPlayers;
  int? maxPlayers;

  List<Player> get players => _playerRepo.players;
  List<GamePreset> get presets => _presetRepo.presets;

  void _initDefaultSelection() {
    if (_initialized) return;
    final defaults = _playerRepo.defaultPlayerIds;
    if (defaults.isNotEmpty) {
      selectedPlayerIds.addAll(defaults);
      _initialized = true;
    }
  }

  void applyPreset(GamePreset preset) {
    isInverseScore = preset.isInverseScore;
    selectedGameType = preset.type;
    roundLabels = preset.roundLabels;
    fields = preset.fields;
    scoreFormula = preset.scoreFormula;
    scoringRules = preset.scoringRules;
    minPlayers = preset.minPlayers;
    maxPlayers = preset.maxPlayers;
    notifyListeners();
  }

  void clearPreset() {
    selectedPresetId = null;
    selectedGameType = GameType.standard;
    roundLabels = null;
    fields = null;
    scoreFormula = null;
    scoringRules = null;
    minPlayers = null;
    maxPlayers = null;
    notifyListeners();
  }

  void setIsInverseScore(bool val) {
    isInverseScore = val;
    notifyListeners();
  }

  void togglePlayer(String playerId) {
    if (selectedPlayerIds.contains(playerId)) {
      selectedPlayerIds.remove(playerId);
    } else {
      selectedPlayerIds.add(playerId);
    }
    notifyListeners();
  }

  String resolveTitle(String rawTitle, AppLocalizations l10n) {
    if (rawTitle.isNotEmpty) return rawTitle;
    if (selectedPresetId != null) {
      final preset = _presetRepo.get(selectedPresetId!);
      if (preset != null) return preset.title;
    }
    return l10n
        .defaultGameTitle(DateFormat('yyyy-MM-dd').format(DateTime.now()));
  }

  Future<String> createGame({
    required String rawTitle,
    required AppLocalizations l10n,
    int? targetScore,
    int? targetRounds,
  }) {
    return _gameRepo.create(
      resolveTitle(rawTitle, l10n),
      selectedPlayerIds,
      isInverseScore,
      targetScore: targetScore,
      targetRounds: targetRounds,
      type: selectedGameType,
      roundLabels: roundLabels,
      fields: fields,
      scoreFormula: scoreFormula,
      scoringRules: scoringRules,
    );
  }

  @override
  void dispose() {
    _playerRepo.removeListener(notifyListeners);
    _presetRepo.removeListener(notifyListeners);
    super.dispose();
  }
}
