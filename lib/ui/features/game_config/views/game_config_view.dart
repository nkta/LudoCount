import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:ludocount/ui/features/game_config/view_models/game_config_view_model.dart';

class GameConfigView extends StatefulWidget {
  const GameConfigView({super.key});

  @override
  State<GameConfigView> createState() => _GameConfigViewState();
}

class _GameConfigViewState extends State<GameConfigView> {
  final _titleController = TextEditingController();
  final _maxScoreController = TextEditingController();
  final _maxRoundsController = TextEditingController();
  bool _initializedPresetArg = false;

  @override
  void dispose() {
    _titleController.dispose();
    _maxScoreController.dispose();
    _maxRoundsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<GameConfigViewModel>();
    final presetArg =
        ModalRoute.of(context)?.settings.arguments as GamePreset?;

    if (!_initializedPresetArg && presetArg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.applyPreset(presetArg);
        vm.selectedPresetId = presetArg.id;
        _maxScoreController.text =
            presetArg.targetScore != null ? '${presetArg.targetScore}' : '';
        _maxRoundsController.text =
            presetArg.targetRounds != null ? '${presetArg.targetRounds}' : '';
      });
      _initializedPresetArg = true;
    }

    final isPresetLocked = vm.selectedPresetId != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newGameTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.gameTitleLabel,
                hintText: l10n.gameTitleHint,
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 24),

            if (vm.presets.isNotEmpty) ...[
              Text(l10n.presets,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                value: vm.selectedPresetId,
                hint: Text(l10n.presets),
                items: [
                  const DropdownMenuItem(value: null, child: Text('-')),
                  ...vm.presets.map((preset) => DropdownMenuItem(
                        value: preset.id,
                        child: Text(preset.title),
                      )),
                ],
                onChanged: (value) {
                  if (value != null) {
                    final preset =
                        vm.presets.firstWhere((p) => p.id == value);
                    vm.applyPreset(preset);
                    vm.selectedPresetId = value;
                    _maxScoreController.text = preset.targetScore != null
                        ? '${preset.targetScore}'
                        : '';
                    _maxRoundsController.text = preset.targetRounds != null
                        ? '${preset.targetRounds}'
                        : '';
                  } else {
                    vm.clearPreset();
                    _maxScoreController.clear();
                    _maxRoundsController.clear();
                  }
                },
              ),
              const SizedBox(height: 24),
            ],

            Text(l10n.selectPlayers,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (vm.players.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(l10n.noPlayers),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/players'),
                        child: Text(l10n.createPlayers),
                      )
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: vm.players.map((player) {
                  final isSelected =
                      vm.selectedPlayerIds.contains(player.id);
                  return FilterChip(
                    label: Text(player.name),
                    selected: isSelected,
                    onSelected: (_) => vm.togglePlayer(player.id),
                    selectedColor: Theme.of(context).primaryColor,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            if (vm.selectedGameType == GameType.standard) ...[
              Text(l10n.options,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.inverseScoring),
                subtitle: Text(l10n.inverseScoringSubtitle),
                value: vm.isInverseScore,
                onChanged: isPresetLocked ? null : vm.setIsInverseScore,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _maxScoreController,
                      keyboardType: TextInputType.number,
                      enabled: !isPresetLocked,
                      decoration: InputDecoration(
                        labelText: l10n.maxScoreLabel,
                        hintText: l10n.maxScoreHint,
                        prefixIcon: const Icon(Icons.flag),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxRoundsController,
                      keyboardType: TextInputType.number,
                      enabled: !isPresetLocked,
                      decoration: InputDecoration(
                        labelText: l10n.maxRoundsLabel,
                        hintText: l10n.maxRoundsHint,
                        prefixIcon: const Icon(Icons.repeat),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Mode de jeu: ${vm.selectedGameType == GameType.sevenWonders ? "7 Wonders" : "Skull King"}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Les options sont configurées automatiquement pour ce mode de jeu.'),
            ],

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726)),
              onPressed: vm.selectedPlayerIds.isEmpty
                  ? null
                  : () => _startGame(context, vm, l10n),
              child: Text(l10n.startGame),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startGame(
    BuildContext context,
    GameConfigViewModel vm,
    AppLocalizations l10n,
  ) async {
    if (vm.minPlayers != null &&
        vm.selectedPlayerIds.length < vm.minPlayers!) {
      final proceed = await _showWarning(
          context,
          l10n,
          'Ce preset recommande au moins ${vm.minPlayers} joueurs. Voulez-vous continuer ?');
      if (proceed != true) return;
    }
    if (vm.maxPlayers != null &&
        vm.selectedPlayerIds.length > vm.maxPlayers!) {
      final proceed = await _showWarning(
          context,
          l10n,
          'Ce preset recommande au maximum ${vm.maxPlayers} joueurs. Voulez-vous continuer ?');
      if (proceed != true) return;
    }

    final gameId = await vm.createGame(
      rawTitle: _titleController.text.trim(),
      l10n: l10n,
      targetScore: int.tryParse(_maxScoreController.text),
      targetRounds: int.tryParse(_maxRoundsController.text),
    );
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/score', arguments: gameId);
    }
  }

  Future<bool?> _showWarning(
      BuildContext context, AppLocalizations l10n, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Attention'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuer')),
        ],
      ),
    );
  }
}
