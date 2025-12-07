import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/providers/game_provider.dart';
import 'package:ludocount/models/game_preset.dart';
import 'package:ludocount/models/game.dart';
import 'package:ludocount/models/player.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  late GameProvider gameProvider;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GamePresetAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ScoringRuleAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(GameTypeAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ScoreFieldDefinitionAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(GameAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PlayerAdapter());

    // Open boxes needed by GameProvider
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
    gameProvider = GameProvider();
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

  test('calculateDynamicScore should use playerCount variable', () {
    final formula = 'playerCount * 10';
    final inputs = {'playerCount': 4};
    
    final score = gameProvider.calculateDynamicScore(formula, inputs);
    expect(score, 40);
  });

  test('calculateDynamicScore should work with other variables and playerCount', () {
    final formula = 'bid * playerCount';
    final inputs = {'bid': 5, 'playerCount': 3};
    
    final score = gameProvider.calculateDynamicScore(formula, inputs);
    expect(score, 15);
  });
}
