import '../../data/models/app_release.dart';
import '../../data/models/app_update_failure.dart';
import '../../data/models/app_version.dart';
import '../../data/repositories/app_update_repository.dart';

class UpdateCheckResult {
  const UpdateCheckResult({required this.currentVersion, required this.release});

  final AppVersion? currentVersion;
  final AppRelease release;

  bool get isUpdateAvailable {
    final current = currentVersion;
    return current != null && release.version.isNewerThan(current);
  }
}

/// Compare la version installée à la dernière release publiée sur GitHub.
class CheckForUpdateUseCase {
  CheckForUpdateUseCase({required AppUpdateRepository appUpdateRepository})
      : _repository = appUpdateRepository;

  final AppUpdateRepository _repository;

  /// Lève une [AppUpdateException] si le dépôt est injoignable
  /// ([AppUpdateFailure.network]) ou ne publie encore rien
  /// ([AppUpdateFailure.noRelease]).
  Future<UpdateCheckResult> call() async {
    final currentVersion = await _repository.currentVersion();
    final release = await _repository.fetchLatestRelease();
    if (release == null) {
      throw const AppUpdateException(AppUpdateFailure.noRelease);
    }
    return UpdateCheckResult(
      currentVersion: currentVersion,
      release: release,
    );
  }
}
