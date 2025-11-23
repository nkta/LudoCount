import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_preset.dart';
import '../l10n/app_localizations.dart';

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
                              onPressed: () => provider.deletePreset(preset.id),
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

  void _showCreatePresetDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final scoreController = TextEditingController();
    final roundsController = TextEditingController();
    bool isInverse = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: Text(l10n.newPreset),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.presetNameLabel),
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
                Provider.of<GameProvider>(context, listen: false).addPreset(
                  title: name,
                  isInverseScore: isInverse,
                  targetScore: targetScore,
                  targetRounds: targetRounds,
                );
                Navigator.pop(ctx);
              },
              child: Text(l10n.add),
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
