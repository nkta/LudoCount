import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../l10n/app_localizations.dart';

class PlayerListScreen extends StatelessWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.playerListTitle)),
      body: Consumer<GameProvider>(
        builder: (context, provider, child) {
          final players = provider.players;
          final hasDefaults = players.any((p) => p.isDefault);
          if (players.isEmpty) {
            return Center(child: Text(l10n.noSavedPlayers));
          }
          return Column(
            children: [
              if (hasDefaults)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: OutlinedButton.icon(
                    onPressed: provider.clearDefaultPlayers,
                    icon: const Icon(Icons.clear_all),
                    label: Text(l10n.clearDefaults),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(player.name[0].toUpperCase()),
                        ),
                        title: Text(player.name),
                        subtitle: player.isDefault
                            ? Text(
                                l10n.defaultBadge,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: player.isDefault,
                              onChanged: (value) {
                                provider.setPlayerDefault(
                                    player.id, value ?? false);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () =>
                                  _confirmDelete(context, provider, player),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _showAddPlayerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool defaultChecked = false;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newPlayer),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: l10n.name),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: defaultChecked,
                onChanged: (val) =>
                    setState(() => defaultChecked = val ?? false),
                title: Text(l10n.markAsDefault),
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
              if (controller.text.trim().isNotEmpty) {
                Provider.of<GameProvider>(context, listen: false).addPlayer(
                    controller.text.trim(),
                    isDefault: defaultChecked);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, GameProvider provider, Player player) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePlayerTitle),
        content: Text(l10n.deletePlayerMessage(player.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.deletePlayer(player.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
