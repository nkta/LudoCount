import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/domain/use_cases/calculate_score_use_case.dart';

void main() {
  late CalculateScoreUseCase calculator;

  setUp(() {
    calculator = CalculateScoreUseCase();
  });

  group('Math Functions', () {
    test('Should support pow', () {
      expect(calculator.calculateDynamic('pow(2, 3)', {}), 8);
      expect(calculator.calculateDynamic('pow(5, 2)', {}), 25);
    });

    test('Should support sqrt', () {
      expect(calculator.calculateDynamic('sqrt(16)', {}), 4);
      expect(calculator.calculateDynamic('sqrt(25)', {}), 5);
    });

    test('Should support rounding functions', () {
      expect(calculator.calculateDynamic('ceil(4.1)', {}), 5);
      expect(calculator.calculateDynamic('floor(4.9)', {}), 4);
      expect(calculator.calculateDynamic('rnd(4.5)', {}), 5);
      expect(calculator.calculateDynamic('rnd(4.4)', {}), 4);
      expect(calculator.calculateDynamic('truncate(4.9)', {}), 4);
    });

    test('Should support sign', () {
      expect(calculator.calculateDynamic('sign(-5)', {}), -1);
      expect(calculator.calculateDynamic('sign(5)', {}), 1);
      expect(calculator.calculateDynamic('sign(0)', {}), 0);
    });

    test('Should support clamp', () {
      expect(calculator.calculateDynamic('clamp(10, 0, 5)', {}), 5);
      expect(calculator.calculateDynamic('clamp(-5, 0, 5)', {}), 0);
      expect(calculator.calculateDynamic('clamp(3, 0, 5)', {}), 3);
    });

    test('Should support constants', () {
      expect(calculator.calculateDynamic('floor(pi)', {}), 3);
      expect(calculator.calculateDynamic('floor(e)', {}), 2);
    });

    test('Should support abs (existing)', () {
      expect(calculator.calculateDynamic('abs(-10)', {}), 10);
    });

    test('Should support min/max (existing)', () {
      expect(calculator.calculateDynamic('min(10, 5)', {}), 5);
      expect(calculator.calculateDynamic('max(10, 5)', {}), 10);
    });
  });
}
