import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:mink_utils/mink_utils.dart';

List<num> normalizedPathLength(List<num> x, List<num> y) {
  final l = List<num>.filled(x.length, 0);
  for (int i = 1; i < x.length; i++) {
    l[i] = l[i - 1] + distance(x[i - 1], y[i - 1], x[i], y[i]);
  }
  for (int i = 0; i < l.length; i++) {
    l[i] /= l.last;
  }
  return l;
}

Offset quadraticBezier(Offset p0, Offset p1, Offset p2, num t) => Offset(
    pow(1 - t, 2) * ((1 - t) * p0.dx + t * p1.dx) +
        t * ((1 - t) * p1.dx + t * p2.dx),
    pow(1 - t, 2) * ((1 - t) * p0.dy + t * p1.dy) +
        t * ((1 - t) * p1.dy + t * p2.dy));

List<Offset> bezierOffsets(Offset p0, Offset p1, Offset p2) {
  final List<Offset> offsets = [];
  for (int i = 0; i < 100; i++) {
    offsets.add(quadraticBezier(p0, p1, p2, i));
  }
  return offsets;
}

// generates the bezier curve for a point with Bernstein polynomials.
// n : degree
// t : 0 < 1
// w : weights
double nthBezier(int n, num t, List<num> w) {
  double sum = 0;
  for (int k = 0; k <= n; k++) {
    sum += binomial(n, k) * pow((1 - t), n - k) * pow(t, k) * w[k];
  }
  return sum;
}

// generate a bezier curve of degree x.length - 1 that uses the points
// given in x and y as controll points. The points argument sets the
// number of points that should be generated on this path.
// The return values are given as a single list, where the values are
// pairs of x and y coordinates to draw points on.
// like [x1, y1, x2, y2, x3, y3, ..., xn, yn]
Float32List nthBezierCurve(List<num> x, List<num> y, {int points = 100}) {
  final offsets = Float32List(points * 2 + 2);
  for (int i = 0; i <= points; i++) {
    offsets[2 * i] = nthBezier(x.length - 1, i / points, x);
    offsets[2 * i + 1] = nthBezier(x.length - 1, i / points, y);
  }
  return offsets;
}
