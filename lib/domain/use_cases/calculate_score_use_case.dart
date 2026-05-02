import 'dart:math' as math;
import 'package:expressions/expressions.dart';
import '../../data/models/game_preset.dart';

class CalculateScoreUseCase {
  int calculateDynamic(
    String formula,
    Map<String, int> inputs, {
    int roundIndex = 0,
    List<ScoringRule>? rules,
  }) {
    try {
      final context = <String, dynamic>{
        ...inputs,
        'round': roundIndex + 1,
        'index': roundIndex,
        'abs': (num x) => x.abs(),
        'min': (num a, num b) => math.min(a, b),
        'max': (num a, num b) => math.max(a, b),
        'pow': (num x, num y) => math.pow(x, y),
        'sqrt': (num x) => math.sqrt(x),
        'ceil': (num x) => x.ceil(),
        'floor': (num x) => x.floor(),
        'rnd': (num x) => x.round(),
        'sign': (num x) => x.sign,
        'truncate': (num x) => x.truncate(),
        'clamp': (num x, num min, num max) => x.clamp(min, max),
        'pi': math.pi,
        'e': math.e,
      };

      final evaluator = const ExpressionEvaluator();

      if (rules != null && rules.isNotEmpty) {
        return _evaluateRules(rules, evaluator, context);
      }

      if (formula.isEmpty) return 0;
      final result = evaluator.eval(Expression.parse(formula), context);
      return result is num ? result.round() : 0;
    } catch (_) {
      return 0;
    }
  }

  int _evaluateRules(
    List<ScoringRule> rules,
    ExpressionEvaluator evaluator,
    Map<String, dynamic> context,
  ) {
    for (final rule in rules) {
      try {
        final conditionResult =
            evaluator.eval(Expression.parse(rule.condition), context);
        if (conditionResult == true) {
          if (rule.rules != null && rule.rules!.isNotEmpty) {
            return _evaluateRules(rule.rules!, evaluator, context);
          }
          if (rule.formula != null && rule.formula!.isNotEmpty) {
            final result =
                evaluator.eval(Expression.parse(rule.formula!), context);
            return result is num ? result.round() : 0;
          }
          return 0;
        }
      } catch (_) {
        continue;
      }
    }
    return 0;
  }

  int calculateSkullKing(int bid, int tricks, int roundIndex) {
    if (bid == tricks) {
      return bid == 0 ? (roundIndex + 1) * 10 : bid * 20;
    } else {
      return bid == 0 ? (roundIndex + 1) * -10 : (tricks - bid).abs() * -10;
    }
  }
}
