import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mink_utils/mink_utils.dart';

void main() {
  final l1 = Float32List.fromList([0, 0, 1, 1]);

  group("transform", () {
    test("rotate", () {
      expect(() {
        final c = l1.copy().toFloat32List();
        RawPointTransformer.rotate(c, math.pi * 2);
        return c;
      }(), l1);

      expect(() {
        final c = l1.copy().toFloat32List();
        RawPointTransformer.rotate(c, math.pi);
        return c;
      }(), Float32List.fromList([0, 0, -1, -1]));
    });

    test("translate", () {
      expect(() {
        final c = l1.copy().toFloat32List();
        RawPointTransformer.translate(c, 1, 1);
        return c;
      }(), Float32List.fromList([1, 1, 2, 2]));
      expect(() {
        final c = l1.copy().toFloat32List();
        RawPointTransformer.translate(c, 1, -1);
        return c;
      }(), Float32List.fromList([1, -1, 2, 0]));
    });

    test("scale", () {
      expect(() {
        final c = l1.copy().toFloat32List();
        RawPointTransformer.scale(c, 30);
        return c;
      }(), Float32List.fromList([0, 0, 30, 30]));

      expect(() {
        final c = l1.copy().toFloat32List();
        RawPointTransformer.scaleX(c, 30);
        return c;
      }(), Float32List.fromList([0, 0, 30, 1]));

      expect(() {
        final c = l1.copy().toFloat32List();
        RawPointTransformer.scaleY(c, 30);
        return c;
      }(), Float32List.fromList([0, 0, 1, 30]));

    });
  });
}
