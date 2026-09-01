import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ludocount/data/models/app_release.dart';
import 'package:ludocount/data/models/app_update_failure.dart';
import 'package:ludocount/data/models/app_version.dart';
import 'package:ludocount/data/repositories/app_update_repository.dart';
import 'package:ludocount/domain/use_cases/check_for_update_use_case.dart';

enum AppUpdateStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  downloading,
  readyToInstall,
  failed,
}

class AppUpdateViewModel extends ChangeNotifier {
  AppUpdateViewModel({
    required AppUpdateRepository appUpdateRepository,
    required CheckForUpdateUseCase checkForUpdateUseCase,
  })  : _repository = appUpdateRepository,
        _checkForUpdate = checkForUpdateUseCase;

  final AppUpdateRepository _repository;
  final CheckForUpdateUseCase _checkForUpdate;

  AppUpdateStatus _status = AppUpdateStatus.idle;
  AppUpdateFailure? _failure;
  AppRelease? _release;
  AppVersion? _currentVersion;
  double? _progress;
  File? _apk;
  bool _disposed = false;

  AppUpdateStatus get status => _status;
  AppUpdateFailure? get failure => _failure;
  AppRelease? get release => _release;
  AppVersion? get currentVersion => _currentVersion;

  /// Avancement du téléchargement entre 0 et 1, `null` tant que la taille
  /// totale est inconnue (barre indéterminée).
  double? get progress => _progress;

  /// L'installation d'un APK n'a de sens que sur Android : ailleurs, la
  /// fonctionnalité est simplement masquée.
  bool get isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Une release plus récente a été trouvée : elle reste connue tant qu'une
  /// nouvelle vérification ne l'a pas infirmée, même si le téléchargement a
  /// échoué entre temps.
  bool get isUpdateAvailable => _release != null;

  /// Un APK déjà téléchargé attend d'être installé : inutile de refaire le
  /// transfert si l'installeur du système a été refusé ou fermé.
  bool get canInstall => _apk != null;

  bool get isBusy =>
      _status == AppUpdateStatus.checking ||
      _status == AppUpdateStatus.downloading;

  Future<void> checkForUpdate() async {
    if (_disposed || !isSupportedPlatform || isBusy) return;

    _set(status: AppUpdateStatus.checking);
    try {
      final result = await _checkForUpdate();
      _currentVersion = result.currentVersion;
      _release = result.isUpdateAvailable ? result.release : null;
      _set(
        status: result.isUpdateAvailable
            ? AppUpdateStatus.updateAvailable
            : AppUpdateStatus.upToDate,
      );
    } on AppUpdateException catch (e) {
      _fail(e.failure);
    } catch (e) {
      debugPrint('Vérification de mise à jour impossible : $e');
      _fail(AppUpdateFailure.network);
    }
  }

  /// Télécharge l'APK de la release puis passe la main à l'installeur du
  /// système. Sans effet si aucune mise à jour n'a été trouvée.
  Future<void> downloadAndInstall() async {
    final release = _release;
    if (release == null || _status == AppUpdateStatus.downloading) return;

    _apk = null;
    _set(status: AppUpdateStatus.downloading, progress: 0);
    try {
      final apk = await _repository.downloadApk(
        release,
        onProgress: _onDownloadProgress,
      );
      if (apk == null) {
        // Téléchargement annulé par l'utilisateur.
        _set(status: AppUpdateStatus.updateAvailable, progress: null);
        return;
      }
      _apk = apk;
      _set(status: AppUpdateStatus.readyToInstall, progress: null);
      await install();
    } on AppUpdateException catch (e) {
      _fail(e.failure);
    } catch (e) {
      debugPrint('Téléchargement de la mise à jour impossible : $e');
      _fail(AppUpdateFailure.download);
    }
  }

  /// Relance l'installeur système pour l'APK déjà téléchargé, par exemple si
  /// l'utilisateur a fermé la boîte de dialogue du système.
  Future<void> install() async {
    final apk = _apk;
    if (apk == null) return;
    try {
      await _repository.installApk(apk);
    } on AppUpdateException catch (e) {
      _fail(e.failure);
    } catch (e) {
      debugPrint('Installation de la mise à jour impossible : $e');
      _fail(AppUpdateFailure.install);
    }
  }

  void cancelDownload() {
    if (_status != AppUpdateStatus.downloading) return;
    _repository.cancelDownload();
  }

  void _onDownloadProgress(int received, int? total) {
    if (total == null || total <= 0) {
      // Taille inconnue : barre indéterminée, rien à rafraîchir.
      if (_progress != null) _set(progress: null);
      return;
    }
    final progress = received / total;
    // Le flux arrive par petits blocs : ne réveiller l'interface qu'au
    // pourcentage près.
    if (_progress != null && (progress - _progress!).abs() < 0.01) return;
    _set(progress: progress);
  }

  /// Toute transition réécrit l'état complet : un appel sans `failure` ni
  /// `progress` les remet à zéro.
  void _set({
    AppUpdateStatus? status,
    AppUpdateFailure? failure,
    double? progress,
  }) {
    if (status != null) _status = status;
    _failure = failure;
    _progress = progress;
    if (!_disposed) notifyListeners();
  }

  void _fail(AppUpdateFailure failure) =>
      _set(status: AppUpdateStatus.failed, failure: failure, progress: null);

  @override
  void dispose() {
    _disposed = true;
    _repository.cancelDownload();
    _repository.close();
    super.dispose();
  }
}
