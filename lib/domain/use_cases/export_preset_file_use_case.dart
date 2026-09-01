import 'dart:io';

import '../../data/models/game_preset.dart';
import '../../data/services/preset_file_service.dart';
import '../../data/services/preset_share_service.dart';

class ExportPresetFileUseCase {
  ExportPresetFileUseCase({PresetFileService? fileService})
      : _fileService = fileService ?? PresetFileService();

  final PresetFileService _fileService;

  /// Écrit le code de partage de [preset] dans un fichier `.ludopreset` puis
  /// ouvre la feuille de partage du système.
  Future<File> call(GamePreset preset, {String? subject}) async {
    final code = PresetShareService.encodePreset(preset);
    final directory = await _fileService.temporaryDirectory();
    final file = await _fileService.writeCode(
      code: code,
      title: preset.title,
      directory: directory,
    );
    await _fileService.shareFile(file, subject: subject);
    return file;
  }
}
