import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/player.dart';

class GameProvider extends ChangeNotifier {
  final Box<Player> _playerBox = Hive.box<Player>('players');
  final Box<Game> _gameBox = Hive.box<Game>('games');
  final Uuid _uuid = const Uuid();

  List<Player> get players => _playerBox.values.toList();
  List<Game> get games => _gameBox.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // Du plus récent au plus ancien

  // --- Players Logic ---

  Future<void> addPlayer(String name) async {
    final id = _uuid.v4();
    final newPlayer = Player(id: id, name: name);
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

  // --- Game Logic ---

  Future<String> createGame(String title, List<String> playerIds, bool isInverse, {int? targetScore, int? targetRounds}) async {
    final id = _uuid.v4();
    // Initialiser les scores vides pour chaque joueur
    final Map<String, List<int?>> initialScores = {};
    for (var pId in playerIds) {
      initialScores[pId] = [];
    }

    final newGame = Game(
      id: id,
      title: title.isEmpty ? 'Partie du ${DateTime.now().toString().split(' ')[0]}' : title,
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
  Future<void> updateScore(String gameId, String playerId, int roundIndex, int? newScore) async {
    final game = getGame(gameId);
    if (game == null) return;

    if (game.scores.containsKey(playerId) && roundIndex < game.scores[playerId]!.length) {
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
