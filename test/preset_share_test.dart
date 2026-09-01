import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/services/preset_file_service.dart';
import 'package:ludocount/data/services/preset_share_service.dart';
import 'package:ludocount/domain/use_cases/export_preset_file_use_case.dart';
import 'package:ludocount/domain/use_cases/import_preset_file_use_case.dart';

/// Remplace les accès plateforme (sélecteur de fichiers, feuille de partage)
/// par le répertoire temporaire du test.
class _FakePresetFileService extends PresetFileService {
  _FakePresetFileService(this._directory);

  final Directory _directory;

  /// Fichier passé au partage système.
  File? sharedFile;

  /// Code renvoyé par le sélecteur, null pour simuler une annulation.
  String? pickedCode;

  /// Erreur levée par le sélecteur, si le fichier ne peut pas être lu.
  Object? pickError;

  @override
  Future<Directory> temporaryDirectory() async => _directory;

  @override
  Future<void> shareFile(File file, {String? subject}) async {
    sharedFile = file;
  }

  @override
  Future<String?> pickCode({String? dialogTitle}) async {
    if (pickError != null) throw pickError!;
    return pickedCode;
  }
}

GamePreset _samplePreset() => GamePreset(
      id: 'file_id',
      title: 'Skull King',
      isInverseScore: false,
      targetRounds: 10,
      isCustom: true,
      fields: [ScoreFieldDefinition(key: 'bid', label: 'Pari')],
      scoringRules: [ScoringRule(condition: 'bid == 0', formula: '10')],
      minPlayers: 2,
      maxPlayers: 6,
    );

void main() {
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
    expect(RegExp(r'^[a-zA-Z0-9+/]+={0,2}$').hasMatch(code), isTrue);

    final decoded = PresetShareService.decodePreset(code);
    expect(decoded.title, 'Shared Preset');
    expect(decoded.scoreFormula, 'bid * 10');
  });

  group('Partage par fichier', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ludocount_preset_file');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('le nom de fichier dérive du titre du preset', () {
      final service = PresetFileService();
      expect(service.fileNameFor('Skull King'), 'skull_king.ludopreset');
      expect(service.fileNameFor('Élan Noir !'), 'elan_noir.ludopreset');
      expect(service.fileNameFor('***'), 'preset.ludopreset');
    });

    test('un preset écrit dans un fichier est relu à l’identique', () async {
      final service = PresetFileService();
      final preset = _samplePreset();

      final file = await service.writeCode(
        code: PresetShareService.encodePreset(preset),
        title: preset.title,
        directory: tempDir,
      );
      expect(file.path, endsWith('.ludopreset'));

      final restored = PresetShareService.decodePreset(
        await service.readCode(file),
      );
      expect(restored.title, preset.title);
      expect(restored.targetRounds, 10);
      expect(restored.fields!.first.key, 'bid');
      expect(restored.scoringRules!.first.condition, 'bid == 0');
      expect(restored.maxPlayers, 6);
    });

    test('export puis import restituent le preset', () async {
      final service = _FakePresetFileService(tempDir);
      final preset = _samplePreset();

      final file = await ExportPresetFileUseCase(fileService: service)(
        preset,
        subject: 'Preset LudoCount : Skull King',
      );
      expect(service.sharedFile?.path, file.path);

      service.pickedCode = await service.readCode(file);
      final imported = await ImportPresetFileUseCase(fileService: service)();

      expect(imported, isNotNull);
      expect(imported!.title, preset.title);
      expect(imported.scoringRules!.first.formula, '10');
      expect(imported.fields!.first.label, 'Pari');
    });

    test('les espaces autour du code sont tolérés', () async {
      final service = PresetFileService();
      final preset = _samplePreset();
      final file = File('${tempDir.path}/spaced.ludopreset');
      await file.writeAsString(
          '\n  ${PresetShareService.encodePreset(preset)}  \n');

      final restored = PresetShareService.decodePreset(
        await service.readCode(file),
      );
      expect(restored.title, preset.title);
    });

    test('un fichier binaire est refusé', () async {
      final service = PresetFileService();
      final file = File('${tempDir.path}/broken.ludopreset');
      await file.writeAsBytes([0xFF, 0xFE, 0x00, 0x80]);

      expect(service.readCode(file), throwsA(isA<PresetFileException>()));
    });

    test('un fichier absent est refusé', () async {
      final service = PresetFileService();
      final file = File('${tempDir.path}/absent.ludopreset');

      expect(service.readCode(file), throwsA(isA<PresetFileException>()));
    });

    test('un fichier illisible remonte une erreur typée', () async {
      final service = _FakePresetFileService(tempDir)
        ..pickError = const PresetFileException('Fichier binaire');

      expect(
        ImportPresetFileUseCase(fileService: service)(),
        throwsA(isA<PresetFileImportException>().having(
            (e) => e.error, 'error', PresetFileImportError.unreadableFile)),
      );
    });

    test('un contenu qui n’est pas un code de preset remonte une erreur typée',
        () async {
      final service = _FakePresetFileService(tempDir)
        ..pickedCode = 'ceci n’est pas un preset';

      expect(
        ImportPresetFileUseCase(fileService: service)(),
        throwsA(isA<PresetFileImportException>().having(
            (e) => e.error, 'error', PresetFileImportError.invalidCode)),
      );
    });

    test('annuler la sélection ne renvoie aucun preset', () async {
      final service = _FakePresetFileService(tempDir);

      expect(await ImportPresetFileUseCase(fileService: service)(), isNull);
    });
  });
}
