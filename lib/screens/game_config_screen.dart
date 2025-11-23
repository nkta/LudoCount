import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/game_preset.dart';

class GameConfigScreen extends StatefulWidget {
  const GameConfigScreen({super.key});

  @override
  State<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends State<GameConfigScreen> {
  final _titleController = TextEditingController();
  final _maxScoreController = TextEditingController();
  final _maxRoundsController = TextEditingController();
  final List<String> _selectedPlayerIds = [];
  String? _selectedPresetId;
  bool _initializedSelection = false;
  bool _isInverseScore = false;

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
    final provider = Provider.of<GameProvider>(context);
    final players = provider.players;
    final defaultIds = provider.getDefaultPlayerIds();
    final preferredIds = defaultIds;
    final presets = provider.presets;
    final presetArg = ModalRoute.of(context)?.settings.arguments as GamePreset?;

    if (!_initializedSelection && presetArg != null) {
      _applyPreset(presetArg);
      _selectedPresetId = presetArg.id;
    }

    if (!_initializedSelection && preferredIds.isNotEmpty) {
      _selectedPlayerIds
        ..clear()
        ..addAll(preferredIds);
      _initializedSelection = true;
    }

    final bool isPresetLocked = _selectedPresetId != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newGameTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.gameTitleLabel,
                hintText: l10n.gameTitleHint,
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 24),

            // Preset
            if (presets.isNotEmpty) ...[
              Text(
                l10n.presets,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                value: _selectedPresetId,
                hint: Text(l10n.presets),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-'),
                  ),
                  ...presets.map(
                    (preset) => DropdownMenuItem(
                      value: preset.id,
                      child: Text(_presetTitle(preset, l10n)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPresetId = value;
                    final preset = presets.firstWhere((p) => p.id == value);
                    if (value != null) {
                      _applyPreset(preset);
                    } else {
                      // Déverrouillage: l'utilisateur peut éditer à nouveau
                      _isInverseScore = _isInverseScore;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
            ],

            // Sélection des joueurs
            Text(
              l10n.selectPlayers,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (players.isEmpty)
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: players.map((player) {
                      final isSelected = _selectedPlayerIds.contains(player.id);
                      return FilterChip(
                        label: Text(player.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPlayerIds.add(player.id);
                            } else {
                              _selectedPlayerIds.remove(player.id);
                            }
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Options
            Text(
              l10n.options,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.inverseScoring),
              subtitle: Text(l10n.inverseScoringSubtitle),
              value: _isInverseScore,
              onChanged: isPresetLocked
                  ? null
                  : (val) => setState(() => _isInverseScore = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maxScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.maxScoreLabel,
                      hintText: l10n.maxScoreHint,
                      prefixIcon: const Icon(Icons.flag),
                    ),
                    enabled: !isPresetLocked,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxRoundsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.maxRoundsLabel,
                      hintText: l10n.maxRoundsHint,
                      prefixIcon: const Icon(Icons.repeat),
                    ),
                    enabled: !isPresetLocked,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Bouton Lancer
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726), // Orange
              ),
              onPressed: _selectedPlayerIds.length < 1
                  ? null
                  : () async {
                      final rawTitle = _titleController.text.trim();
                      final dateLabel =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                      final resolvedTitle = rawTitle.isEmpty
                          ? (_selectedPresetId != null
                              ? _presetTitle(
                                  presets.firstWhere(
                                      (p) => p.id == _selectedPresetId),
                                  l10n)
                              : l10n.defaultGameTitle(dateLabel))
                          : rawTitle;
                      final targetScore =
                          int.tryParse(_maxScoreController.text);
                      final targetRounds =
                          int.tryParse(_maxRoundsController.text);

                      final gameId = await provider.createGame(
                        resolvedTitle,
                        _selectedPlayerIds,
                        _isInverseScore,
                        targetScore: targetScore,
                        targetRounds: targetRounds,
                      );
                      if (mounted) {
                        Navigator.pushReplacementNamed(
                          context,
                          '/score',
                          arguments: gameId,
                        );
                      }
                    },
              child: Text(l10n.startGame),
            ),
          ],
        ),
      ),
    );
  }

  void _applyPreset(GamePreset preset) {
    _isInverseScore = preset.isInverseScore;
    _maxScoreController.text =
        preset.targetScore != null ? '${preset.targetScore}' : '';
    _maxRoundsController.text =
        preset.targetRounds != null ? '${preset.targetRounds}' : '';
  }

  String _presetTitle(GamePreset preset, AppLocalizations l10n) {
    return preset.title;
  }
}
