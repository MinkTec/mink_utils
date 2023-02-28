import 'package:flutter_test/flutter_test.dart';
import 'package:mink_utils/mink_utils.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group("bspline", () {
    test("start", () {
      expect(0, 0);

      final spline = BSpline(2, [Vector2(0, 0), Vector2(1, 1), Vector2(2, -1)]);

      // TODO: write tests

    });
  });
}
