import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/game_preset.dart';

class GameProvider extends ChangeNotifier {
  Box<Player> get _playerBox => Hive.box<Player>('players');
  Box<Game> get _gameBox => Hive.box<Game>('games');
  Box<GamePreset> get _presetBox => Hive.box<GamePreset>('presets');
  final Uuid _uuid = const Uuid();

  List<Player> get players => _playerBox.values.toList();
  List<Game> get games => _gameBox.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // Du plus récent au plus ancien

  // --- Presets ---
  List<GamePreset> get presets => _presetBox.values.toList();

  // --- Dice State ---
  int _diceCount = 1;
  int get diceCount => _diceCount;
  void setDiceCount(int count) {
    _diceCount = count;
    notifyListeners();
  }

  Future<void> addPreset({
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
    await _presetBox.put(preset.id, preset);
    await _presetBox.put(preset.id, preset);
    notifyListeners();
  }

  Future<void> savePreset(GamePreset preset) async {
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

  int calculateDynamicScore(String formula, Map<String, int> inputs, {int roundIndex = 0, List<ScoringRule>? rules}) {
    try {
      // Crée le contexte avec les inputs et les fonctions mathématiques de base
      final context = <String, dynamic>{
        ...inputs,
        'round': roundIndex + 1,
        'index': roundIndex,
        'abs': (num x) => x.abs(),
      'min': (num a, num b) => math.min(a, b),
      'max': (num a, num b) => math.max(a, b),
      'pow': (num x, num y) => math.pow(x, y),
      'sqrt': (num x) => math.sqrt(x),
      'ceil': (num x) => x.ceil(),
      'floor': (num x) => x.floor(),
      'rnd': (num x) => x.round(),
      'sign': (num x) => x.sign,
      'truncate': (num x) => x.truncate(),
      'clamp': (num x, num min, num max) => x.clamp(min, max),
      'pi': math.pi,
      'e': math.e,
    };

      final evaluator = const ExpressionEvaluator();

      // Si des règles sont définies, on les utilise en priorité
      if (rules != null && rules.isNotEmpty) {
        for (final rule in rules) {
          try {
            // Évalue la condition
            final conditionExpr = Expression.parse(rule.condition);
            final conditionResult = evaluator.eval(conditionExpr, context);

            if (conditionResult == true) {
              // Si la condition est vraie, on évalue la formule associée
              final formulaExpr = Expression.parse(rule.formula);
              final result = evaluator.eval(formulaExpr, context);
              if (result is num) {
                return result.round();
              }
              return 0;
            }
          } catch (e) {
            print('Erreur dans la règle "${rule.condition}": $e');
            continue; // Passe à la règle suivante en cas d'erreur
          }
        }
        // Si aucune règle ne correspond (et pas de "else" explicite capturé par une condition true), retourne 0
        return 0;
      }

      // Sinon, utilise la formule unique classique
      if (formula.isEmpty) return 0;
      
      final expression = Expression.parse(formula);
      final result = evaluator.eval(expression, context);

      if (result is num) {
        return result.round();
      }
      return 0;
    } catch (e) {
      print('Erreur de calcul de formule: $e');
      return 0;
    }
  }

  Future<void> updateRoundData(String gameId, String playerId, int roundIndex,
      Map<String, int> data, int score) async {
    final game = getGame(gameId);
    if (game == null) return;

    // Initialiser roundData si null
    if (game.roundData == null) {
      game.roundData = {};
    }
    
    if (!game.roundData!.containsKey(playerId)) {
      game.roundData![playerId] = [];
    }

    // S'assurer que la liste roundData est assez grande
    while (game.roundData![playerId]!.length <= roundIndex) {
      game.roundData![playerId]!.add(null);
    }

    game.roundData![playerId]![roundIndex] = data;
    
    // S'assurer que la liste scores est assez grande
    if (!game.scores.containsKey(playerId)) {
      game.scores[playerId] = [];
    }
    while (game.scores[playerId]!.length <= roundIndex) {
      game.scores[playerId]!.add(null);
    }
    
    // Mettre à jour le score principal aussi
    await updateScore(gameId, playerId, roundIndex, score);
    // updateScore appelle déjà save() et notifyListeners()
  }

  Future<String> createGame(
      String title, List<String> playerIds, bool isInverse,
      {int? targetScore,
      int? targetRounds,
      GameType type = GameType.standard,
      List<String>? roundLabels,
      List<ScoreFieldDefinition>? fields,
      String? scoreFormula,
      List<ScoringRule>? scoringRules}) async {
    final id = _uuid.v4();
    // Initialiser les scores vides pour chaque joueur
    final Map<String, List<int?>> initialScores = {};
    for (var pId in playerIds) {
      initialScores[pId] = [];
      if (roundLabels != null) {
        for (var i = 0; i < roundLabels.length; i++) {
          initialScores[pId]!.add(null);
        }
      }
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
      type: type,
      roundLabels: roundLabels,
      fields: fields,
      scoreFormula: scoreFormula,
      scoringRules: scoringRules,
    );

    await _gameBox.put(id, newGame);
    notifyListeners();
    return id;
  }

  Future<void> deleteGame(String id) async {
    if (_gameBox.containsKey(id)) {
      await _gameBox.delete(id);
      notifyListeners();
    }
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

  int calculateSkullKingScore(int bid, int tricks, int roundIndex) {
    if (bid == tricks) {
      if (bid == 0) {
        return (roundIndex + 1) * 10;
      } else {
        return bid * 20;
      }
    } else {
      if (bid == 0) {
        return (roundIndex + 1) * -10;
      } else {
        return (tricks - bid).abs() * -10;
      }
    }
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
