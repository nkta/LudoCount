import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/domain/use_cases/calculate_score_use_case.dart';
import 'package:ludocount/data/models/game_preset.dart';

void main() {
  late CalculateScoreUseCase calculator;

  setUp(() {
    calculator = CalculateScoreUseCase();
  });

  group('Conditional Scoring Rules', () {
    test('Should evaluate first matching rule', () {
      final rules = [
        ScoringRule(condition: 'bid == 0', formula: '10'),
        ScoringRule(condition: 'bid == tricks', formula: '20'),
        ScoringRule(condition: 'true', formula: '-10'),
      ];

      expect(calculator.calculateDynamic('', {'bid': 0, 'tricks': 0}, rules: rules), 10);
      expect(calculator.calculateDynamic('', {'bid': 2, 'tricks': 2}, rules: rules), 20);
      expect(calculator.calculateDynamic('', {'bid': 2, 'tricks': 1}, rules: rules), -10);
    });

    test('Should return 0 if no rule matches', () {
      final rules = [
        ScoringRule(condition: 'bid == 100', formula: '1000'),
      ];

      expect(calculator.calculateDynamic('', {'bid': 1, 'tricks': 1}, rules: rules), 0);
    });

    test('Should handle complex expressions in conditions and formulas', () {
      final rules = [
        ScoringRule(condition: 'bid == 0 && tricks > 0', formula: 'tricks * -10'),
        ScoringRule(condition: 'bid == 0', formula: '50'),
      ];

      expect(calculator.calculateDynamic('', {'bid': 0, 'tricks': 2}, rules: rules), -20);
      expect(calculator.calculateDynamic('', {'bid': 0, 'tricks': 0}, rules: rules), 50);
    });

    test('Should fallback to formula if rules are null or empty', () {
      expect(calculator.calculateDynamic('bid * 10', {'bid': 5}, rules: null), 50);
      expect(calculator.calculateDynamic('bid * 10', {'bid': 5}, rules: []), 50);
    });
  });
}
