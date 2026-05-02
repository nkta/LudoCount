import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/domain/use_cases/calculate_score_use_case.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/models/game.dart';
import 'package:ludocount/data/models/player.dart';
import 'package:ludocount/data/repositories/game_repository.dart';
import 'package:ludocount/data/repositories/preset_repository.dart';
import 'package:ludocount/data/services/game_service.dart';
import 'package:ludocount/data/services/preset_service.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  group('Expert Mode Integration Tests', () {
    late CalculateScoreUseCase calculator;
    late GameRepository gameRepository;
    late PresetRepository presetRepository;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GameAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GamePresetAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(GameTypeAdapter());
      if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ScoreFieldDefinitionAdapter());
      if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ScoringRuleAdapter());
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PlayerAdapter());

      await Hive.openBox<Player>('players');
      await Hive.openBox<Game>('games');
      await Hive.openBox<GamePreset>('presets');

      calculator = CalculateScoreUseCase();
      gameRepository = GameRepository(gameService: GameService());
      presetRepository = PresetRepository(presetService: PresetService());
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Create Expert Preset and Calculate Score', () async {
      final fields = [
        ScoreFieldDefinition(key: 'bid', label: 'Pari'),
        ScoreFieldDefinition(key: 'tricks', label: 'Plis'),
      ];
      final formula = 'bid == tricks ? (bid == 0 ? 10 : bid * 20) : (bid == 0 ? -10 : abs(tricks - bid) * -10)';

      await presetRepository.add(
        title: 'Skull King Expert',
        isInverseScore: false,
        fields: fields,
        scoreFormula: formula,
      );

      expect(presetRepository.presets.length, 1);
      final preset = presetRepository.presets.first;
      expect(preset.fields!.length, 2);
      expect(preset.scoreFormula, formula);

      final gameId = await gameRepository.create('Test Game', ['p1'], false);

      final inputs = {'bid': 1, 'tricks': 1};
      final score = calculator.calculateDynamic(formula, inputs);
      expect(score, 20);

      await gameRepository.updateRoundData(gameId, 'p1', 0, inputs, score);

      final game = gameRepository.get(gameId)!;
      expect(game.scores['p1']![0], 20);
      expect(game.roundData!['p1']![0]!['bid'], 1);
      expect(game.roundData!['p1']![0]!['tricks'], 1);
    });

    test('Dynamic Score Calculation - Complex Formula', () {
      final formula = 'a * 2 + b';
      final inputs = {'a': 5, 'b': 3};
      final score = calculator.calculateDynamic(formula, inputs);
      expect(score, 13);
    });
  });
}
