import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/repositories/preset_repository.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:ludocount/ui/features/expert_preset_config/view_models/expert_preset_config_view_model.dart';
import 'package:ludocount/ui/features/expert_preset_config/views/expert_preset_config_view.dart';
import 'package:ludocount/ui/features/presets/view_models/presets_view_model.dart';
import 'package:ludocount/ui/features/qr_scan/views/qr_scan_view.dart';

class PresetsView extends StatelessWidget {
  const PresetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.presets),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Importer un preset',
            onPressed: () => _showImportDialog(
                context, context.read<PresetsViewModel>()),
          ),
        ],
      ),
      body: Consumer<PresetsViewModel>(
        builder: (context, vm, _) {
          final presets = vm.presets;
          if (presets.isEmpty) {
            return Center(child: Text(l10n.noPresets));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              return _PresetCard(preset: preset, vm: vm);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePresetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePresetDialog(BuildContext context, {GamePreset? preset}) {
    final l10n = AppLocalizations.of(context);
    final vm = context.read<PresetsViewModel>();
    final nameController =
        TextEditingController(text: preset?.title);
    final scoreController =
        TextEditingController(text: preset?.targetScore?.toString());
    final roundsController =
        TextEditingController(text: preset?.targetRounds?.toString());
    final minPlayersController =
        TextEditingController(text: preset?.minPlayers?.toString());
    final maxPlayersController =
        TextEditingController(text: preset?.maxPlayers?.toString());
    bool isInverse = preset?.isInverseScore ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(preset != null ? 'Modifier le preset' : l10n.newPreset),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (preset == null) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ChangeNotifierProvider(
                          create: (_) => ExpertPresetConfigViewModel(
                              presetRepository: context.read<PresetRepository>()),
                          child: const ExpertPresetConfigView(),
                        ),
                      ));
                    },
                    child: const Text('Mode Expert (Avancé)'),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: nameController,
                  decoration:
                      InputDecoration(labelText: l10n.presetNameLabel),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isInverse,
                  onChanged: (val) => setState(() => isInverse = val),
                  title: Text(l10n.inverseScoring),
                  subtitle: Text(l10n.inverseScoringSubtitle),
                ),
                TextField(
                  controller: scoreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.maxScoreLabel,
                    hintText: l10n.maxScoreHint,
                  ),
                ),
                TextField(
                  controller: roundsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.maxRoundsLabel,
                    hintText: l10n.maxRoundsHint,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPlayersController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Joueurs Min'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: maxPlayersController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Joueurs Max'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final targetScore =
                    int.tryParse(scoreController.text);
                final targetRounds =
                    int.tryParse(roundsController.text);
                final minPlayers =
                    int.tryParse(minPlayersController.text);
                final maxPlayers =
                    int.tryParse(maxPlayersController.text);

                if (preset != null) {
                  vm.savePreset(GamePreset(
                    id: preset.id,
                    title: name,
                    isInverseScore: isInverse,
                    targetScore: targetScore,
                    targetRounds: targetRounds,
                    isCustom: true,
                    type: GameType.standard,
                    fields: preset.fields,
                    scoreFormula: preset.scoreFormula,
                    scoringRules: preset.scoringRules,
                    roundLabels: preset.roundLabels,
                    minPlayers: minPlayers,
                    maxPlayers: maxPlayers,
                  ));
                } else {
                  vm.addPreset(
                    title: name,
                    isInverseScore: isInverse,
                    targetScore: targetScore,
                    targetRounds: targetRounds,
                    type: GameType.standard,
                    minPlayers: minPlayers,
                    maxPlayers: maxPlayers,
                  );
                }
                Navigator.pop(ctx);
              },
              child:
                  Text(preset != null ? l10n.save : l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(
      BuildContext context, PresetsViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importer un preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Code du preset',
                hintText: 'Collez le code ici...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    final code = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const QRScanView()),
                    );
                    if (code != null) controller.text = code;
                  },
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              try {
                final code = controller.text.trim();
                if (code.isEmpty) return;
                final preset = vm.decodePreset(code);
                Navigator.pop(ctx);
                _showImportPreviewDialog(context, vm, preset);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code invalide')));
              }
            },
            child: const Text('Vérifier'),
          ),
        ],
      ),
    );
  }

  void _showImportPreviewDialog(
      BuildContext context, PresetsViewModel vm, GamePreset preset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer l'importation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titre: ${preset.title}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Type: ${preset.isCustom ? "Expert" : "Standard"}'),
            if (preset.targetScore != null)
              Text('Score max: ${preset.targetScore}'),
            if (preset.targetRounds != null)
              Text('Tours max: ${preset.targetRounds}'),
            if (preset.fields != null)
              Text('Champs: ${preset.fields!.map((f) => f.label).join(", ")}'),
            const SizedBox(height: 16),
            const Text(
                'Voulez-vous ajouter ce preset à votre collection ?'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              vm.importPreset(preset);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Preset "${preset.title}" importé !')));
              Navigator.pop(ctx);
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final GamePreset preset;
  final PresetsViewModel vm;

  const _PresetCard({required this.preset, required this.vm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = <Widget>[
      _chip(context,
          preset.isInverseScore ? l10n.modeInverse : l10n.modeStandard),
      if (preset.targetScore != null)
        _chip(context, '${l10n.maxScoreLabelInfo} ${preset.targetScore}'),
      if (preset.targetRounds != null)
        _chip(context,
            '${l10n.maxRoundsLabelInfo} ${preset.targetRounds}'),
      if (preset.minPlayers != null || preset.maxPlayers != null)
        _chip(context, _playerLabel()),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(preset.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/config',
                        arguments: preset),
                    label: Text(l10n.usePreset),
                  ),
                ),
                if (preset.isCustom) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (preset.fields != null &&
                          preset.fields!.isNotEmpty) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ChangeNotifierProvider(
                            create: (_) => ExpertPresetConfigViewModel(
                              presetRepository:
                                  context.read<PresetRepository>(),
                              preset: preset,
                            ),
                            child: const ExpertPresetConfigView(),
                          ),
                        ));
                      } else {
                        _showEditDialog(context);
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
                ],
                IconButton(
                  onPressed: () => _showShareDialog(context),
                  icon: const Icon(Icons.share),
                  tooltip: 'Partager',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _playerLabel() {
    if (preset.minPlayers != null && preset.maxPlayers != null) {
      return 'Joueurs: ${preset.minPlayers}-${preset.maxPlayers}';
    } else if (preset.minPlayers != null) {
      return 'Joueurs: ${preset.minPlayers}+';
    } else {
      return 'Joueurs: max ${preset.maxPlayers}';
    }
  }

  Widget _chip(BuildContext context, String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }

  void _showEditDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: preset.title);
    final scoreController =
        TextEditingController(text: preset.targetScore?.toString());
    final roundsController =
        TextEditingController(text: preset.targetRounds?.toString());
    final minPlayersController =
        TextEditingController(text: preset.minPlayers?.toString());
    final maxPlayersController =
        TextEditingController(text: preset.maxPlayers?.toString());
    bool isInverse = preset.isInverseScore;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Modifier le preset'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: l10n.presetNameLabel),
                    textCapitalization: TextCapitalization.sentences),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isInverse,
                  onChanged: (val) => setState(() => isInverse = val),
                  title: Text(l10n.inverseScoring),
                  subtitle: Text(l10n.inverseScoringSubtitle),
                ),
                TextField(
                    controller: scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: l10n.maxScoreLabel,
                        hintText: l10n.maxScoreHint)),
                TextField(
                    controller: roundsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: l10n.maxRoundsLabel,
                        hintText: l10n.maxRoundsHint)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: minPlayersController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Joueurs Min'))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextField(
                          controller: maxPlayersController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Joueurs Max'))),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                vm.savePreset(GamePreset(
                  id: preset.id,
                  title: name,
                  isInverseScore: isInverse,
                  targetScore: int.tryParse(scoreController.text),
                  targetRounds: int.tryParse(roundsController.text),
                  isCustom: true,
                  type: GameType.standard,
                  fields: preset.fields,
                  scoreFormula: preset.scoreFormula,
                  scoringRules: preset.scoringRules,
                  roundLabels: preset.roundLabels,
                  minPlayers: int.tryParse(minPlayersController.text),
                  maxPlayers: int.tryParse(maxPlayersController.text),
                ));
                Navigator.pop(ctx);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content:
            const Text('Voulez-vous vraiment supprimer ce preset ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () {
              vm.deletePreset(preset.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    final code = vm.encodePreset(preset);
    showDialog(
      context: context,
      builder: (ctx) => DefaultTabController(
        length: 2,
        child: AlertDialog(
          title: const Text('Partager le preset'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: Column(
              children: [
                const TabBar(
                  tabs: [Tab(text: 'Code'), Tab(text: 'QR Code')],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                              'Copiez ce code pour partager votre preset :'),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: SelectableText(
                                code,
                                style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: QrImageView(
                            data: code,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fermer')),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Code copié dans le presse-papier')));
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copier'),
            ),
          ],
        ),
      ),
    );
  }
}
