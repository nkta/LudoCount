import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/domain/use_cases/calculate_score_use_case.dart';

void main() {
  late CalculateScoreUseCase calculator;

  setUp(() {
    calculator = CalculateScoreUseCase();
  });

  group('Math Expressions Extended', () {
    test('Should support abs function', () {
      expect(calculator.calculateDynamic('abs(-10)', {}), 10);
      expect(calculator.calculateDynamic('abs(10)', {}), 10);
      expect(calculator.calculateDynamic('abs(0)', {}), 0);
      expect(calculator.calculateDynamic('abs(-5.5)', {}), 6);
    });

    test('Should support parentheses', () {
      expect(calculator.calculateDynamic('(2 + 3) * 4', {}), 20);
      expect(calculator.calculateDynamic('2 + (3 * 4)', {}), 14);
      expect(calculator.calculateDynamic('((2 + 3) * 2) / 2', {}), 5);
    });

    test('Should support complex expressions with abs and parentheses', () {
      expect(calculator.calculateDynamic('abs((5 - 10) * 2)', {}), 10);
      expect(calculator.calculateDynamic('(abs(-5) + 5) * 2', {}), 20);
    });
  });
}
