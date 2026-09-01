import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ludocount/data/models/app_release.dart';
import 'package:ludocount/data/models/app_update_failure.dart';
import 'package:ludocount/data/models/app_version.dart';
import 'package:ludocount/data/repositories/app_update_repository.dart';
import 'package:ludocount/data/services/app_info_service.dart';
import 'package:ludocount/data/services/app_installer_service.dart';
import 'package:ludocount/data/services/github_release_service.dart';
import 'package:ludocount/domain/use_cases/check_for_update_use_case.dart';

Map<String, dynamic> _releaseJson({
  String tagName = 'v1.2.0',
  bool withApk = true,
  int apkSize = 12,
}) =>
    {
      'tag_name': tagName,
      'name': 'LudoCount $tagName',
      'body': 'Corrections diverses',
      'html_url': 'https://github.com/nkta/LudoCount/releases/tag/$tagName',
      'assets': [
        {'name': 'notes.txt', 'browser_download_url': 'https://x/notes.txt'},
        if (withApk)
          {
            'name': 'ludocount-$tagName.apk',
            'browser_download_url': 'https://x/ludocount.apk',
            'size': apkSize,
          },
      ],
    };

/// Client qui note sa fermeture, pour vérifier que le service ne ferme que
/// le client qu'il a créé lui-même.
class _RecordingClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(const Stream<List<int>>.empty(), 404);

  @override
  void close() => closed = true;
}

