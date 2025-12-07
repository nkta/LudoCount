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

  test('createGame should populate fields and formula', () async {
    final fields = [ScoreFieldDefinition(key: 'bid', label: 'Pari')];
    final formula = 'bid * 10';
    final rules = [ScoringRule(condition: 'bid == 0', formula: '10')];

    final gameId = await gameProvider.createGame(
      'Test Game',
      ['p1'],
      false,
      fields: fields,
      scoreFormula: formula,
      scoringRules: rules,
    );

    final game = gameProvider.getGame(gameId);
    expect(game, isNotNull);
    expect(game!.fields, isNotNull);
    expect(game.fields!.length, 1);
    expect(game.fields!.first.key, 'bid');
    expect(game.scoreFormula, formula);
    expect(game.scoringRules, isNotNull);
    expect(game.scoringRules!.length, 1);
    expect(game.scoringRules!.first.condition, 'bid == 0');
  });
}
