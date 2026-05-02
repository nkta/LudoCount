import 'package:flutter/foundation.dart';
import 'package:ludocount/data/models/game.dart';
import 'package:ludocount/data/repositories/game_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required GameRepository gameRepository})
      : _repository = gameRepository {
    _repository.addListener(notifyListeners);
  }

  final GameRepository _repository;

  Game? getLastGame() => _repository.getLast();

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}
