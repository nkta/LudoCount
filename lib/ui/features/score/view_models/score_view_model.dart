import 'package:flutter/foundation.dart';
import 'package:ludocount/data/models/game.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/models/player.dart';
import 'package:ludocount/data/repositories/game_repository.dart';
import 'package:ludocount/data/repositories/player_repository.dart';
import 'package:ludocount/domain/use_cases/calculate_score_use_case.dart';

class ScoreViewModel extends ChangeNotifier {
  ScoreViewModel({
    required String gameId,
    required GameRepository gameRepository,
    required PlayerRepository playerRepository,
    required CalculateScoreUseCase calculateScoreUseCase,
  })  : _gameId = gameId,
        _gameRepo = gameRepository,
        _playerRepo = playerRepository,
        _calculator = calculateScoreUseCase {
    _gameRepo.addListener(notifyListeners);
  }

  final String _gameId;
  final GameRepository _gameRepo;
  final PlayerRepository _playerRepo;
  final CalculateScoreUseCase _calculator;

  Game? get game => _gameRepo.get(_gameId);

  List<Player> get players => game?.playersIds
          .map((id) => _playerRepo.get(id))
          .whereType<Player>()
          .toList() ??
      [];

  int getTotal(String playerId) => _gameRepo.getTotal(_gameId, playerId);

  int calculateScore(
    String formula,
    Map<String, int> inputs, {
    int roundIndex = 0,
    List<ScoringRule>? rules,
  }) =>
      _calculator.calculateDynamic(formula, inputs,
          roundIndex: roundIndex, rules: rules);

  int calculateSkullKing(int bid, int tricks, int roundIndex) =>
      _calculator.calculateSkullKing(bid, tricks, roundIndex);

  Future<void> addRound([Map<String, int?>? scores]) =>
      _gameRepo.addRound(_gameId, scores);

  Future<void> updateScore(String playerId, int roundIndex, int? score) =>
      _gameRepo.updateScore(_gameId, playerId, roundIndex, score);

  Future<void> updateRoundData(
    String playerId,
    int roundIndex,
    Map<String, int> data,
    int score,
  ) =>
      _gameRepo.updateRoundData(_gameId, playerId, roundIndex, data, score);

  Future<void> finishGame() => _gameRepo.finish(_gameId);

  @override
  void dispose() {
    _gameRepo.removeListener(notifyListeners);
    super.dispose();
  }
}
