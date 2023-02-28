import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:mink_utils/iterable_utils.dart';
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

  double get arcLength {
    if (points.length < 4) return 0;

    final l = [points[0], points[1]];
    double acc = 0;
    double dx, dy;

    for (int i = 2; i < points.length; i += 2) {
      dx = points[i] - l[0];
      dy = points[i + 1] - l[1];
      l[0] = points[i];
      l[1] = points[i + 1];
      acc += math.sqrt(dx * dx + dy * dy);
    }
    return acc;
  }

  /// Extrapolate linear from either end of the curve.
  /// This function gets the interpolation direction
  /// from the direction of the second last to last element.
  ///
  /// The [t] t variable sets the length in relation to the
  /// curves [arcLength];
  /// A value of t = 0.1 would add 10 percent of the arc length
  /// in the direction the last two elements are pointing.
  /// Negativ values for [t] indicate exptrapolation from the
  /// start of the curve rather than the end.
  Offset lexp(double t) {
    final l = arcLength;
    List<double> d;
    List<double> s;
    if (t >= 0) {
      d = [points.at(-2) - points.at(-4), points.at(-1) - points.at(-3)];
      s = [points.at(-2), points.at(-1)];
    } else {
      d = [points.at(0) - points.at(2), points.at(1) - points.at(3)];
      s = [points[0], points[1]];
    }

    final n = d.norm();
    return Offset(s[0] + l * t.abs() * n[0], s[1] + l * t.abs() * n[1]);
  }

  Offset get center => boundingBox.center;
}
