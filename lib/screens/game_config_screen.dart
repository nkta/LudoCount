import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

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
    final provider = Provider.of<GameProvider>(context);
    final players = provider.players;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Partie')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de la partie (Optionnel)',
                hintText: 'Soirée Jeux...',
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 24),

            // Sélection des joueurs
            const Text(
              'Sélectionnez les joueurs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (players.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Aucun joueur disponible.'),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/players'),
                        child: const Text('Créer des joueurs'),
                      )
                    ],
                  ),
                ),
              )
            else
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

            const SizedBox(height: 24),

            // Options
            const Text(
              'Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Marquage inversé (le plus bas gagne)'),
              subtitle: const Text('Ex: Golf, Skyjo...'),
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
                    decoration: const InputDecoration(
                      labelText: 'Score Max',
                      hintText: 'Ex: 500',
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxRoundsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tours Max',
                      hintText: 'Ex: 10',
                      prefixIcon: Icon(Icons.repeat),
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
                      final targetScore = int.tryParse(_maxScoreController.text);
                      final targetRounds = int.tryParse(_maxRoundsController.text);
                      
                      final gameId = await provider.createGame(
                        _titleController.text.trim(),
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
              child: const Text('LANCER LA PARTIE'),
            ),
          ],
        ),
      ),
    );
  }
}
