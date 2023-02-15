import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:mink_utils/histogram_utils.dart';

void main() {
  final linear = List<int>.generate(10, (i) => i);

  group("1d", () {
    test("basic", () {
      expect(linear.cluster(10).baskets.length, 10);
      expect(linear.cluster(10).baskets.every((e) => e == 1), true);
    });
  });

  group("nd", () {
    test("basic", () {
      List<double> random(int n) {
        final r = math.Random();
        return List<double>.generate(n, (i) => math.Random().nextDouble());
      }

      final cd = linear.cluster(5);

      final cd3 = ClusteredData(data: [random(10000)], n: 20);


    });
  });
}
