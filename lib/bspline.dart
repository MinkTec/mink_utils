import 'package:vector_math/vector_math.dart';

class BSpline {
  final List<double> _knots;
  final int _degree;
  final List<Vector2> _controlPoints;

  BSpline(this._degree, List<Vector2> controlPoints)
      : _controlPoints = controlPoints,
        _knots = _generateKnots(_degree, controlPoints.length);

  Vector2 evaluate(double t) {
    final span = _findSpan(t);
    final basis = _basisFunctions(span, t);

    var result = Vector2.zero();
    for (var i = 0; i <= _degree; i++) {
      result.add(_controlPoints[span - _degree + i].scaled(basis[i]));
    }

    return result;
  }

  List<Vector2> evaluateRange(double start, double end, int segments) {
    final step = (end - start) / segments;
    final points = <Vector2>[];
    for (var i = 0; i <= segments; i++) {
      final t = start + step * i;
      points.add(evaluate(t));
    }
    return points;
  }

  List<Vector2> get controlPoints => List.unmodifiable(_controlPoints);

  static List<double> _generateKnots(int degree, int numControlPoints) {
    final knots = <double>[];
    for (var i = 0; i <= degree; i++) {
      knots.add(0.0);
    }
    for (var i = 1; i < numControlPoints - degree; i++) {
      knots.add(i.toDouble());
    }
    for (var i = 0; i <= degree; i++) {
      knots.add((numControlPoints - degree).toDouble());
    }
    return knots;
  }

  int _findSpan(double t) {
    if (t >= _knots[_knots.length - _degree - 1]) {
      return _knots.length - _degree - 2;
    }
    var low = _degree;
    var high = _knots.length - _degree - 1;
    var mid = ((high + low) / 2).floor();
    while (t < _knots[mid] || t >= _knots[mid + 1]) {
      if (t < _knots[mid]) {
        high = mid;
      } else {
        low = mid;
      }
      mid = ((high + low) / 2).floor();
    }
    return mid;
  }

  List<double> _basisFunctions(int span, double t) {
    final basis = List.filled(_degree + 1, 0.0);
    basis[0] = 1.0;
    final left = List.filled(_degree + 1, 0.0);
    final right = List.filled(_degree + 1, 0.0);
    for (var j = 1; j <= _degree; j++) {
      left[j] = t - _knots[span + 1 - j];
      right[j] = _knots[span + j] - t;
      var saved = 0.0;
      for (var k = 0; k < j; k++) {
        final temp = basis[k] / (right[k + 1] + left[j - k]);
        basis[k] = saved + right[k + 1] * temp;
        saved = left[j - k] * temp;
      }
      basis[j] = saved;
    }
    return basis;
  }
}
