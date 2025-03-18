
import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:test/test.dart';

void main() {
  group('MathUtils', () {
    test('distance', () {
      expect(distance(0, 0, 3, 4), 5);
    });

    test('binomial', () {
      expect(binomial(5, 2), 10);
    });

    test('smallGauss', () {
      expect(smallGauss(5), 15);
    });
  });
}