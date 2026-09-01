import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_version.dart';

/// Expose la version de l'application telle qu'elle a été compilée, c'est à
/// dire le champ `version:` de `pubspec.yaml` recopié par Flutter dans le
/// `versionName` / `versionCode` du paquet natif.
class AppInfoService {
  Future<AppVersion?> currentVersion() async {
    final info = await PackageInfo.fromPlatform();
    final version = AppVersion.tryParse(info.version);
    if (version == null) return null;
    return AppVersion(
      major: version.major,
      minor: version.minor,
      patch: version.patch,
      build: int.tryParse(info.buildNumber) ?? version.build,
    );
  }
}
