import 'package:flutter/foundation.dart';
import 'package:ludocount/data/models/game.dart';
import 'package:ludocount/data/repositories/game_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({required GameRepository gameRepository})
      : _repository = gameRepository {
    _repository.addListener(notifyListeners);
  }

  final GameRepository _repository;

  List<Game> get games => _repository.games;

  Future<void> deleteGame(String id) => _repository.delete(id);

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}
