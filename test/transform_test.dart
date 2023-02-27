// ignore_for_file: unrelated_type_equality_checks

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mink_utils/mink_utils.dart';

void main() {
  final d1 = <double>[0, 0, 1, 1];
  final d2 = <double>[0, -1, 1, 1];
  final l1 = Float32List.fromList(d1);
  final l2 = Float32List.fromList(d2);
  final curve = RawCurve.copy(l1);
  final curve2 = RawCurve.copy(l2);

  group("RawCurve", () {
    test("equality", () {
      expect(curve == RawCurve.fromList(l1), true);
      expect(curve == l1, true);
      expect(curve == d1, true);

      expect(curve == RawCurve.fromList(l2), false);
      expect(curve == l2, false);
      expect(curve == d2, false);
    });

    test("rotate", () {
      final local = curve.copy();
      local.rotate(math.pi * 2);
      expect(local == l1, true);

      local.rotate(math.pi);

      expect(local == <double>[0, 0, -1, -1], true);
    });

    test("translate", () {
      final local = curve.copy();
      local.translate(1, 1);
      local.translate(-1, -1);

      expect(local == curve, true);

      local.translate(1, -1);
      expect(local == <double>[1, -1, 2, 0], true);
    });

    test("scale", () {
      var local = curve.copy();
      local.scale(30);
      expect(local == <double>[0, 0, 30, 30], true);

      local = curve.copy();
      local.scaleX(30);
      expect(local == <double>[0, 0, 30, 1], true);

      local = curve.copy();
      local.scaleY(30);
      expect(local == <double>[0, 0, 1, 30], true);
    });

    test("bbox", () {
      var b = curve.boundingBox;

      expect(b, const Rect.fromLTRB(0, 0, 1, 1));
      expect(curve2.boundingBox, const Rect.fromLTRB(0, -1, 1, 1));

      expect(
          RawCurve.fromList([0, 0, 40, 40, 100, 100, 20, 20, -100, 50, 40, -20])
              .boundingBox,
          const Rect.fromLTRB(-100, -20, 100, 100));
    });
  });
}
