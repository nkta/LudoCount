import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_preset.dart';
import '../l10n/app_localizations.dart';
import 'expert_preset_config_screen.dart';

class PresetScreen extends StatelessWidget {
  const PresetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.presets)),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          final presets = provider.presets;
          if (presets.isEmpty) {
            return Center(child: Text(l10n.noPresets));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              final title = _titleFor(preset, l10n);
              final desc = _descFor(preset, l10n);
              final chips = <Widget>[];
              chips.add(_buildChip(
                  context,
                  preset.isInverseScore
                      ? l10n.modeInverse
                      : l10n.modeStandard));
              if (preset.targetScore != null) {
                chips.add(_buildChip(context,
                    '${l10n.maxScoreLabelInfo} ${preset.targetScore}'));
              }
              if (preset.targetRounds != null) {
                chips.add(_buildChip(context,
                    '${l10n.maxRoundsLabelInfo} ${preset.targetRounds}'));
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (desc.isNotEmpty) ...[
                        Text(desc),
                        const SizedBox(height: 12),
                      ],
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: chips,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/config',
                                    arguments: preset);
                              },
                              label: Text(l10n.usePreset),
                            ),
                          ),
                          if (preset.isCustom) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                if (preset.fields != null && preset.fields!.isNotEmpty) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ExpertPresetConfigScreen(preset: preset),
                                    ),
                                  );
                                } else {
                                  _showCreatePresetDialog(context, preset: preset);
                                }
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text('Voulez-vous vraiment supprimer ce preset ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text(l10n.cancel),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () {
                                          provider.deletePreset(preset.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                ),
              );
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

  String _titleFor(GamePreset preset, AppLocalizations l10n) {
    return preset.title;
  }

  String _descFor(GamePreset preset, AppLocalizations l10n) {
    return '';
  }

  void _showCreatePresetDialog(BuildContext context, {GamePreset? preset}) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: preset?.title);
    final scoreController = TextEditingController(text: preset?.targetScore?.toString());
    final roundsController = TextEditingController(text: preset?.targetRounds?.toString());
    bool isInverse = preset?.isInverseScore ?? false;
    GameType selectedType = preset?.type ?? GameType.standard;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: Text(preset != null ? 'Modifier le preset' : l10n.newPreset),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (preset == null) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Fermer le dialog
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ExpertPresetConfigScreen()),
                      );
                    },
                    child: const Text('Mode Expert (Avancé)'),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.presetNameLabel),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final targetScore = int.tryParse(scoreController.text);
                final targetRounds = int.tryParse(roundsController.text);
                
                if (preset != null) {
                  // Update existing
                  final updatedPreset = GamePreset(
                    id: preset.id,
                    title: name,
                    isInverseScore: isInverse,
                    targetScore: targetScore,
                    targetRounds: targetRounds,
                    isCustom: true,
                    type: GameType.standard,
                    // Preserve other fields just in case, though standard shouldn't have them
                    fields: preset.fields,
                    scoreFormula: preset.scoreFormula,
                    scoringRules: preset.scoringRules,
                    roundLabels: preset.roundLabels,
                  );
                  Provider.of<GameProvider>(context, listen: false).savePreset(updatedPreset);
                } else {
                  // Create new
                  Provider.of<GameProvider>(context, listen: false).addPreset(
                    title: name,
                    isInverseScore: isInverse,
                    targetScore: targetScore,
                    targetRounds: targetRounds,
                    type: GameType.standard,
                  );
                }
                Navigator.pop(ctx);
              },
              child: Text(preset != null ? l10n.save : l10n.add),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }
}
