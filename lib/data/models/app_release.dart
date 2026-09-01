import 'app_version.dart';

/// Une release publiée sur GitHub, réduite à ce dont la mise à jour in-app a
/// besoin : sa version, ses notes et l'APK qui y est attaché.
class AppRelease {
  const AppRelease({
    required this.version,
    required this.tagName,
    required this.title,
    required this.notes,
    required this.pageUrl,
    this.apkName,
    this.apkUrl,
    this.apkSize,
  });

  final AppVersion version;
  final String tagName;
  final String title;
  final String notes;
  final Uri pageUrl;

  /// Absents lorsque la release ne contient aucun APK : l'utilisateur est
  /// alors renvoyé vers [pageUrl].
  final String? apkName;
  final Uri? apkUrl;
  final int? apkSize;

  bool get hasApk => apkUrl != null;

  /// Lève une [FormatException] si aucun numéro de version n'est lisible dans
  /// le tag ou le titre de la release.
  factory AppRelease.fromJson(Map<String, dynamic> json) {
    final tagName = (json['tag_name'] as String?)?.trim() ?? '';
    final title = (json['name'] as String?)?.trim() ?? '';
    final version = AppVersion.tryParse(tagName) ?? AppVersion.tryParse(title);
    if (version == null) {
      throw FormatException('Version illisible dans la release "$tagName"');
    }

    final assets = (json['assets'] as List?) ?? const [];
    final apk = assets.cast<Map<String, dynamic>>().firstWhere(
          (asset) =>
              (asset['name'] as String?)?.toLowerCase().endsWith('.apk') ??
              false,
          orElse: () => const {},
        );
    final downloadUrl = apk['browser_download_url'] as String?;

    return AppRelease(
      version: version,
      tagName: tagName,
      title: title.isEmpty ? tagName : title,
      notes: (json['body'] as String?)?.trim() ?? '',
      pageUrl: Uri.parse((json['html_url'] as String?) ??
          'https://github.com/nkta/LudoCount/releases'),
      apkName: apk['name'] as String?,
      apkUrl: downloadUrl == null ? null : Uri.parse(downloadUrl),
      apkSize: apk['size'] as int?,
    );
  }
}
