import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Levée quand un fichier ne peut pas être lu comme code de preset.
class PresetFileException implements Exception {
  const PresetFileException(this.message);

  final String message;

  @override
  String toString() => 'PresetFileException: $message';
}

/// Échange d'un preset par fichier.
///
/// Le fichier porte l'extension `.ludopreset` et contient, en texte UTF-8,
/// exactement le code produit par `PresetShareService.encodePreset`
/// (base64 du JSON compressé en gzip). Le format est donc le même que celui
/// du QR code : seul le transport change.
class PresetFileService {
  /// Extension dédiée aux presets exportés, sans le point.
  static const String fileExtension = 'ludopreset';

  /// Le contenu est du texte base64, annoncé comme tel au partage système.
  static const String mimeType = 'text/plain';

  /// Un preset encodé pèse quelques kilo-octets : au-delà, le fichier choisi
  /// n'en est pas un et il est inutile de le charger en mémoire.
  static const int maxFileSize = 512 * 1024;

  /// Nom de fichier proposé pour un preset intitulé [title].
  ///
  /// Les accents sont repliés et tout le reste devient `_`, pour un nom sûr
  /// quel que soit le système qui recevra le fichier.
  String fileNameFor(String title) {
    const accented = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
    const plain = 'aaaaaaceeeeiiiinooooouuuuyy';
    final buffer = StringBuffer();
    for (final char in title.toLowerCase().split('')) {
      final index = accented.indexOf(char);
      buffer.write(index == -1 ? char : plain[index]);
    }
    final slug = buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final base = slug.isEmpty ? 'preset' : slug;
    return '${base.length > 40 ? base.substring(0, 40) : base}.$fileExtension';
  }

  /// Répertoire temporaire de l'application, où sont écrits les fichiers
  /// destinés au partage.
  Future<Directory> temporaryDirectory() => getTemporaryDirectory();

  /// Écrit [code] dans [directory] sous un nom dérivé de [title].
  Future<File> writeCode({
    required String code,
    required String title,
    required Directory directory,
  }) {
    final file = File('${directory.path}/${fileNameFor(title)}');
    return file.writeAsString(code, flush: true);
  }

  /// Lit le code de partage contenu dans [file].
  Future<String> readCode(File file) =>
      _readCode(length: file.length, readAsBytes: file.readAsBytes);

  /// Ouvre le sélecteur de fichiers du système et retourne le code lu,
  /// ou null si l'utilisateur annule.
  ///
  /// Le filtre reste volontairement sur [FileType.any] : Android ne connaît
  /// pas le type MIME de `.ludopreset` et masquerait les fichiers dans le
  /// sélecteur. C'est le contenu, pas l'extension, qui décide de la validité.
  Future<String?> pickCode({String? dialogTitle}) async {
    final PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(dialogTitle: dialogTitle);
    } on PlatformException catch (e) {
      throw PresetFileException(e.message ?? e.code);
    } on MissingPluginException catch (e) {
      throw PresetFileException(e.message ?? 'Sélecteur indisponible');
    }
    if (picked == null) return null;
    // On lit par [PlatformFile] et non par [File] : sur Android, le sélecteur
    // renvoie un URI `content://` sans chemin local exploitable.
    return _readCode(length: picked.length, readAsBytes: picked.readAsBytes);
  }

  /// Contrôle la taille, lit les octets puis décode le texte, quelle que soit
  /// la source du fichier.
  Future<String> _readCode({
    required Future<int> Function() length,
    required Future<Uint8List> Function() readAsBytes,
  }) async {
    final Uint8List bytes;
    try {
      if (await length() > maxFileSize) {
        throw const PresetFileException('Fichier trop volumineux');
      }
      bytes = await readAsBytes();
    } on FileSystemException catch (e) {
      throw PresetFileException(e.message);
    }
    return _decodeText(bytes);
  }

  /// Propose [file] au partage système (mail, messagerie, stockage...).
  Future<void> shareFile(File file, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: mimeType)],
      subject: subject,
    ));
  }

  String _decodeText(Uint8List bytes) {
    try {
      return utf8.decode(bytes).trim();
    } on FormatException {
      throw const PresetFileException('Fichier binaire, texte attendu');
    }
  }
}
