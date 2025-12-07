import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/providers/game_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ludocount/models/player.dart';
import 'package:ludocount/models/game.dart';
import 'package:ludocount/models/game_preset.dart';

import 'dart:io';

void main() {
  group('Skull King Scoring Tests', () {
    late GameProvider provider;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GameAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GamePresetAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(GameTypeAdapter());
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PlayerAdapter());
      
      await Hive.openBox<Player>('players');
      await Hive.openBox<Game>('games');
      await Hive.openBox<GamePreset>('presets');

      provider = GameProvider();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Bid correct (non-zero)', () {
      // Bid 1, Tricks 1 -> 20 points
      expect(provider.calculateSkullKingScore(1, 1, 0), 20);
      // Bid 3, Tricks 3 -> 60 points
      expect(provider.calculateSkullKingScore(3, 3, 4), 60);
    });

    test('Bid correct (zero) - Round 1', () {
      // Bid 0, Tricks 0, Round 1 (index 0) -> 10 points
      expect(provider.calculateSkullKingScore(0, 0, 0), 10);
    });

    test('Bid correct (zero) - Round 5', () {
      // Bid 0, Tricks 0, Round 5 (index 4) -> 50 points
      expect(provider.calculateSkullKingScore(0, 0, 4), 50);
    });

    test('Bid incorrect (non-zero bid)', () {
      // Bid 1, Tricks 0 -> -10 points (diff 1)
      expect(provider.calculateSkullKingScore(1, 0, 0), -10);
      // Bid 1, Tricks 2 -> -10 points (diff 1)
      expect(provider.calculateSkullKingScore(1, 2, 0), -10);
      // Bid 2, Tricks 0 -> -20 points (diff 2)
      expect(provider.calculateSkullKingScore(2, 0, 0), -20);
      // Bid 2, Tricks 5 -> -30 points (diff 3)
      expect(provider.calculateSkullKingScore(2, 5, 0), -30);
    });

    test('Bid incorrect (zero bid) - Round 1', () {
      // Bid 0, Tricks 1, Round 1 (index 0) -> -10 points
      expect(provider.calculateSkullKingScore(0, 1, 0), -10);
    });

    test('Bid incorrect (zero bid) - Round 5', () {
      // Bid 0, Tricks 1, Round 5 (index 4) -> -50 points
      expect(provider.calculateSkullKingScore(0, 1, 4), -50);
    });
  });
}
