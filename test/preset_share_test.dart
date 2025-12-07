import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/models/game_preset.dart';
import 'package:ludocount/services/preset_share_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GamePresetAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ScoringRuleAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(GameTypeAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ScoreFieldDefinitionAdapter());
  });

  tearDownAll(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('GamePreset JSON serialization', () {
    final preset = GamePreset(
      id: 'test_id',
      title: 'Test Preset',
      isInverseScore: true,
      targetScore: 100,
      targetRounds: 5,
      isCustom: true,
      fields: [ScoreFieldDefinition(key: 'bid', label: 'Pari')],
      scoringRules: [ScoringRule(condition: 'true', formula: '10')],
      minPlayers: 2,
      maxPlayers: 4,
    );

    final json = preset.toJson();
    expect(json['title'], 'Test Preset');
    expect(json['fields'].length, 1);
    expect(json['scoringRules'].length, 1);
    expect(json['minPlayers'], 2);

    final restored = GamePreset.fromJson(json);
    expect(restored.title, preset.title);
    expect(restored.fields!.first.key, 'bid');
    expect(restored.scoringRules!.first.formula, '10');
    expect(restored.minPlayers, 2);
  });

  test('PresetShareService encode/decode', () {
    final preset = GamePreset(
      id: 'share_id',
      title: 'Shared Preset',
      isInverseScore: false,
      scoreFormula: 'bid * 10',
    );

    final code = PresetShareService.encodePreset(preset);
    expect(code, isNotEmpty);
    
    // Should be base64
    expect(RegExp(r'^[a-zA-Z0-9+/]+={0,2}$').hasMatch(code), isTrue);

    final decoded = PresetShareService.decodePreset(code);
    expect(decoded.title, 'Shared Preset');
    expect(decoded.scoreFormula, 'bid * 10');
  });
}
