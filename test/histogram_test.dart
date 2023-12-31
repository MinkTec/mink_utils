import 'dart:math' as math;
import 'package:mink_utils/basic_utils.dart';
import 'package:mink_utils/histogram_utils.dart';
import 'package:test/test.dart';

void main() {
  final linear = List<int>.generate(10, (i) => i);

  group("1d", () {
    // test("basic", () {
    //   expect(linear.cluster(10).baskets.length, 10);
    //   expect(linear.cluster(10).baskets.every((e) => e == 1), true);
    // });
  });

  group("nd", () {
    test("stupid", () {
      List<double> random(int n) {
        final r = math.Random();
        return List<double>.generate(n, (i) => math.Random().nextDouble());
      }

      final cd = linear.cluster(5);

      final cd3 = ClusteredData(data: [random(10000)], n: 20);
    });
    test("basic", () {
      int edgeLength = 3;
      int dim = 2;

      final bilinear = List<List<int>>.generate(
          dim, (i) => List<int>.generate(100, (j) => j));
      final ClusteredData cluster = bilinear.cluster(edgeLength);
      expect(cluster.baskets.length, math.pow(edgeLength, dim));
    });

    test("advanced", () {
      final list1 = List<int>.generate(10, id);
      final list2 = List<int>.generate(10, (i) => 10 + i);

      final ClusteredData cluster = [list1, list2].cluster(3);
      expect(cluster.baskets.length, 9);
    });
  });
}
