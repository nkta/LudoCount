import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/domain/use_cases/calculate_score_use_case.dart';

void main() {
  group('Skull King Scoring Tests', () {
    late CalculateScoreUseCase calculator;

    setUp(() {
      calculator = CalculateScoreUseCase();
    });

    test('Bid correct (non-zero)', () {
      expect(calculator.calculateSkullKing(1, 1, 0), 20);
      expect(calculator.calculateSkullKing(3, 3, 4), 60);
    });

    test('Bid correct (zero) - Round 1', () {
      expect(calculator.calculateSkullKing(0, 0, 0), 10);
    });

    test('Bid correct (zero) - Round 5', () {
      expect(calculator.calculateSkullKing(0, 0, 4), 50);
    });

    test('Bid incorrect (non-zero bid)', () {
      expect(calculator.calculateSkullKing(1, 0, 0), -10);
      expect(calculator.calculateSkullKing(1, 2, 0), -10);
      expect(calculator.calculateSkullKing(2, 0, 0), -20);
      expect(calculator.calculateSkullKing(2, 5, 0), -30);
    });

    test('Bid incorrect (zero bid) - Round 1', () {
      expect(calculator.calculateSkullKing(0, 1, 0), -10);
    });

    test('Bid incorrect (zero bid) - Round 5', () {
      expect(calculator.calculateSkullKing(0, 1, 4), -50);
    });
  });
}
