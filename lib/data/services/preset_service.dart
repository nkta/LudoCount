import 'package:hive/hive.dart';
import '../models/game_preset.dart';

class PresetService {
  Box<GamePreset> get _box => Hive.box<GamePreset>('presets');

  List<GamePreset> getAll() => _box.values.toList();
  GamePreset? get(String id) => _box.get(id);
  Future<void> put(String id, GamePreset preset) => _box.put(id, preset);
  Future<void> delete(String id) => _box.delete(id);
  bool containsKey(String id) => _box.containsKey(id);
}
