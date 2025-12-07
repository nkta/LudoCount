import 'package:hive/hive.dart';
import '../models/game_preset.dart';
import '../providers/game_provider.dart';

class PresetSeeder {
  static Future<void> seedAkropolis(GameProvider provider) async {
    final box = Hive.box<GamePreset>('presets');
    // Force update for development/fix
    // if (box.values.any((p) => p.title == 'Akropolis')) {
    //   return; 
    // }
    
    // Delete existing if any to be sure
    final existing = box.values.where((p) => p.title == 'Akropolis').toList();
    for (var p in existing) {
      await p.delete();
    }

    final fields = [
      ScoreFieldDefinition(key: 'val', label: 'Valeur / Points'),
      ScoreFieldDefinition(key: 'mult', label: 'Multiplicateur / Étoiles'),
    ];

    final formula = 'val * mult';
    
    final roundLabels = ['Bleu', 'Jaune', 'Rouge', 'Violet', 'Vert', 'Pierres'];

    await provider.addPreset(
      title: 'Akropolis',
      isInverseScore: false,
      fields: fields,
      scoreFormula: formula,
      targetRounds: 6,
      roundLabels: roundLabels,
      minPlayers: 2,
      maxPlayers: 4,
    );
  }

  static Future<void> seedLuz(GameProvider provider) async {
    final box = Hive.box<GamePreset>('presets');
    
    // Delete existing if any to be sure
    final existing = box.values.where((p) => p.title == 'Luz').toList();
    for (var p in existing) {
      await p.delete();
    }

    final fields = [
      ScoreFieldDefinition(key: 'plis', label: 'Plis'),
      ScoreFieldDefinition(key: 'bj', label: 'Bille jaune'),
      ScoreFieldDefinition(key: 'bb', label: 'Bille bleu'),
    ];

    final rules = [
      ScoringRule(
        condition: 'bb == 0 && plis == bj',
        formula: 'round * 10',
      ),
      ScoringRule(
        condition: 'bb != 0 && (plis == bj + bb || plis == bj)',
        formula: 'round * 10 / 2',
      ),
      ScoringRule(
        condition: '(bb == 0 && plis != bj) || (bb != 0 && (plis != bj + bb && plis != bj))',
        formula: 'abs(plis - bj) * (-5)',
      ),
    ];

    await provider.addPreset(
      title: 'Luz',
      isInverseScore: false,
      fields: fields,
      scoringRules: rules,
      targetRounds: 4,
      isCustom: true,
      minPlayers: 3,
      maxPlayers: 5,
    );
  }




}
