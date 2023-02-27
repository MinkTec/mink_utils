import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:mink_utils/list_utils.dart';

class RawCurve {
  Float32List points;

  RawCurve(this.points);

  factory RawCurve.fromList(List<double> list) =>
      RawCurve(Float32List.fromList(list));

  factory RawCurve.copy(Float32List l) => RawCurve.fromList(l.copy());

  RawCurve copy() => RawCurve.copy(points);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is RawCurve) {
      return listEquals(points, other.points);
    } else if (other is List<double> || other is Float32List) {
      return listEquals(points, other as List<double>);
    } else {
      return false;
    }
  }

  void rotate(double angle) {
    double temp;
    for (int i = 0; i < points.length; i += 2) {
      temp = points[i] * math.cos(angle) - points[i + 1] * math.sin(angle);
      points[i + 1] =
          points[i] * math.sin(angle) + points[i + 1] * math.cos(angle);
      points[i] = temp;
    }
  }

  void translate(double dx, double dy) {
    for (int i = 0; i < points.length; i += 2) {
      points[i] = points[i] + dx;
      points[i + 1] = points[i + 1] + dy;
    }
  }

  void scale(double scale) {
    assert(points.length > 3);

    final baseX = points[0];
    final baseY = points[1];

    for (int i = 2; i < points.length; i += 2) {
      points[i] = (points[i] - baseX) * scale;
      points[i + 1] = (points[i + 1] - baseY) * scale;
    }
  }

  void scaleX(double scale) {
    assert(points.length > 3);
    final baseX = points[0];
    for (int i = 2; i < points.length; i += 2) {
      points[i] = (points[i] - baseX) * scale;
    }
  }

  void scaleY(double scale) {
    assert(points.length > 3);
    final baseY = points[1];
    for (int i = 2; i < points.length; i += 2) {
      points[i + 1] = (points[i + 1] - baseY) * scale;
    }
  }

  Rect get boundingBox {
    final List<double> rect = [points[0], points[1], points[0], points[1]];

    for (int i = 2; i < points.length; i += 2) {
      if (rect[0] > points[i]) rect[0] = points[i];
      if (rect[1] > points[i + 1]) rect[1] = points[i + 1];
      if (rect[2] < points[i]) rect[2] = points[i];
      if (rect[3] < points[i + 1]) rect[3] = points[i + 1];
    }
    assert(rect[0] <= rect[2] && rect[1] <= rect[3]);

    return Rect.fromLTRB(rect[0], rect[1], rect[2], rect[3]);
  }

  Offset get center => boundingBox.center;
}
