import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/providers/game_provider.dart';
import 'package:ludocount/models/game_preset.dart';
import 'package:ludocount/models/game.dart';
import 'package:ludocount/models/player.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  group('Expert Mode Integration Tests', () {
    late GameProvider provider;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GameAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GamePresetAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(GameTypeAdapter());
      if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ScoreFieldDefinitionAdapter());
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

    test('Create Expert Preset and Calculate Score', () async {
      // 1. Create Expert Preset
      final fields = [
        ScoreFieldDefinition(key: 'bid', label: 'Pari'),
        ScoreFieldDefinition(key: 'tricks', label: 'Plis'),
      ];
      final formula = 'bid == tricks ? (bid == 0 ? 10 : bid * 20) : (bid == 0 ? -10 : abs(tricks - bid) * -10)';
      
      await provider.addPreset(
        title: 'Skull King Expert',
        isInverseScore: false,
        fields: fields,
        scoreFormula: formula,
      );

      expect(provider.presets.length, 1);
      final preset = provider.presets.first;
      expect(preset.fields!.length, 2);
      expect(preset.scoreFormula, formula);

      // 2. Create Game with this preset
      // Note: createGame doesn't take preset ID directly, but we can simulate the flow
      // In the app, we use the preset to pre-fill config.
      // Here we just need to test the dynamic scoring logic which is independent of the game creation itself,
      // but let's create a game to test updateRoundData.
      
      final gameId = await provider.createGame('Test Game', ['p1'], false);
      
      // 3. Calculate and Update Score
      final inputs = {'bid': 1, 'tricks': 1};
      final score = provider.calculateDynamicScore(formula, inputs);
      expect(score, 20); // 1 * 20

      await provider.updateRoundData(gameId, 'p1', 0, inputs, score);
      
      final game = provider.getGame(gameId)!;
      expect(game.scores['p1']![0], 20);
      expect(game.roundData!['p1']![0]!['bid'], 1);
      expect(game.roundData!['p1']![0]!['tricks'], 1);
    });

    test('Dynamic Score Calculation - Complex Formula', () {
      final formula = 'a * 2 + b';
      final inputs = {'a': 5, 'b': 3};
      final score = provider.calculateDynamicScore(formula, inputs);
      expect(score, 13);
    });
  });
}
