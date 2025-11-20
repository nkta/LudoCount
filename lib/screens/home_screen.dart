import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LudoCount')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            _buildMenuButton(
              context,
              label: 'CONTINUER',
              color: const Color(0xFF66BB6A),
              onPressed: () => _continueLastGame(context),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              label: 'NOUVELLE PARTIE',
              color: const Color(0xFFFFA726),
              onPressed: () => Navigator.pushNamed(context, '/config'),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              label: 'HISTORIQUE',
              color: const Color(0xFFEF5350),
              onPressed: () => Navigator.pushNamed(context, '/history'),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              label: 'JOUEURS',
              color: const Color(0xFF42A5F5),
              onPressed: () => Navigator.pushNamed(context, '/players'),
            ),
            const Spacer(),
          ],
        ),
      ),
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
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _continueLastGame(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final lastGame = gameProvider.getLastGame();

    if (lastGame != null) {
      Navigator.pushNamed(context, '/score', arguments: lastGame.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune partie récente trouvée.')),
      );
    }
  }
}

