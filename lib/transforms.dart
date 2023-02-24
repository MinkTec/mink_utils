import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/painting.dart';

class RawPointTransformer {
  static void rotate(Float32List b, double angle) {
    double temp;
    for (int i = 0; i < b.length; i += 2) {
      temp = b[i] * math.cos(angle) - b[i + 1] * math.sin(angle);
      b[i + 1] = b[i] * math.sin(angle) + b[i + 1] * math.cos(angle);
      b[i] = temp;
    }
  }

  static void translate(Float32List b, double dx, double dy) {
    for (int i = 0; i < b.length; i += 2) {
      b[i] = b[i] + dx;
      b[i + 1] = b[i + 1] + dy;
    }
  }

  static void scale(Float32List b, double scale) {
    assert(b.length > 3);

    final baseX = b[0];
    final baseY = b[1];

    for (int i = 2; i < b.length; i += 2) {
      b[i] = (b[i] - baseX) * scale;
      b[i + 1] = (b[i + 1] - baseY) * scale;
    }
  }

  static void scaleX(Float32List b, double scale) {
    assert(b.length > 3);
    final baseX = b[0];
    for (int i = 2; i < b.length; i += 2) {
      b[i] = (b[i] - baseX) * scale;
    }
  }

  static void scaleY(Float32List b, double scale) {
    assert(b.length > 3);
    final baseY = b[1];
    for (int i = 2; i < b.length; i += 2) {
      b[i + 1] = (b[i + 1] - baseY) * scale;
    }
  }

  /// returns the bounding box as rectangle [top, left, width, height]
  static Rect getBoundingBox(Float32List b) {
    final List<double> rect = [b[0], b[1], b[0], b[1]];

    for (int i = 2; i < b.length; i += 2) {
      if (rect[0] > b[i]) rect[0] = b[i];
      if (rect[1] > b[i + 1]) rect[1] = b[i + 1];
      if (rect[2] < b[i]) rect[2] = b[i];
      if (rect[3] < b[i + 1]) rect[3] = b[i + 1];
    }

    return Rect.fromLTRB(b[0], b[1], b[2], b[3]);
  }

  static Offset getCenter(Float32List b) => getBoundingBox(b).center;
}
