import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/domain/use_cases/calculate_score_use_case.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/models/game.dart';
import 'package:ludocount/data/models/player.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  late CalculateScoreUseCase calculator;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GamePresetAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ScoringRuleAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(GameTypeAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ScoreFieldDefinitionAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PlayerAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GameAdapter());

    await Hive.openBox<GamePreset>('presets');
    await Hive.openBox<Player>('players');
    await Hive.openBox<Game>('games');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() {
    calculator = CalculateScoreUseCase();
  });

  test('GamePreset should store minPlayers and maxPlayers', () async {
    final preset = GamePreset(
      id: 'test_id',
      title: 'Test Preset',
      isInverseScore: false,
      minPlayers: 3,
      maxPlayers: 5,
    );

    final box = Hive.box<GamePreset>('presets');
    await box.put(preset.id, preset);

    final retrieved = box.get(preset.id);
    expect(retrieved, isNotNull);
    expect(retrieved!.minPlayers, 3);
    expect(retrieved.maxPlayers, 5);
  });

  test('calculateDynamic should use playerCount variable', () {
    final score = calculator.calculateDynamic('playerCount * 10', {'playerCount': 4});
    expect(score, 40);
  });

  test('calculateDynamic should work with other variables and playerCount', () {
    final score = calculator.calculateDynamic('bid * playerCount', {'bid': 5, 'playerCount': 3});
    expect(score, 15);
  });
}
