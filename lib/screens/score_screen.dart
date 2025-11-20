import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game.dart';
import '../models/player.dart';

class ScoreScreen extends StatefulWidget {
  final String gameId;

  const ScoreScreen({super.key, required this.gameId});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final ScrollController _tableScrollController = ScrollController();
  final ScrollController _footerScrollController = ScrollController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _tableScrollController.addListener(_syncTableToFooter);
    _footerScrollController.addListener(_syncFooterToTable);
  }

  void _syncTableToFooter() {
    if (_isSyncing) return;
    if (_tableScrollController.offset != _footerScrollController.offset) {
      _isSyncing = true;
      _footerScrollController.jumpTo(_tableScrollController.offset);
      _isSyncing = false;
    }
  }

  void _syncFooterToTable() {
    if (_isSyncing) return;
    if (_footerScrollController.offset != _tableScrollController.offset) {
      _isSyncing = true;
      _tableScrollController.jumpTo(_footerScrollController.offset);
      _isSyncing = false;
    }
  }

  @override
  void dispose() {
    _tableScrollController.removeListener(_syncTableToFooter);
    _footerScrollController.removeListener(_syncFooterToTable);
    _tableScrollController.dispose();
    _footerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final game = provider.getGame(widget.gameId);

    if (game == null) {
      return const Scaffold(body: Center(child: Text('Partie introuvable')));
    }

    final gamePlayers = game.playersIds
        .map((id) => provider.getPlayer(id))
        .where((p) => p != null)
        .cast<Player>()
        .toList();

    if (gamePlayers.isEmpty) {
      return const Scaffold(body: Center(child: Text('Aucun joueur dans cette partie.')));
    }

    final int roundCount = game.scores[gamePlayers.first.id]?.length ?? 0;
    
    // Définition des largeurs
    const double columnWidth = 100.0; 
    const double indexColumnWidth = 50.0;
    final double totalContentWidth = (gamePlayers.length * columnWidth) + indexColumnWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text(game.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => _showRankingDialog(context, game, gamePlayers, provider),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGameInfo(context, game),
          )
        ],
      ),
      body: Column(
        children: [
          // --- TABLEAU (Header + Body) ---
          Expanded(
            child: SingleChildScrollView(
              controller: _tableScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalContentWidth,
                child: Column(
                  children: [
                    // HEADER
                    Container(
                      height: 50,
                      color: const Color(0xFF2C343C),
                      child: Row(
                        children: [
                          SizedBox(width: indexColumnWidth, child: const Center(child: Icon(Icons.grid_3x3, color: Colors.grey, size: 18))),
                          ...gamePlayers.map((p) => SizedBox(
                            width: columnWidth,
                            child: Center(
                              child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ),
                          ))
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    
                    // BODY (ListView Verticale)
                    Expanded(
                      child: ListView.builder(
                        itemCount: roundCount,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                              color: index % 2 == 0 ? Colors.white.withOpacity(0.02) : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: indexColumnWidth,
                                  child: Center(child: Text('${index + 1}', style: TextStyle(color: Colors.grey.shade500))),
                                ),
                                ...gamePlayers.map((player) {
                                  final score = game.scores[player.id]?[index];
                                  return SizedBox(
                                    width: columnWidth,
                                    child: InkWell(
                                      onTap: game.isFinished ? null : () => _editScore(context, provider, game, player.id, index, score, gamePlayers),
                                      child: Center(
                                        child: Text(
                                          score?.toString() ?? '',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- BOUTONS (Fixes et Pleine Largeur) ---
          if (!game.isFinished)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, -1))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddRoundDialog(context, provider, game, gamePlayers),
                    icon: const Icon(Icons.add),
                    label: const Text('AJOUTER UN TOUR'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _confirmFinishGame(context, provider, game, gamePlayers),
                    icon: const Icon(Icons.stop),
                    label: const Text('TERMINER LA PARTIE'),
                  ),
                ],
              ),
            )
          else
             Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text(
                'PARTIE TERMINÉE',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
             ),

          // --- FOOTER (Sticky en bas, scrolle avec le tableau) ---
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1F262D),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, -2))],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _footerScrollController,
              child: SizedBox(
                 width: totalContentWidth,
                 child: Row(
                   children: [
                     SizedBox(width: indexColumnWidth, child: const Center(child: Icon(Icons.functions, color: Colors.grey))),
                     ...gamePlayers.map((player) {
                        final total = provider.getPlayerTotal(widget.gameId, player.id);
                        final bool isMaxReached = game.targetScore != null && total >= game.targetScore!;
                        return SizedBox(
                          width: columnWidth,
                          height: 60,
                          child: Center(
                            child: Text(
                              '$total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isMaxReached ? Colors.redAccent : const Color(0xFF66BB6A), 
                              ),
                            ),
                          ),
                        );
                     })
                   ],
                 ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRoundDialog(BuildContext context, GameProvider provider, Game game, List<Player> players) {
    final Map<String, TextEditingController> controllers = {};
    for (var player in players) {
      controllers[player.id] = TextEditingController();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau Tour'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: players.map((player) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: controllers[player.id],
                  decoration: InputDecoration(
                    labelText: player.name,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  textInputAction: TextInputAction.next,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final Map<String, int?> newScores = {};
              controllers.forEach((playerId, controller) {
                if (controller.text.isNotEmpty) {
                  newScores[playerId] = int.tryParse(controller.text);
                }
              });
              provider.addRound(game.id, newScores);
              Navigator.pop(ctx);
              _checkEndGameConditions(context, game, players, provider);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _editScore(BuildContext context, GameProvider provider, Game game, String playerId, int roundIndex, int? currentScore, List<Player> players) {
    final controller = TextEditingController(text: currentScore?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le score'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          autofocus: true,
          onSubmitted: (_) => _submitEdit(context, ctx, provider, game, playerId, roundIndex, controller.text, players),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => _submitEdit(context, ctx, provider, game, playerId, roundIndex, controller.text, players),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _submitEdit(BuildContext parentContext, BuildContext dialogContext, GameProvider provider, Game game, String playerId, int roundIndex, String text, List<Player> players) {
    if (text.isEmpty) {
      provider.updateScore(game.id, playerId, roundIndex, null);
    } else {
      final val = int.tryParse(text);
      if (val != null) {
        provider.updateScore(game.id, playerId, roundIndex, val);
      }
    }
    Navigator.pop(dialogContext);
    _checkEndGameConditions(parentContext, game, players, provider);
  }

  void _checkEndGameConditions(BuildContext context, Game game, List<Player> players, GameProvider provider) {
    if (game.targetRounds != null) {
      final currentRounds = game.scores[players.first.id]?.length ?? 0;
      if (currentRounds >= game.targetRounds!) {
        // On termine automatiquement la partie si max tours atteint
        provider.finishGame(game.id);
        _showRankingDialog(context, game, players, provider, isFinal: true, isAutomatic: true);
        return;
      }
    }
    if (game.targetScore != null) {
      bool maxReached = false;
      for (var p in players) {
        if (provider.getPlayerTotal(game.id, p.id) >= game.targetScore!) {
          maxReached = true;
          break;
        }
      }
      if (maxReached) {
         // On termine automatiquement la partie si max score atteint
         provider.finishGame(game.id);
        _showRankingDialog(context, game, players, provider, isFinal: true, isAutomatic: true);
      }
    }
  }

  void _confirmFinishGame(BuildContext context, GameProvider provider, Game game, List<Player> players) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminer la partie ?'),
        content: const Text('Cela verrouillera les scores. Voulez-vous continuer ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.finishGame(game.id);
              Navigator.pop(ctx);
              _showRankingDialog(context, game, players, provider, isFinal: true);
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  void _showRankingDialog(BuildContext context, Game game, List<Player> players, GameProvider provider, {bool isFinal = false, bool isAutomatic = false}) {
    final Map<String, int> totals = {};
    for (var p in players) {
      totals[p.id] = provider.getPlayerTotal(game.id, p.id);
    }
    final sortedPlayers = List<Player>.from(players);
    sortedPlayers.sort((a, b) {
      final scoreA = totals[a.id]!;
      final scoreB = totals[b.id]!;
      return game.isInverseScore ? scoreA.compareTo(scoreB) : scoreB.compareTo(scoreA);
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.all(10), // Pop up plus large
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Text(isFinal ? 'Résultats Finaux' : 'Classement'),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAutomatic && !isFinal)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text('Une limite de la partie a été atteinte !', style: TextStyle(color: Colors.orangeAccent, fontStyle: FontStyle.italic)),
                  ),
                ...sortedPlayers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  final score = totals[player.id]!;
                  Color? rankColor;
                  if (index == 0) rankColor = Colors.amber;
                  else if (index == 1) rankColor = Colors.grey.shade400;
                  else if (index == 2) rankColor = Colors.brown.shade300;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: rankColor != null ? Border.all(color: rankColor, width: 2) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40, alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: rankColor ?? Colors.transparent),
                          child: Text('#${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: rankColor != null ? Colors.black : Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(player.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        Text('$score pts', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (isFinal) Navigator.pop(context);
            },
            child: Text(isFinal ? 'Quitter' : 'OK'),
          ),
          if (isFinal)
             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Voir la grille')),
        ],
      ),
    );
  }

  void _showGameInfo(BuildContext context, Game game) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text('Date: ${game.date.toString().split('.')[0]}'),
            Text('Mode: ${game.isInverseScore ? "Score Inversé (Golf)" : "Standard"}'),
            if (game.targetScore != null) Text('Score Max: ${game.targetScore}'),
            if (game.targetRounds != null) Text('Tours Max: ${game.targetRounds}'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
