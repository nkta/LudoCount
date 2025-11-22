import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Assurez-vous d'ajouter intl au pubspec
import '../providers/game_provider.dart';
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).toLanguageTag();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: Consumer<GameProvider>(
        builder: (context, provider, child) {
          final games = provider.games; // Déjà trié par date dans le provider

          if (games.isEmpty) {
            return Center(
              child: Text(
                l10n.noGamesRecorded,
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final game = games[index];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    game.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd(localeCode).add_Hm().format(game.date),
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.playersCount(game.playersIds.length),
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/score', arguments: game.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
