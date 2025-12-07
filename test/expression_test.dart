import 'package:flutter_test/flutter_test.dart';
import 'package:expressions/expressions.dart';

void main() {
  test('Should support logical operators && and ||', () {
    final evaluator = const ExpressionEvaluator();
    final context = {'a': 1, 'b': 2, 'c': 3};

    // Test &&
    var expr = Expression.parse('a == 1 && b == 2');
    expect(evaluator.eval(expr, context), isTrue);

    expr = Expression.parse('a == 1 && b == 3');
    expect(evaluator.eval(expr, context), isFalse);

    // Test ||
    expr = Expression.parse('a == 1 || b == 3');
    expect(evaluator.eval(expr, context), isTrue);

    expr = Expression.parse('a == 5 || b == 3');
    expect(evaluator.eval(expr, context), isFalse);

    // Test complex combination
    expr = Expression.parse('(a == 1 && b == 2) || c == 5');
    expect(evaluator.eval(expr, context), isTrue);
  });
}
