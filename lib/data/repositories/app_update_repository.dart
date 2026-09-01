import 'dart:io';

import '../models/app_release.dart';
import '../models/app_update_failure.dart';
import '../models/app_version.dart';
import '../services/app_info_service.dart';
import '../services/app_installer_service.dart';
import '../services/github_release_service.dart';

/// Point d'entrée unique de la mise à jour in-app : version installée,
/// dernière release publiée, téléchargement et installation de l'APK.
class AppUpdateRepository {
  AppUpdateRepository({
    required GithubReleaseService releaseService,
    required AppInfoService appInfoService,
    required AppInstallerService installerService,
  })  : _releaseService = releaseService,
        _appInfoService = appInfoService,
        _installerService = installerService;

  final GithubReleaseService _releaseService;
  final AppInfoService _appInfoService;
  final AppInstallerService _installerService;

  Future<AppVersion?> currentVersion() => _appInfoService.currentVersion();

  /// `null` si le dépôt ne publie aucune release.
  Future<AppRelease?> fetchLatestRelease() =>
      _releaseService.fetchLatestRelease();

  /// Retourne `null` si [cancelDownload] a interrompu le transfert.
  Future<File?> downloadApk(
    AppRelease release, {
    void Function(int received, int? total)? onProgress,
  }) async {
    final url = release.apkUrl;
    if (url == null) {
      throw const AppUpdateException(AppUpdateFailure.noApkAsset);
    }
    final destination =
        await _installerService.resolveApkFile(release.apkName ?? 'update.apk');
    return _releaseService.downloadApk(
      url: url,
      destination: destination,
      expectedSize: release.apkSize,
      onProgress: onProgress,
    );
  }

  void cancelDownload() => _releaseService.cancelDownload();

  Future<void> installApk(File apk) => _installerService.installApk(apk);

  /// Libère la connexion HTTP du service de release. Le repository n'est plus
  /// utilisable ensuite.
  void close() => _releaseService.close();
}
