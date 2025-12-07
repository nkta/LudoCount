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

  group('Conditional Scoring Rules', () {
    test('Should evaluate first matching rule', () {
      final rules = [
        ScoringRule(condition: 'bid == 0', formula: '10'),
        ScoringRule(condition: 'bid == tricks', formula: '20'),
        ScoringRule(condition: 'true', formula: '-10'),
      ];

      // Case 1: bid == 0 -> Rule 1
      expect(gameProvider.calculateDynamicScore('', {'bid': 0, 'tricks': 0}, rules: rules), 10);

      // Case 2: bid == tricks (but not 0) -> Rule 2
      expect(gameProvider.calculateDynamicScore('', {'bid': 2, 'tricks': 2}, rules: rules), 20);

      // Case 3: No match (bid != tricks and bid != 0) -> Rule 3 (default)
      expect(gameProvider.calculateDynamicScore('', {'bid': 2, 'tricks': 1}, rules: rules), -10);
    });

    test('Should return 0 if no rule matches', () {
      final rules = [
        ScoringRule(condition: 'bid == 100', formula: '1000'),
      ];

      expect(gameProvider.calculateDynamicScore('', {'bid': 1, 'tricks': 1}, rules: rules), 0);
    });

    test('Should handle complex expressions in conditions and formulas', () {
      final rules = [
        ScoringRule(condition: 'bid == 0 && tricks > 0', formula: 'tricks * -10'),
        ScoringRule(condition: 'bid == 0', formula: '50'),
      ];

      // bid 0, tricks 2 -> Rule 1 (-20)
      expect(gameProvider.calculateDynamicScore('', {'bid': 0, 'tricks': 2}, rules: rules), -20);

      // bid 0, tricks 0 -> Rule 2 (50)
      expect(gameProvider.calculateDynamicScore('', {'bid': 0, 'tricks': 0}, rules: rules), 50);
    });

    test('Should fallback to formula if rules are null or empty', () {
      // Formula: bid * 10
      expect(gameProvider.calculateDynamicScore('bid * 10', {'bid': 5}, rules: null), 50);
      expect(gameProvider.calculateDynamicScore('bid * 10', {'bid': 5}, rules: []), 50);
    });
  });
}
