import 'package:flutter/foundation.dart';
import 'package:ludocount/data/models/player.dart';
import 'package:ludocount/data/repositories/player_repository.dart';

class PlayersViewModel extends ChangeNotifier {
  PlayersViewModel({required PlayerRepository playerRepository})
      : _repository = playerRepository {
    _repository.addListener(notifyListeners);
  }

  final PlayerRepository _repository;

  List<Player> get players => _repository.players;
  bool get hasDefaults => players.any((p) => p.isDefault);

  Future<void> addPlayer(String name, {bool isDefault = false}) =>
      _repository.add(name, isDefault: isDefault);

  Future<void> deletePlayer(String id) => _repository.delete(id);

  Future<void> setDefault(String id, bool isDefault) =>
      _repository.setDefault(id, isDefault);

  Future<void> clearDefaults() => _repository.clearDefaults();

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}
