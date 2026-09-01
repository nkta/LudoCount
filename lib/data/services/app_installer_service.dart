import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_update_failure.dart';

/// Remet l'APK téléchargé à l'installeur du système.
///
/// Android n'autorise pas l'ouverture d'un `file://` depuis Android 7 :
/// `open_filex` passe par un `FileProvider` qui expose le fichier en
/// `content://`. L'installation reste soumise à l'autorisation
/// « Installer des applications inconnues » demandée par le système.
class AppInstallerService {
  static const _apkMimeType = 'application/vnd.android.package-archive';

  /// Emplacement d'écriture de l'APK, dans le cache de l'application : le
  /// système peut le récupérer et `open_filex` sait l'exposer.
  Future<File> resolveApkFile(String fileName) async {
    final directory = await getTemporaryDirectory();
    return File('${directory.path}/updates/${_sanitize(fileName)}');
  }

  Future<void> installApk(File apk) async {
    final result = await OpenFilex.open(apk.path, type: _apkMimeType);
    if (result.type != ResultType.done) {
      throw AppUpdateException(
        AppUpdateFailure.install,
        '${result.type.name}: ${result.message}',
      );
    }
  }

  /// Le nom de l'asset vient de GitHub : on le réduit à un nom de fichier sûr.
  String _sanitize(String fileName) {
    final cleaned = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'update.apk' : cleaned;
  }
}
