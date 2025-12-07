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

  group('Math Functions', () {
    test('Should support pow', () {
      expect(gameProvider.calculateDynamicScore('pow(2, 3)', {}), 8);
      expect(gameProvider.calculateDynamicScore('pow(5, 2)', {}), 25);
    });

    test('Should support sqrt', () {
      expect(gameProvider.calculateDynamicScore('sqrt(16)', {}), 4);
      expect(gameProvider.calculateDynamicScore('sqrt(25)', {}), 5);
    });

    test('Should support rounding functions', () {
      expect(gameProvider.calculateDynamicScore('ceil(4.1)', {}), 5);
      expect(gameProvider.calculateDynamicScore('floor(4.9)', {}), 4);
      expect(gameProvider.calculateDynamicScore('rnd(4.5)', {}), 5);
      expect(gameProvider.calculateDynamicScore('rnd(4.4)', {}), 4);
      expect(gameProvider.calculateDynamicScore('truncate(4.9)', {}), 4);
    });

    test('Should support sign', () {
      expect(gameProvider.calculateDynamicScore('sign(-5)', {}), -1);
      expect(gameProvider.calculateDynamicScore('sign(5)', {}), 1);
      expect(gameProvider.calculateDynamicScore('sign(0)', {}), 0);
    });

    test('Should support clamp', () {
      expect(gameProvider.calculateDynamicScore('clamp(10, 0, 5)', {}), 5);
      expect(gameProvider.calculateDynamicScore('clamp(-5, 0, 5)', {}), 0);
      expect(gameProvider.calculateDynamicScore('clamp(3, 0, 5)', {}), 3);
    });

    test('Should support constants', () {
      // pi is approx 3.14159...
      expect(gameProvider.calculateDynamicScore('floor(pi)', {}), 3);
      // e is approx 2.718...
      expect(gameProvider.calculateDynamicScore('floor(e)', {}), 2);
    });
    
    test('Should support abs (existing)', () {
      expect(gameProvider.calculateDynamicScore('abs(-10)', {}), 10);
    });

    test('Should support min/max (existing)', () {
      expect(gameProvider.calculateDynamicScore('min(10, 5)', {}), 5);
      expect(gameProvider.calculateDynamicScore('max(10, 5)', {}), 10);
    });
  });
}
