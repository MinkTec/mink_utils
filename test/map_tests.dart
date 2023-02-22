import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:mink_utils/mink_utils.dart';

void main() {
  final linear = List<int>.generate(10, (i) => i);

  group("base", () {
    test("base", () {
      final map = {1: 0};

      expect(map.addIfNew([2], 0), {1:0,2:0});
    });
  });
}
