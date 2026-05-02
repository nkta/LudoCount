import 'package:hive/hive.dart';
import '../../data/models/game_preset.dart';
import '../../data/repositories/preset_repository.dart';

class SeedPresetsUseCase {
  SeedPresetsUseCase({required PresetRepository presetRepository})
      : _repository = presetRepository;

  final PresetRepository _repository;

  Future<void> call() async {
    await _seedAkropolis();
    await _seedLuz();
  }

  Future<void> _seedAkropolis() async {
    final box = Hive.box<GamePreset>('presets');
    for (final p in box.values.where((p) => p.title == 'Akropolis').toList()) {
      await p.delete();
    }
    await _repository.add(
      title: 'Akropolis',
      isInverseScore: false,
      fields: [
        ScoreFieldDefinition(key: 'val', label: 'Valeur / Points'),
        ScoreFieldDefinition(key: 'mult', label: 'Multiplicateur / Étoiles'),
      ],
      scoreFormula: 'val * mult',
      targetRounds: 6,
      roundLabels: ['Bleu', 'Jaune', 'Rouge', 'Violet', 'Vert', 'Pierres'],
      minPlayers: 2,
      maxPlayers: 4,
      isCustom: false,
    );
  }

  Future<void> _seedLuz() async {
    final box = Hive.box<GamePreset>('presets');
    for (final p in box.values.where((p) => p.title == 'Luz').toList()) {
      await p.delete();
    }
    await _repository.add(
      title: 'Luz',
      isInverseScore: false,
      fields: [
        ScoreFieldDefinition(key: 'plis', label: 'Plis'),
        ScoreFieldDefinition(key: 'bj', label: 'Bille jaune'),
        ScoreFieldDefinition(key: 'bb', label: 'Bille bleu'),
      ],
      scoringRules: [
        ScoringRule(
            condition: 'bb == 0 && plis == bj', formula: 'round * 10'),
        ScoringRule(
            condition: 'bb != 0 && (plis == bj + bb || plis == bj)',
            formula: 'round * 10 / 2'),
        ScoringRule(
            condition:
                '(bb == 0 && plis != bj) || (bb != 0 && (plis != bj + bb && plis != bj))',
            formula: 'abs(plis - bj) * (-5)'),
      ],
      targetRounds: 4,
      isCustom: true,
      minPlayers: 3,
      maxPlayers: 5,
    );
  }
}
