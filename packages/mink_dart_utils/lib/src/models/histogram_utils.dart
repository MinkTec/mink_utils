import 'dart:math' as math;

import 'package:mink_dart_utils/mink_dart_utils.dart';

// from dart:ui
double? _lerpDouble(num? a, num? b, double t) {
  if (a == b || (a?.isNaN ?? false) && (b?.isNaN ?? false)) {
    return a?.toDouble();
  }
  a ??= 0.0;
  b ??= 0.0;
  assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(t.isFinite, 't must be finite when interpolating between values');
  return a * (1.0 - t) + b * t;
}

class ClusteredDataCell {
  final int? index;
  final int count;
  final List<List<double>> borders;

  ClusteredDataCell({required this.count, required this.borders, this.index});

  @override
  String toString() => """$count: $borders""";

  double _findMiddle(List<double> d) => _lerpDouble(d.first, d.last, 0.5)!;

  List<double> get center => borders.map(_findMiddle).toList();
}

class ClusteredData {
  List<int> baskets = [];
  List<List<double>> borders = [];

  int get n => (borders.firstOrNull?.length ?? 1) - 1;
  int get dim => borders.length;

  @override
  toString() {
    int leftpad = 1;
    if (top(1).isNotEmpty) {
      leftpad = 1 + top(1).first.count.toString().length;
    }
    return "|${[
      for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
          """${getCell([
                j,
                i
              ]).count.toString().padLeft(leftpad)}  ${(j == n - 1) ? "|\n" : ""}"""
    ].join("|")}";
  }

  // Coordinate system:
  // Since darts support for ndim arrays is ass the coordinates for
  // the baskets are implemented using a map ℕⁿ -> ℕ.
  //
  // The the nodes of Hypercube the imaginary Hypbercube are numbered
  // consecutive.
  //
  // Consider the following square:
  //   x1  0  1  2
  // x2 | ----------
  // 0  |  0  1  2
  // 1  |  3  4  5
  // 2  |  6  7  8
  //
  // The center-right field can be expressed as [2][1] or as 5.
  // The Coordinates can be transformed by following expression:
  //
  // i = ∑ₙxₙ * lⁿ
  //
  // where x is the coordinate vector, n is the number of the dimension
  // counted from 0 and l is the length of on edge of the Hypercube.
  //
  // 5 = 2 * 3⁰ + 1 * 3¹
  //
  // TODO: Find mathematical expression for the backtransform

  factory ClusteredData.dummy() => ClusteredData.calc(data: [], n: 1);

  ClusteredData({
    required this.baskets,
    required this.borders,
  });

  factory ClusteredData.calc({
    required List<List<num>> data,
    required int n,
    List<List<double>?>? limits,
  }) {
    if (data.isEmpty || data.first.isEmpty) {
      return ClusteredData(
        baskets: [],
        borders: [],
      );
    }

    assert(data.every((d) => d.length == data.first.length) &&
        (limits == null || data.length == limits.length));

    final borders = ((limits != null)
            ? data.mapIndexed((i, l) => _genHistogramBordersTuple(
                limits[i] != null
                    ? (limits[i]![0], limits[i]![1])
                    : l.extrema(),
                n))
            : data.map((l) => _genHistogramBordersTuple(l.extrema(), n)))
        .toList();

    final baskets = List<int>.filled(math.pow(n, data.length).toInt(), 0);

    final deltas =
        borders.map((e) => math.max(e.last - e.first, 0.000001)).toList();

    final coords = List<int>.filled(data.length, 0);

    double x;

    for (int i = 0; i < data.first.length; i++) {
      for (int d = 0; d < data.length; d++) {
        x = (((data[d][i] - borders[d].first) / deltas[d]) * (n));
        if (x.isFinite) {
          coords[d] = x.floor();
        }
      }
      try {
        baskets[coordsToSerializedIndex(coords, n)]++;
      } catch (_) {
        // if limits are given the values can exceed the maximum index
      }
    }

    return ClusteredData(borders: borders, baskets: baskets);
  }

  factory ClusteredData.oneDimensional({
    required Iterable<double> data,
    required int n,
    double? min,
    double? max,
  }) {
    final baskets = List<int>.filled(n, 0);

    min ??= data.reduce(math.min);
    max ??= data.reduce(math.max);

    double i;

    int counter = 0;
    for (var d in data) {
      if (d > 90) {
        counter++;
      }
    }
    print("-------- got ${counter} over 90");

    final borders = _genHistogramBorders(min, max, n);

    for (var x in data) {
      if (x < min || x > max) {
        continue;
      }
      if (x == max) {
        baskets.last++;
        continue;
      }
      i = ((x - min) / (max - min));
      baskets[(i * n).floor()]++;
    }

    return ClusteredData(
      borders: [borders],
      baskets: baskets,
    );
  }

  factory ClusteredData.oneDimensionalCustomLimitsWithOutliers({
    required Iterable<double> data,
    required List<double> limits,
  }) {
    final baskets = List<int>.filled(limits.length + 1, 0);

    int i;

    for (var x in data) {
      if (x >= limits.last) {
        baskets.last++;
        continue;
      }
      if (x <= limits.first) {
        baskets.first++;
        continue;
      }
      for (i = 0; i < limits.length; i++) {
        if (x < limits[i]) {
          baskets[i]++;
          break;
        }
      }
    }

    return ClusteredData(
      borders: [
        [double.negativeInfinity, ...limits, double.infinity]
      ],
      baskets: baskets,
    );
  }

  static int coordsToSerializedIndex(List<int> coords, int n) =>
      coords.reversed.mapIndexed((i, c) => c * math.pow(n, i).toInt()).sum;

  List<int> serializedIndexToCoords(int i) {
    // TODO should probably be done with bit operations
    List<int> coords = [];
    final d = borders.length;
    final edge = borders.first.length - 1;
    int f;
    for (int x = 1; x <= d; x++) {
      f = math.pow(edge, d - x).toInt();
      coords.add(i ~/ f);
      i -= coords.last * f;
    }
    return coords;
  }

  Iterable<ClusteredDataCell> top([int n = 10]) sync* {
    final indices = baskets.topIndices(n);
    for (var i in indices) {
      final c = serializedIndexToCoords(i);
      yield ClusteredDataCell(
          count: baskets[i],
          index: i,
          borders:
              borders.mapIndexed((i, e) => [e[c[i]], e[c[i] + 1]]).toList());
    }
  }

  ClusteredDataCell getCell(List<int> coords) =>
      ClusteredDataCell(count: getBasket(coords), borders: getBorders(coords));

  int getBasket(List<int> coords) =>
      baskets[coordsToSerializedIndex(coords, n)];

  List<List<double>> getBorders(List<int> coords) {
    if (n < 5) {
      print(StackTrace.current);
      print("--- coords ${coords} | borders: ${borders}");
    }
    return coords
        .mapIndexed((i, c) => [borders[i][c], borders[i][c + 1]])
        .toList();
  }
}

// ignore: unused_element
List<double> _genHistogramBorders(num min, num max, int n) => [
      ...List<double>.generate(n, (i) => min + (max - min) / n * i),
      max.toDouble()
    ];

List<double> _genHistogramBordersTuple((num, num) extrema, int n) => [
      ...List<double>.generate(
          n, (i) => extrema.$1 + (extrema.$2 - extrema.$1) / n * i),
      extrema.$2.toDouble()
    ];

extension StatsticsExtensions<T extends num> on Iterable<T> {
  ClusteredData cluster(int n) => ClusteredData.calc(data: [toList()], n: n);

  @Deprecated("use cluster")
  ClusteredData histogram(int n) => cluster(n);
}

extension HistogramND<T extends num> on List<List<T>> {
  ClusteredData cluster(int n) => ClusteredData.calc(data: this, n: n);
}
