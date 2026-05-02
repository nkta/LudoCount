import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:ludocount/ui/features/dice/view_models/dice_view_model.dart';

class DiceRollDialog extends StatefulWidget {
  const DiceRollDialog({super.key});

  @override
  State<DiceRollDialog> createState() => _DiceRollDialogState();
}

class _DiceRollDialogState extends State<DiceRollDialog>
    with SingleTickerProviderStateMixin {
  late int _numberOfDice;
  List<int> _results = [];
  bool _isRolling = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _numberOfDice = context.read<DiceViewModel>().diceCount;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isRolling = false;
            _generateResults();
          });
          _controller.reset();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rollDice() {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    _controller.forward();
  }

  void _generateResults() {
    final random = Random();
    _results = List.generate(_numberOfDice, (_) => random.nextInt(6) + 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.diceRoller),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: _numberOfDice > 1
                      ? () {
                          setState(() {
                            _numberOfDice--;
                            _results.clear();
                          });
                          context
                              .read<DiceViewModel>()
                              .setCount(_numberOfDice);
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                Text('$_numberOfDice',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                IconButton.filledTonal(
                  onPressed: _numberOfDice < 10
                      ? () {
                          setState(() {
                            _numberOfDice++;
                            _results.clear();
                          });
                          context
                              .read<DiceViewModel>()
                              .setCount(_numberOfDice);
                        }
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Center(
                child: _isRolling || _results.isNotEmpty
                    ? AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: List.generate(_numberOfDice, (index) {
                              final value = _isRolling
                                  ? Random().nextInt(6) + 1
                                  : _results[index];
                              final angle = _isRolling
                                  ? (Random().nextDouble() - 0.5) * 0.5
                                  : 0.0;
                              return Transform.rotate(
                                  angle: angle, child: _buildDie(value));
                            }),
                          );
                        },
                      )
                    : Text(l10n.rollDice,
                        style: const TextStyle(color: Colors.grey)),
              ),
            ),
            if (!_isRolling && _results.isNotEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${l10n.total}: ${_results.fold(0, (sum, val) => sum + val)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton.icon(
          onPressed: _isRolling ? null : _rollDice,
          icon: const Icon(Icons.casino),
          label: Text(l10n.rollDice.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildDie(int value) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(1, 2))
        ],
      ),
      child: Center(child: _DieFace(value: value, size: 8)),
    );
  }
}

class _DieFace extends StatelessWidget {
  final int value;
  final double size;
  const _DieFace({required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    Widget dot() => Container(
          width: size,
          height: size,
          decoration:
              const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        );

    switch (value) {
      case 1:
        return dot();
      case 2:
        return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), const SizedBox(width: 8)]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [const SizedBox(width: 8), dot()]),
        ]);
      case 3:
        return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), const SizedBox(width: 8)]),
          dot(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [const SizedBox(width: 8), dot()]),
        ]);
      case 4:
        return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), dot()]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), dot()]),
        ]);
      case 5:
        return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), dot()]),
          dot(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), dot()]),
        ]);
      case 6:
        return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), dot()]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), dot()]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [dot(), dot()]),
        ]);
      default:
        return Text('$value',
            style: const TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold));
    }
  }
}
