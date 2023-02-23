import 'dart:math' as math;
import 'dart:typed_data';

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
      b[i + 1] = b[i+1] + dy;
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
}
