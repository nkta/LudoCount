import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:ludocount/ui/features/app_update/view_models/app_update_view_model.dart';
import 'package:ludocount/ui/features/app_update/views/app_update_dialog.dart';
import 'package:ludocount/ui/features/home/view_models/home_view_model.dart';
import 'package:ludocount/ui/features/dice/views/dice_roll_dialog.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [_buildUpdateAction(l10n)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              _buildMenuButton(context,
                  label: l10n.continueLabel,
                  color: const Color(0xFF66BB6A),
                  onPressed: () => _continueLastGame(context)),
              const SizedBox(height: 16),
              _buildMenuButton(context,
                  label: l10n.newGame,
                  color: const Color(0xFFFFA726),
                  onPressed: () => Navigator.pushNamed(context, '/config')),
              const SizedBox(height: 16),
              _buildMenuButton(context,
                  label: l10n.presets.toUpperCase(),
                  color: const Color(0xFF8E24AA),
                  onPressed: () => Navigator.pushNamed(context, '/presets')),
              const SizedBox(height: 16),
              _buildMenuButton(context,
                  label: l10n.history,
                  color: const Color(0xFFEF5350),
                  onPressed: () => Navigator.pushNamed(context, '/history')),
              const SizedBox(height: 16),
              _buildMenuButton(context,
                  label: l10n.players,
                  color: const Color(0xFF42A5F5),
                  onPressed: () => Navigator.pushNamed(context, '/players')),
              const SizedBox(height: 16),
              _buildMenuButton(context,
                  label: l10n.diceRoller.toUpperCase(),
                  color: const Color(0xFF26A69A),
                  icon: Icons.casino,
                  onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const DiceRollDialog(),
                      )),
              const SizedBox(height: 16),
              _buildMenuButton(context,
                  label: 'Soutenir le dev',
                  color: Colors.pinkAccent,
                  icon: Icons.coffee,
                  onPressed: _launchDonationUrl),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouton de mise à jour, surmonté d'une pastille lorsqu'une version plus
  /// récente a été trouvée. Masqué hors Android, seule plateforme où
  /// l'installation d'un APK est possible.
  Widget _buildUpdateAction(AppLocalizations l10n) {
    return Consumer<AppUpdateViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isSupportedPlatform) return const SizedBox.shrink();
        return IconButton(
          tooltip: l10n.updateCheck,
          icon: Badge(
            isLabelVisible: viewModel.isUpdateAvailable,
            child: const Icon(Icons.system_update),
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const AppUpdateDialog(),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
            Text(label,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _continueLastGame(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.read<HomeViewModel>();
    final lastGame = vm.getLastGame();
    if (lastGame != null) {
      Navigator.pushNamed(context, '/score', arguments: lastGame.id);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.noRecentGame)));
    }
  }

  Future<void> _launchDonationUrl() async {
    final uri = Uri.parse('https://buymeacoffee.com/nkta1');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }
}
