import 'package:hive/hive.dart';
import '../models/game.dart';

class GameService {
  Box<Game> get _box => Hive.box<Game>('games');

  List<Game> getAll() => _box.values.toList();
  Game? get(String id) => _box.get(id);
  Future<void> put(String id, Game game) => _box.put(id, game);
  Future<void> delete(String id) => _box.delete(id);
  bool get isEmpty => _box.isEmpty;
}
