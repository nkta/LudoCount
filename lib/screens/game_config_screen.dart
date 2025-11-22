import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../l10n/app_localizations.dart';

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
    final preferredIds =
        defaultIds.isNotEmpty ? defaultIds : provider.getPreferredPlayerIds();
    final bool usesDefaultPreset = defaultIds.isNotEmpty;

    if (!_initializedSelection && preferredIds.isNotEmpty) {
      _selectedPlayerIds
        ..clear()
        ..addAll(preferredIds);
      _initializedSelection = true;
    }

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
              onChanged: (val) => setState(() => _isInverseScore = val),
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
                          ? l10n.defaultGameTitle(dateLabel)
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
}
