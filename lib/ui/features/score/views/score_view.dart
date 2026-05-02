import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ludocount/data/models/game.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/models/player.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:ludocount/ui/features/dice/views/dice_roll_dialog.dart';
import 'package:ludocount/ui/features/score/view_models/score_view_model.dart';

class ScoreView extends StatefulWidget {
  const ScoreView({super.key});

  @override
  State<ScoreView> createState() => _ScoreViewState();
}

class _ScoreViewState extends State<ScoreView> {
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
    final vm = context.watch<ScoreViewModel>();
    final l10n = AppLocalizations.of(context);
    final game = vm.game;

    if (game == null) {
      return Scaffold(body: Center(child: Text(l10n.gameNotFound)));
    }

    final gamePlayers = vm.players;
    if (gamePlayers.isEmpty) {
      return Scaffold(body: Center(child: Text(l10n.noPlayersInGame)));
    }

    final int roundCount =
        game.scores[gamePlayers.first.id]?.length ?? 0;
    const double columnWidth = 100.0;
    const double indexColumnWidth = 50.0;
    final double totalContentWidth =
        (gamePlayers.length * columnWidth) + indexColumnWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text(game.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino),
            onPressed: () => showDialog(
                context: context,
                builder: (_) => const DiceRollDialog()),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () =>
                _showRankingDialog(context, vm, game, gamePlayers),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGameInfo(context, game),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _tableScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalContentWidth,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        color: const Color(0xFF2C343C),
                        child: Row(
                          children: [
                            SizedBox(
                                width: indexColumnWidth,
                                child: const Center(
                                    child: Icon(Icons.grid_3x3,
                                        color: Colors.grey, size: 18))),
                            ...gamePlayers.map((p) => SizedBox(
                                  width: columnWidth,
                                  child: Center(
                                    child: Text(p.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: roundCount,
                          itemBuilder: (context, index) {
                            final label = game.roundLabels != null &&
                                    index < game.roundLabels!.length
                                ? game.roundLabels![index]
                                : '${index + 1}';
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white
                                            .withOpacity(0.05))),
                                color: index % 2 == 0
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: indexColumnWidth,
                                    child: Center(
                                        child: Text(label,
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12))),
                                  ),
                                  ...gamePlayers.map((player) {
                                    final score =
                                        game.scores[player.id]?[index];
                                    return SizedBox(
                                      width: columnWidth,
                                      child: InkWell(
                                        onTap: () {
                                          if (!game.isFinished ||
                                              game.fields != null) {
                                            _editScore(context, vm, game,
                                                player.id, index, score,
                                                gamePlayers);
                                          }
                                        },
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  score != null
                                                      ? '$score'
                                                      : '-',
                                                  style: const TextStyle(
                                                      fontSize: 16)),
                                              if (game.roundData != null &&
                                                  game.roundData![player.id] !=
                                                      null &&
                                                  index <
                                                      game.roundData![player
                                                          .id]!.length &&
                                                  game.roundData![player
                                                      .id]![index] !=
                                                      null &&
                                                  game.fields == null)
                                                Builder(
                                                  builder: (_) {
                                                    final data = game
                                                        .roundData![player
                                                        .id]![index]!;
                                                    return Text(
                                                      data.entries
                                                          .map((e) =>
                                                              '${e.value}')
                                                          .join(' / '),
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey),
                                                    );
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
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

            if (!game.isFinished)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 4,
                        color: Colors.black12,
                        offset: Offset(0, -1))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (game.roundLabels == null) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          if (game.fields != null) {
                            vm.addRound();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Nouveau tour ajouté. Cliquez sur une case pour saisir les détails.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            _showAddRoundDialog(
                                context, vm, game, gamePlayers);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addRound),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _confirmFinishGame(
                          context, vm, game, gamePlayers),
                      icon: const Icon(Icons.stop),
                      label: Text(l10n.finishGame),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Text(l10n.gameFinished,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
              ),

            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1F262D),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 4,
                      color: Colors.black26,
                      offset: Offset(0, -2))
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _footerScrollController,
                child: SizedBox(
                  width: totalContentWidth,
                  child: Row(
                    children: [
                      SizedBox(
                          width: indexColumnWidth,
                          child: const Center(
                              child: Icon(Icons.functions,
                                  color: Colors.grey))),
                      ...gamePlayers.map((player) {
                        final total = vm.getTotal(player.id);
                        final isMaxReached = game.targetScore != null &&
                            total >= game.targetScore!;
                        return SizedBox(
                          width: columnWidth,
                          height: 60,
                          child: Center(
                            child: Text(
                              '$total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isMaxReached
                                    ? Colors.redAccent
                                    : const Color(0xFF66BB6A),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoundDialog(
    BuildContext context,
    ScoreViewModel vm,
    Game game,
    List<Player> players,
  ) {
    final l10n = AppLocalizations.of(context);
    final Map<String, TextEditingController> controllers = {
      for (final p in players) p.id: TextEditingController(),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newRound),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  textInputAction: TextInputAction.next,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final Map<String, int?> newScores = {};
              controllers.forEach((pId, ctrl) {
                if (ctrl.text.isNotEmpty) {
                  newScores[pId] = int.tryParse(ctrl.text);
                }
              });
              vm.addRound(newScores);
              Navigator.pop(ctx);
              _checkEndGameConditions(context, game, players, vm);
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _showDynamicScoreDialog(
    BuildContext context,
    ScoreViewModel vm,
    Game game,
    String playerId,
    int roundIndex,
    List<Player> players,
  ) {
    final l10n = AppLocalizations.of(context);
    final fields = game.fields!;
    Map<String, int>? existingData;
    if (game.roundData != null &&
        game.roundData!.containsKey(playerId) &&
        roundIndex < game.roundData![playerId]!.length) {
      existingData = game.roundData![playerId]![roundIndex];
    }

    final controllers = {
      for (final f in fields)
        f.key: TextEditingController(
            text: existingData?[f.key]?.toString() ?? ''),
    };

    final title = (game.roundLabels != null &&
            roundIndex < game.roundLabels!.length)
        ? game.roundLabels![roundIndex]
        : '${l10n.round} ${roundIndex + 1}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields.map((field) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: controllers[field.key],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: field.label,
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final inputs = <String, int>{};
              bool allValid = true;
              for (final field in fields) {
                final text = controllers[field.key]!.text;
                final val = text.isEmpty ? 0 : int.tryParse(text);
                if (val == null) {
                  allValid = false;
                  break;
                }
                inputs[field.key] = val;
              }
              inputs['playerCount'] = players.length;

              if (allValid) {
                final score = vm.calculateScore(
                  game.scoreFormula ?? '',
                  inputs,
                  roundIndex: roundIndex,
                  rules: game.scoringRules,
                );
                vm.updateRoundData(playerId, roundIndex, inputs, score);
                Navigator.pop(ctx);
                _checkEndGameConditions(context, game, players, vm);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content:
                        Text('Veuillez entrer des nombres valides')));
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _editScore(
    BuildContext context,
    ScoreViewModel vm,
    Game game,
    String playerId,
    int roundIndex,
    int? currentScore,
    List<Player> players,
  ) {
    final l10n = AppLocalizations.of(context);

    if (game.fields != null &&
        (game.scoreFormula != null ||
            (game.scoringRules != null &&
                game.scoringRules!.isNotEmpty))) {
      _showDynamicScoreDialog(
          context, vm, game, playerId, roundIndex, players);
      return;
    }

    if (game.type == GameType.skullKing) {
      _showSkullKingDialog(
          context, vm, game, playerId, roundIndex, players);
      return;
    }

    final controller = TextEditingController(
        text: currentScore != null ? currentScore.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editScore),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(signed: true),
          autofocus: true,
          onSubmitted: (_) => _submitEdit(
              context, ctx, vm, game, playerId, roundIndex,
              controller.text, players),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => _submitEdit(context, ctx, vm, game, playerId,
                roundIndex, controller.text, players),
            child: Text(l10n.validate),
          ),
        ],
      ),
    );
  }

  void _showSkullKingDialog(
    BuildContext context,
    ScoreViewModel vm,
    Game game,
    String playerId,
    int roundIndex,
    List<Player> players,
  ) {
    final bidController = TextEditingController();
    final tricksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Skull King - Manche ${roundIndex + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bidController,
              decoration:
                  const InputDecoration(labelText: 'Pari (Bid)'),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tricksController,
              decoration: const InputDecoration(
                  labelText: 'Plis réalisés (Tricks)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final bid = int.tryParse(bidController.text);
              final tricks = int.tryParse(tricksController.text);
              if (bid != null && tricks != null) {
                final score =
                    vm.calculateSkullKing(bid, tricks, roundIndex);
                vm.updateScore(playerId, roundIndex, score);
              }
              Navigator.pop(ctx);
              _checkEndGameConditions(context, game, players, vm);
            },
            child: const Text('Calculer'),
          ),
        ],
      ),
    );
  }

  void _submitEdit(
    BuildContext parentCtx,
    BuildContext dialogCtx,
    ScoreViewModel vm,
    Game game,
    String playerId,
    int roundIndex,
    String text,
    List<Player> players,
  ) {
    if (text.isEmpty) {
      vm.updateScore(playerId, roundIndex, null);
    } else {
      final val = int.tryParse(text);
      if (val != null) vm.updateScore(playerId, roundIndex, val);
    }
    Navigator.pop(dialogCtx);
    _checkEndGameConditions(parentCtx, game, players, vm);
  }

  void _checkEndGameConditions(
    BuildContext context,
    Game game,
    List<Player> players,
    ScoreViewModel vm,
  ) {
    if (game.fields != null) return;

    if (game.targetRounds != null && game.roundLabels == null) {
      final currentRounds =
          game.scores[players.first.id]?.length ?? 0;
      if (currentRounds >= game.targetRounds!) {
        vm.finishGame();
        _showRankingDialog(context, vm, game, players,
            isFinal: true, isAutomatic: true);
        return;
      }
    }
    if (game.targetScore != null) {
      final maxReached = players.any(
          (p) => vm.getTotal(p.id) >= game.targetScore!);
      if (maxReached) {
        vm.finishGame();
        _showRankingDialog(context, vm, game, players,
            isFinal: true, isAutomatic: true);
      }
    }
  }

  void _confirmFinishGame(
    BuildContext context,
    ScoreViewModel vm,
    Game game,
    List<Player> players,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.finishGameTitle),
        content: Text(l10n.finishGameMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              vm.finishGame();
              Navigator.pop(ctx);
              _showRankingDialog(context, vm, game, players,
                  isFinal: true);
            },
            child: Text(l10n.finish),
          ),
        ],
      ),
    );
  }

  void _showRankingDialog(
    BuildContext context,
    ScoreViewModel vm,
    Game game,
    List<Player> players, {
    bool isFinal = false,
    bool isAutomatic = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final totals = {for (final p in players) p.id: vm.getTotal(p.id)};
    final sorted = List<Player>.from(players)
      ..sort((a, b) {
        final scoreA = totals[a.id]!;
        final scoreB = totals[b.id]!;
        return game.isInverseScore
            ? scoreA.compareTo(scoreB)
            : scoreB.compareTo(scoreA);
      });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.all(10),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Text(isFinal ? l10n.finalResults : l10n.ranking),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAutomatic)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(l10n.autoLimitReached,
                        style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontStyle: FontStyle.italic)),
                  ),
                ...sorted.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final player = entry.value;
                  final score = totals[player.id]!;
                  Color? rankColor;
                  if (idx == 0) rankColor = Colors.amber;
                  if (idx == 1) rankColor = Colors.grey.shade400;
                  if (idx == 2) rankColor = Colors.brown.shade300;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: rankColor != null
                          ? Border.all(color: rankColor, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: rankColor ?? Colors.transparent),
                          child: Text('#${idx + 1}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rankColor != null
                                      ? Colors.black
                                      : Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(player.name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),
                        Text('$score ${l10n.pointsSuffix}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
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
            child: Text(isFinal ? l10n.leave : l10n.ok),
          ),
          if (isFinal)
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.viewGrid)),
        ],
      ),
    );
  }

  void _showGameInfo(BuildContext context, Game game) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game.title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
                '${l10n.dateLabel} ${game.date.toString().split('.')[0]}'),
            Text(
                '${l10n.modeLabel} ${game.isInverseScore ? l10n.modeInverse : l10n.modeStandard}'),
            if (game.targetScore != null)
              Text('${l10n.maxScoreLabelInfo} ${game.targetScore}'),
            if (game.targetRounds != null)
              Text('${l10n.maxRoundsLabelInfo} ${game.targetRounds}'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
