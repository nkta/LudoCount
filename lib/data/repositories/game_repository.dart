import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/game_preset.dart';
import '../services/game_service.dart';

class GameRepository extends ChangeNotifier {
  GameRepository({required GameService gameService}) : _service = gameService;

  final GameService _service;
  final _uuid = const Uuid();

  List<Game> get games =>
      _service.getAll()..sort((a, b) => b.date.compareTo(a.date));

  Game? get(String id) => _service.get(id);

  Game? getLast() {
    if (_service.isEmpty) return null;
    return games.first;
  }

  Future<String> create(
    String title,
    List<String> playerIds,
    bool isInverse, {
    int? targetScore,
    int? targetRounds,
    GameType type = GameType.standard,
    List<String>? roundLabels,
    List<ScoreFieldDefinition>? fields,
    String? scoreFormula,
    List<ScoringRule>? scoringRules,
  }) async {
    final id = _uuid.v4();
    final Map<String, List<int?>> initialScores = {};
    for (final pId in playerIds) {
      initialScores[pId] = roundLabels != null
          ? List.filled(roundLabels.length, null)
          : [];
    }

    await _service.put(
      id,
      Game(
        id: id,
        title: title.isEmpty ? DateTime.now().toString().split(' ')[0] : title,
        date: DateTime.now(),
        playersIds: playerIds,
        scores: initialScores,
        isInverseScore: isInverse,
        targetScore: targetScore,
        targetRounds: targetRounds,
        type: type,
        roundLabels: roundLabels,
        fields: fields,
        scoreFormula: scoreFormula,
        scoringRules: scoringRules,
      ),
    );
    notifyListeners();
    return id;
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    notifyListeners();
  }

  Future<void> addRound(String gameId, [Map<String, int?>? newScores]) async {
    final game = get(gameId);
    if (game == null) return;
    game.scores.forEach((playerId, scoreList) {
      scoreList.add(newScores?[playerId]);
    });
    await game.save();
    notifyListeners();
  }

  Future<void> updateScore(
      String gameId, String playerId, int roundIndex, int? newScore) async {
    final game = get(gameId);
    if (game == null) return;
    if (game.scores.containsKey(playerId) &&
        roundIndex < game.scores[playerId]!.length) {
      game.scores[playerId]![roundIndex] = newScore;
      await game.save();
      notifyListeners();
    }
  }

  Future<void> updateRoundData(String gameId, String playerId, int roundIndex,
      Map<String, int> data, int score) async {
    final game = get(gameId);
    if (game == null) return;

    game.roundData ??= {};
    game.roundData!.putIfAbsent(playerId, () => []);
    while (game.roundData![playerId]!.length <= roundIndex) {
      game.roundData![playerId]!.add(null);
    }
    game.roundData![playerId]![roundIndex] = data;

    game.scores.putIfAbsent(playerId, () => []);
    while (game.scores[playerId]!.length <= roundIndex) {
      game.scores[playerId]!.add(null);
    }
    await updateScore(gameId, playerId, roundIndex, score);
  }

  int getTotal(String gameId, String playerId) {
    final game = get(gameId);
    if (game == null) return 0;
    final scores = game.scores[playerId];
    if (scores == null || scores.isEmpty) return 0;
    return scores.fold(0, (sum, s) => sum + (s ?? 0));
  }

  Future<void> finish(String gameId) async {
    final game = get(gameId);
    if (game == null) return;
    game.isFinished = true;
    await game.save();
    notifyListeners();
  }
}
