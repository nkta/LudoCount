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

  group('Math Expressions Extended', () {
    test('Should support abs function', () {
      expect(gameProvider.calculateDynamicScore('abs(-10)', {}), 10);
      expect(gameProvider.calculateDynamicScore('abs(10)', {}), 10);
      expect(gameProvider.calculateDynamicScore('abs(0)', {}), 0);
      expect(gameProvider.calculateDynamicScore('abs(-5.5)', {}), 6); // rounded
    });

    test('Should support parentheses', () {
      expect(gameProvider.calculateDynamicScore('(2 + 3) * 4', {}), 20);
      expect(gameProvider.calculateDynamicScore('2 + (3 * 4)', {}), 14);
      expect(gameProvider.calculateDynamicScore('((2 + 3) * 2) / 2', {}), 5);
    });

    test('Should support complex expressions with abs and parentheses', () {
      expect(gameProvider.calculateDynamicScore('abs((5 - 10) * 2)', {}), 10);
      expect(gameProvider.calculateDynamicScore('(abs(-5) + 5) * 2', {}), 20);
    });
  });
}
