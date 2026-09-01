/// Les différentes façons dont une mise à jour peut échouer. Le libellé
/// affiché est choisi par la vue, qui seule connaît les traductions.
enum AppUpdateFailure {
  /// Pas de réseau, dépôt injoignable ou réponse inattendue de GitHub.
  network,

  /// Le dépôt ne publie encore aucune release.
  noRelease,

  /// La dernière release existe mais n'a pas d'APK attaché.
  noApkAsset,

  /// Le téléchargement s'est interrompu ou le fichier reçu est incomplet.
  download,

  /// L'APK n'a pas pu être remis à l'installeur du système.
  install,
}

class AppUpdateException implements Exception {
  const AppUpdateException(this.failure, [this.cause]);

  final AppUpdateFailure failure;
  final Object? cause;

  @override
  String toString() => 'AppUpdateException(${failure.name}): $cause';
}
