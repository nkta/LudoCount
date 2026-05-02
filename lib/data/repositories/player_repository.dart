import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../services/player_service.dart';

class PlayerRepository extends ChangeNotifier {
  PlayerRepository({required PlayerService playerService})
      : _service = playerService;

  final PlayerService _service;
  final _uuid = const Uuid();

  List<Player> get players => _service.getAll();

  Player? get(String id) => _service.get(id);

  bool containsKey(String id) => _service.containsKey(id);

  List<String> get defaultPlayerIds =>
      _service.getAll().where((p) => p.isDefault).map((p) => p.id).toList();

  Future<void> add(String name, {bool isDefault = false}) async {
    final id = _uuid.v4();
    await _service.put(id, Player(id: id, name: name, isDefault: isDefault));
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    notifyListeners();
  }

  Future<void> setDefault(String id, bool isDefault) async {
    final player = _service.get(id);
    if (player == null) return;
    player.isDefault = isDefault;
    await player.save();
    notifyListeners();
  }

  Future<void> clearDefaults() async {
    final defaults = players.where((p) => p.isDefault).toList();
    for (final p in defaults) {
      p.isDefault = false;
      await p.save();
    }
    if (defaults.isNotEmpty) notifyListeners();
  }
}