void main() {
  group('AppVersion', () {
    test('parse les formats de pubspec.yaml et de tag GitHub', () {
      expect(AppVersion.tryParse('1.2.3+4').toString(), '1.2.3+4');
      expect(AppVersion.tryParse('v1.2.3').toString(), '1.2.3');
      expect(AppVersion.tryParse('2').toString(), '2.0.0');
      expect(AppVersion.tryParse('v1.2.3-beta').toString(), '1.2.3');
      expect(AppVersion.tryParse('release'), isNull);
    });

    test('compare les composants dans l\'ordre', () {
      final current = AppVersion.tryParse('1.2.3')!;
      expect(AppVersion.tryParse('1.2.4')!.isNewerThan(current), isTrue);
      expect(AppVersion.tryParse('1.3.0')!.isNewerThan(current), isTrue);
      expect(AppVersion.tryParse('2.0.0')!.isNewerThan(current), isTrue);
      expect(AppVersion.tryParse('1.2.3')!.isNewerThan(current), isFalse);
      expect(AppVersion.tryParse('1.2.2')!.isNewerThan(current), isFalse);
    });

    test('le numéro de build ne départage que si les deux le déclarent', () {
      final build1 = AppVersion.tryParse('1.0.0+1')!;
      expect(AppVersion.tryParse('1.0.0+2')!.isNewerThan(build1), isTrue);
      expect(AppVersion.tryParse('1.0.0')!.isNewerThan(build1), isFalse);
      expect(build1.isNewerThan(AppVersion.tryParse('1.0.0')!), isFalse);
    });
  });

  group('AppRelease', () {
    test('retient l\'APK attaché à la release', () {
      final release = AppRelease.fromJson(_releaseJson());
      expect(release.version.toString(), '1.2.0');
      expect(release.hasApk, isTrue);
      expect(release.apkName, 'ludocount-v1.2.0.apk');
      expect(release.apkSize, 12);
      expect(release.notes, 'Corrections diverses');
    });

    test('signale une release sans APK', () {
      final release = AppRelease.fromJson(_releaseJson(withApk: false));
      expect(release.hasApk, isFalse);
      expect(release.pageUrl.host, 'github.com');
    });

    test('rejette une release dont la version est illisible', () {
      expect(
        () => AppRelease.fromJson(_releaseJson(tagName: 'nightly')),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('GithubReleaseService', () {
    test('lit la dernière release publiée', () async {
      final service = GithubReleaseService(
        client: MockClient((request) async {
          expect(request.url.path, '/repos/nkta/LudoCount/releases/latest');
          return http.Response(jsonEncode(_releaseJson()), 200);
        }),
      );

      final release = await service.fetchLatestRelease();
      expect(release!.version.toString(), '1.2.0');
    });

    test('retourne null quand le dépôt ne publie aucune release', () async {
      final service = GithubReleaseService(
        client: MockClient((_) async => http.Response('{}', 404)),
      );
      expect(await service.fetchLatestRelease(), isNull);
    });

    test('signale une erreur réseau', () async {
      final service = GithubReleaseService(
        client: MockClient((_) async => throw const SocketException('offline')),
      );
      await expectLater(
        service.fetchLatestRelease(),
        throwsA(isA<AppUpdateException>().having(
            (e) => e.failure, 'failure', AppUpdateFailure.network)),
      );
    });

    test('signale une réponse inattendue de GitHub', () async {
      final service = GithubReleaseService(
        client: MockClient((_) async => http.Response('rate limited', 403)),
      );
      await expectLater(
        service.fetchLatestRelease(),
        throwsA(isA<AppUpdateException>().having(
            (e) => e.failure, 'failure', AppUpdateFailure.network)),
      );
    });

    test('télécharge l\'APK et suit la progression', () async {
      final bytes = List<int>.generate(64, (i) => i);
      final service = GithubReleaseService(
        client: MockClient((_) async => http.Response.bytes(bytes, 200)),
      );
      final directory = await Directory.systemTemp.createTemp('ludocount');
      addTearDown(() => directory.delete(recursive: true));

      final progress = <double>[];
      final apk = await service.downloadApk(
        url: Uri.parse('https://x/ludocount.apk'),
        destination: File('${directory.path}/updates/ludocount.apk'),
        expectedSize: bytes.length,
        onProgress: (received, total) => progress.add(received / total!),
      );

      expect(await apk!.readAsBytes(), bytes);
      expect(progress.last, 1.0);
      expect(File('${apk.path}.part').existsSync(), isFalse);
    });

    test('ne ferme pas un client injecté', () {
      final client = _RecordingClient();
      GithubReleaseService(client: client).close();
      expect(client.closed, isFalse);
    });

    test('abandonne le téléchargement quand il est annulé', () async {
      final service = GithubReleaseService(
        client: MockClient(
            (_) async => http.Response.bytes(List.filled(32, 7), 200)),
      );
      final directory = await Directory.systemTemp.createTemp('ludocount');
      addTearDown(() => directory.delete(recursive: true));
      final destination = File('${directory.path}/ludocount.apk');

      final apk = await service.downloadApk(
        url: Uri.parse('https://x/ludocount.apk'),
        destination: destination,
        onProgress: (_, __) => service.cancelDownload(),
      );

      expect(apk, isNull);
      expect(destination.existsSync(), isFalse);
      expect(File('${destination.path}.part').existsSync(), isFalse);
    });

    test('refuse un APK dont la taille ne correspond pas', () async {
      final service = GithubReleaseService(
        client: MockClient((_) async => http.Response.bytes([1, 2, 3], 200)),
      );
      final directory = await Directory.systemTemp.createTemp('ludocount');
      addTearDown(() => directory.delete(recursive: true));
      final destination = File('${directory.path}/ludocount.apk');

      await expectLater(
        service.downloadApk(
          url: Uri.parse('https://x/ludocount.apk'),
          destination: destination,
          expectedSize: 999,
        ),
        throwsA(isA<AppUpdateException>().having(
            (e) => e.failure, 'failure', AppUpdateFailure.download)),
      );
      expect(destination.existsSync(), isFalse);
      expect(File('${destination.path}.part').existsSync(), isFalse);
    });
  });

  group('CheckForUpdateUseCase', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      PackageInfo.setMockInitialValues(
        appName: 'LudoCount',
        packageName: 'com.ludocount.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
    });

    CheckForUpdateUseCase buildUseCase(MockClient client) =>
        CheckForUpdateUseCase(
          appUpdateRepository: AppUpdateRepository(
            releaseService: GithubReleaseService(client: client),
            appInfoService: AppInfoService(),
            installerService: AppInstallerService(),
          ),
        );

    test('détecte une version plus récente', () async {
      final useCase = buildUseCase(
        MockClient((_) async => http.Response(jsonEncode(_releaseJson()), 200)),
      );

      final result = await useCase();
      expect(result.currentVersion.toString(), '1.0.0+1');
      expect(result.isUpdateAvailable, isTrue);
    });

    test('ne propose rien quand la version installée est à jour', () async {
      final useCase = buildUseCase(
        MockClient((_) async =>
            http.Response(jsonEncode(_releaseJson(tagName: 'v1.0.0')), 200)),
      );
      expect((await useCase()).isUpdateAvailable, isFalse);
    });

    test('signale l\'absence de release publiée', () async {
      final useCase =
          buildUseCase(MockClient((_) async => http.Response('{}', 404)));
      await expectLater(
        useCase(),
        throwsA(isA<AppUpdateException>().having(
            (e) => e.failure, 'failure', AppUpdateFailure.noRelease)),
      );
    });
  });
}
