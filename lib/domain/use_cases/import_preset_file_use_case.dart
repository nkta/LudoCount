import '../../data/models/game_preset.dart';
import '../../data/services/preset_file_service.dart';
import '../../data/services/preset_share_service.dart';

/// Raisons pour lesquelles un import par fichier peut échouer.
enum PresetFileImportError {
  /// Le fichier n'a pas pu être ouvert, ou n'est pas du texte.
  unreadableFile,

  /// Le fichier a été lu, mais ne contient pas un code de preset valide.
  invalidCode,
}

class PresetFileImportException implements Exception {
  const PresetFileImportException(this.error);

  final PresetFileImportError error;

  @override
  String toString() => 'PresetFileImportException: $error';
}

class ImportPresetFileUseCase {
  ImportPresetFileUseCase({PresetFileService? fileService})
      : _fileService = fileService ?? PresetFileService();

  final PresetFileService _fileService;

  /// Demande un fichier `.ludopreset` à l'utilisateur et décode le preset
  /// qu'il contient. Retourne null si la sélection est annulée.
  Future<GamePreset?> call({String? dialogTitle}) async {
    final String? code;
    try {
      code = await _fileService.pickCode(dialogTitle: dialogTitle);
    } on PresetFileException {
      // Fichier illisible, sélecteur indisponible ou permission refusée : le
      // service ramène tout cela à une seule exception. Le reste est un bug,
      // qui doit remonter tel quel.
      throw const PresetFileImportException(
          PresetFileImportError.unreadableFile);
    }
    if (code == null) return null;

    try {
      return PresetShareService.decodePreset(code);
    } on FormatException {
      throw const PresetFileImportException(PresetFileImportError.invalidCode);
    }
  }
}
