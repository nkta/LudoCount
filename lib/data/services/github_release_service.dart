import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/app_release.dart';
import '../models/app_update_failure.dart';

/// Accès en lecture aux GitHub Releases du dépôt : dernière version publiée
/// et téléchargement de l'APK qui y est attaché.
class GithubReleaseService {
  GithubReleaseService({
    http.Client? client,
    this.owner = 'nkta',
    this.repo = 'LudoCount',
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final http.Client _client;

  /// Le service ne ferme que le client qu'il a créé lui-même : un client
  /// injecté reste la propriété de son fournisseur, qui peut le réutiliser
  /// après un [close] (les tests en partagent un entre plusieurs appels).
  final bool _ownsClient;

  final String owner;
  final String repo;

  static const _requestTimeout = Duration(seconds: 15);

  // L'API GitHub rejette les requêtes sans User-Agent.
  static const _headers = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'LudoCount',
  };

  bool _cancelRequested = false;

  /// Retourne `null` quand le dépôt ne publie aucune release (HTTP 404).
  /// Lève une [AppUpdateException] en cas de problème réseau.
  Future<AppRelease?> fetchLatestRelease() async {
    final uri =
        Uri.https('api.github.com', '/repos/$owner/$repo/releases/latest');

    final http.Response response;
    try {
      response = await _client.get(uri, headers: _headers).timeout(
            _requestTimeout,
          );
    } on SocketException catch (e) {
      throw AppUpdateException(AppUpdateFailure.network, e);
    } on http.ClientException catch (e) {
      throw AppUpdateException(AppUpdateFailure.network, e);
    } on TimeoutException catch (e) {
      throw AppUpdateException(AppUpdateFailure.network, e);
    }

    if (response.statusCode == HttpStatus.notFound) return null;
    if (response.statusCode != HttpStatus.ok) {
      throw AppUpdateException(
        AppUpdateFailure.network,
        'HTTP ${response.statusCode}',
      );
    }

    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return AppRelease.fromJson(json as Map<String, dynamic>);
    } on FormatException catch (e) {
      throw AppUpdateException(AppUpdateFailure.network, e);
    }
  }

  /// Télécharge [url] dans [destination] en signalant l'avancement.
  ///
  /// Retourne `null` si [cancelDownload] a été appelé pendant le transfert.
  /// Lève une [AppUpdateException] si le transfert échoue ou si le fichier
  /// reçu ne fait pas la taille annoncée par [expectedSize].
  Future<File?> downloadApk({
    required Uri url,
    required File destination,
    int? expectedSize,
    void Function(int received, int? total)? onProgress,
  }) async {
    _cancelRequested = false;

    // Écrit à côté du fichier final pour ne jamais laisser un APK tronqué
    // utilisable derrière soi.
    final partial = File('${destination.path}.part');
    await destination.parent.create(recursive: true);

    IOSink? sink;
    var succeeded = false;
    try {
      final response = await _client
          .send(http.Request('GET', url)..headers.addAll(_headers))
          .timeout(_requestTimeout);

      if (response.statusCode != HttpStatus.ok) {
        throw AppUpdateException(
          AppUpdateFailure.download,
          'HTTP ${response.statusCode}',
        );
      }

      final total = response.contentLength ?? expectedSize;
      var received = 0;
      final output = partial.openWrite();
      sink = output;
      onProgress?.call(0, total);

      // Le flux est écouté explicitement pour pouvoir annuler la souscription
      // — et donc refermer la connexion HTTP — sans attendre la fin du corps
      // de la réponse.
      final completer = Completer<void>();
      final subscription = response.stream.listen(
        (chunk) {
          if (_cancelRequested) {
            if (!completer.isCompleted) completer.complete();
            return;
          }
          output.add(chunk);
          received += chunk.length;
          onProgress?.call(received, total);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        },
        cancelOnError: true,
      );

      try {
        await completer.future;
      } finally {
        await subscription.cancel();
      }

      if (_cancelRequested) return null;

      await output.close();
      sink = null;

      if (expectedSize != null && received != expectedSize) {
        throw AppUpdateException(
          AppUpdateFailure.download,
          'Fichier incomplet : $received/$expectedSize octets',
        );
      }

      if (await destination.exists()) await destination.delete();
      succeeded = true;
      return await partial.rename(destination.path);
    } on AppUpdateException {
      rethrow;
    } on Exception catch (e) {
      throw AppUpdateException(AppUpdateFailure.download, e);
    } finally {
      await sink?.close();
      // Annulation comme échec : le fichier partiel ne survit pas.
      if (!succeeded) await _deleteQuietly(partial);
    }
  }

  /// Interrompt le téléchargement en cours, s'il y en a un.
  void cancelDownload() => _cancelRequested = true;

  /// Libère la connexion HTTP. Sans effet sur un client injecté, dont la
  /// fermeture appartient à celui qui l'a fourni.
  void close() {
    if (_ownsClient) _client.close();
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Un reliquat dans le cache n'empêche pas de réessayer.
    }
  }
}
