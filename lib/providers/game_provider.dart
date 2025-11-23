import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/game_preset.dart';

class GameProvider extends ChangeNotifier {
  final Box<Player> _playerBox = Hive.box<Player>('players');
  final Box<Game> _gameBox = Hive.box<Game>('games');
  final Box<GamePreset> _presetBox = Hive.box<GamePreset>('presets');
  final Uuid _uuid = const Uuid();

  List<Player> get players => _playerBox.values.toList();
  List<Game> get games => _gameBox.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // Du plus récent au plus ancien

  // --- Presets ---
  List<GamePreset> get presets => _presetBox.values.toList();

  Future<void> addPreset({
    required String title,
    required bool isInverseScore,
    int? targetScore,
    int? targetRounds,
  }) async {
    final preset = GamePreset(
      id: _uuid.v4(),
      title: title,
      isInverseScore: isInverseScore,
      targetScore: targetScore,
      targetRounds: targetRounds,
      isCustom: true,
    );
    await _presetBox.put(preset.id, preset);
    notifyListeners();
  }

  Future<void> deletePreset(String id) async {
    if (_presetBox.containsKey(id)) {
      await _presetBox.delete(id);
      notifyListeners();
    }
  }

  // --- Players Logic ---

  Future<void> addPlayer(String name, {bool isDefault = false}) async {
    final id = _uuid.v4();
    final newPlayer = Player(id: id, name: name, isDefault: isDefault);
    await _playerBox.put(id, newPlayer);
    notifyListeners();
  }

  Future<void> deletePlayer(String id) async {
    await _playerBox.delete(id);
    notifyListeners();
  }

  Player? getPlayer(String id) {
    return _playerBox.get(id);
  }

  Future<void> setPlayerDefault(String id, bool isDefault) async {
    final player = getPlayer(id);
    if (player == null) return;
    player.isDefault = isDefault;
    await player.save();
    notifyListeners();
  }

  List<String> getDefaultPlayerIds() {
    return players.where((p) => p.isDefault).map((p) => p.id).toList();
  }

  Future<void> clearDefaultPlayers() async {
    final defaults = players.where((p) => p.isDefault).toList();
    for (final player in defaults) {
      player.isDefault = false;
      await player.save();
    }
    if (defaults.isNotEmpty) {
      notifyListeners();
    }
  }

  // --- Game Logic ---

  Future<String> createGame(
      String title, List<String> playerIds, bool isInverse,
      {int? targetScore, int? targetRounds}) async {
    final id = _uuid.v4();
    // Initialiser les scores vides pour chaque joueur
    final Map<String, List<int?>> initialScores = {};
    for (var pId in playerIds) {
      initialScores[pId] = [];
    }

    final newGame = Game(
      id: id,
      title: title.isEmpty ? DateTime.now().toString().split(' ')[0] : title,
      date: DateTime.now(),
      playersIds: playerIds,
      scores: initialScores,
      isInverseScore: isInverse,
      targetScore: targetScore,
      targetRounds: targetRounds,
    );

    await _gameBox.put(id, newGame);
    notifyListeners();
    return id;
  }

  Game? getGame(String id) {
    return _gameBox.get(id);
  }

  Game? getLastGame() {
    if (_gameBox.isEmpty) return null;
    final sortedGames = games; // Utilise le getter trié
    return sortedGames.first;
  }

  List<String> getPreferredPlayerIds() {
    final defaults = getDefaultPlayerIds();
    if (defaults.isNotEmpty) return defaults;
    final last = getLastGame();
    if (last == null) return [];
    return last.playersIds.where((id) => _playerBox.containsKey(id)).toList();
  }

  /// Ajoute un nouveau tour avec des scores optionnels (null par défaut)
  Future<void> addRound(String gameId, [Map<String, int?>? newScores]) async {
    final game = getGame(gameId);
    if (game == null) return;

    game.scores.forEach((playerId, scoreList) {
      scoreList.add(newScores?[playerId]);
    });

    await game.save();
    notifyListeners();
  }

  /// Met à jour un score spécifique
  Future<void> updateScore(
      String gameId, String playerId, int roundIndex, int? newScore) async {
    final game = getGame(gameId);
    if (game == null) return;

    if (game.scores.containsKey(playerId) &&
        roundIndex < game.scores[playerId]!.length) {
      game.scores[playerId]![roundIndex] = newScore;
      await game.save();
      notifyListeners();
    }
  }

  int getPlayerTotal(String gameId, String playerId) {
    final game = getGame(gameId);
    if (game == null) return 0;

    final scores = game.scores[playerId];
    if (scores == null || scores.isEmpty) return 0;

    // On traite null comme 0 pour le calcul du total
    return scores.fold(0, (sum, current) => sum + (current ?? 0));
  }

  Future<void> finishGame(String gameId) async {
    final game = getGame(gameId);
    if (game != null) {
      game.isFinished = true;
      await game.save();
      notifyListeners();
    }
  }
}
