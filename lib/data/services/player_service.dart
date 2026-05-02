import 'package:hive/hive.dart';
import '../models/player.dart';

class PlayerService {
  Box<Player> get _box => Hive.box<Player>('players');

  List<Player> getAll() => _box.values.toList();
  Player? get(String id) => _box.get(id);
  Future<void> put(String id, Player player) => _box.put(id, player);
  Future<void> delete(String id) => _box.delete(id);
  bool containsKey(String id) => _box.containsKey(id);
}
