import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ludocount/data/models/app_release.dart';
import 'package:ludocount/data/models/app_update_failure.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:ludocount/ui/features/app_update/view_models/app_update_view_model.dart';

/// Boîte de dialogue de mise à jour : vérifie la dernière release publiée,
/// affiche ses notes puis télécharge et installe son APK.
class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({super.key});

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<AppUpdateViewModel>();
    // Relance une vérification tant qu'aucune mise à jour n'est connue : le
    // contrôle silencieux du démarrage a pu échouer faute de réseau.
    if (!viewModel.isBusy && !viewModel.isUpdateAvailable) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => viewModel.checkForUpdate());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<AppUpdateViewModel>();

    return AlertDialog(
      title: Text(l10n.updateTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildContent(context, l10n, viewModel),
        ),
      ),
      actions: _buildActions(context, l10n, viewModel),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    AppUpdateViewModel viewModel,
  ) {
    final release = viewModel.release;

    switch (viewModel.status) {
      case AppUpdateStatus.idle:
      case AppUpdateStatus.checking:
        return [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.updateChecking)),
            ],
          ),
        ];

      case AppUpdateStatus.upToDate:
        return [
          Row(
            children: [
              Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.updateUpToDate)),
            ],
          ),
          const SizedBox(height: 8),
          _buildCurrentVersion(context, l10n, viewModel),
        ];

      case AppUpdateStatus.updateAvailable:
        return [
          Text(
            l10n.updateAvailable(release!.version.toString()),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          _buildCurrentVersion(context, l10n, viewModel),
          if (release.apkSize != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.updateSize(_formatMegabytes(context, release.apkSize!)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (!release.hasApk) ...[
            const SizedBox(height: 12),
            Text(l10n.updateErrorNoApk,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          ..._buildNotes(context, l10n, release),
        ];

      case AppUpdateStatus.downloading:
        return [
          Text(l10n.updateDownloading),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: viewModel.progress),
          if (viewModel.progress != null) ...[
            const SizedBox(height: 8),
            Text(
              '${(viewModel.progress! * 100).round()} %',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ];

      case AppUpdateStatus.readyToInstall:
        return [
          Text(l10n.updateInstallHint),
        ];

      case AppUpdateStatus.failed:
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 16),
              Expanded(child: Text(_failureMessage(l10n, viewModel.failure))),
            ],
          ),
        ];
    }
  }

  List<Widget> _buildNotes(
    BuildContext context,
    AppLocalizations l10n,
    AppRelease release,
  ) {
    if (release.notes.isEmpty) return const [];
    return [
      const SizedBox(height: 16),
      Text(l10n.updateNotes,
          style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 4),
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: SingleChildScrollView(child: Text(release.notes)),
      ),
    ];
  }

  Widget _buildCurrentVersion(
    BuildContext context,
    AppLocalizations l10n,
    AppUpdateViewModel viewModel,
  ) {
    final version = viewModel.currentVersion;
    return Text(
      version == null ? '' : l10n.updateCurrentVersion(version.toString()),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    AppLocalizations l10n,
    AppUpdateViewModel viewModel,
  ) {
    final close = TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(l10n.updateClose),
    );

    switch (viewModel.status) {
      case AppUpdateStatus.idle:
      case AppUpdateStatus.checking:
      case AppUpdateStatus.upToDate:
        return [close];

      case AppUpdateStatus.updateAvailable:
        final release = viewModel.release!;
        return [
          close,
          if (release.hasApk)
            ElevatedButton.icon(
              onPressed: viewModel.downloadAndInstall,
              icon: const Icon(Icons.download),
              label: Text(l10n.updateDownload),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _openReleasePage(release),
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.updateOpenPage),
            ),
        ];

      case AppUpdateStatus.downloading:
        return [
          TextButton(
            onPressed: viewModel.cancelDownload,
            child: Text(l10n.cancel),
          ),
        ];

      case AppUpdateStatus.readyToInstall:
        return [
          close,
          ElevatedButton.icon(
            onPressed: viewModel.install,
            icon: const Icon(Icons.system_update),
            label: Text(l10n.updateInstall),
          ),
        ];

      case AppUpdateStatus.failed:
        return [
          close,
          if (viewModel.failure == AppUpdateFailure.install &&
              viewModel.canInstall)
            ElevatedButton.icon(
              onPressed: viewModel.install,
              icon: const Icon(Icons.system_update),
              label: Text(l10n.updateInstall),
            )
          else
            ElevatedButton(
              onPressed: viewModel.checkForUpdate,
              child: Text(l10n.updateRetry),
            ),
        ];
    }
  }

  String _failureMessage(AppLocalizations l10n, AppUpdateFailure? failure) {
    switch (failure) {
      case AppUpdateFailure.noRelease:
        return l10n.updateErrorNoRelease;
      case AppUpdateFailure.noApkAsset:
        return l10n.updateErrorNoApk;
      case AppUpdateFailure.download:
        return l10n.updateErrorDownload;
      case AppUpdateFailure.install:
        return l10n.updateErrorInstall;
      case AppUpdateFailure.network:
      case null:
        return l10n.updateErrorNetwork;
    }
  }

  String _formatMegabytes(BuildContext context, int bytes) {
    final locale = Localizations.localeOf(context).languageCode;
    return NumberFormat('0.0', locale).format(bytes / (1024 * 1024));
  }

  Future<void> _openReleasePage(AppRelease release) async {
    await launchUrl(release.pageUrl, mode: LaunchMode.externalApplication);
  }
}
