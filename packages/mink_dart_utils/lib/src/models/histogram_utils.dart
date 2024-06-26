import 'dart:math' as math;

import 'package:collection/collection.dart' hide IterableNumberExtension;
import 'package:mink_dart_utils/src/extensions/num_iterable_extensions.dart';

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

  factory ClusteredData.dummy() => ClusteredData(data: [], n: 1);

  ClusteredData(
      {required List<List<num>> data,
      required int n,
      List<List<double>?>? limits}) {
    if (data.isEmpty || data.first.isEmpty) {
      baskets = [];
      borders = [];
      return;
    }

    assert(data.every((d) => d.length == data.first.length) &&
        (limits == null || data.length == limits.length));

    borders = ((limits != null)
            ? data.mapIndexed(
                (i, l) => _genHistogramBordersTuple(limits[i] ?? l.extrema, n))
            : data.map((l) => _genHistogramBordersTuple(l.extrema, n)))
        .toList();

    baskets = List<int>.filled(math.pow(n, data.length).toInt(), 0);

    final deltas =
        borders.map((e) => math.max(e.last - e.first, 0.000001)).toList();
    final coords = List<int>.filled(data.length, 0);

    for (int i = 0; i < data.first.length; i++) {
      for (int d = 0; d < data.length; d++) {
        var a = data[d][i];
        var b = borders[d].first;
        var c = deltas[d];
        var cc = ((data[d][i] - borders[d].first) / deltas[d]);
        var ccc = (((data[d][i] - borders[d].first) / deltas[d]) * (n)).floor();

        coords[d] =
            (((data[d][i] - borders[d].first) / deltas[d]) * (n)).floor();
      }
      try {
        baskets[coordsToSerializedIndex(coords)]++;
      } catch (e) {
        // if limits are given the values can exceed the maximum index
      }
    }
  }

  int coordsToSerializedIndex(List<int> coords) =>
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

  int getBasket(List<int> coords) => baskets[coordsToSerializedIndex(coords)];

  List<List<double>> getBorders(List<int> coords) =>
      coords.mapIndexed((i, c) => [borders[i][c], borders[i][c + 1]]).toList();
}

// ignore: unused_element
List<double> _genHistogramBorders(num min, num max, int n) => [
      ...List<double>.generate(n, (i) => min + (max - min) / n * i),
      max.toDouble()
    ];

List<double> _genHistogramBordersTuple(List<num> extrema, int n) => [
      ...List<double>.generate(
          n, (i) => extrema.first + (extrema.last - extrema.first) / n * i),
      extrema.last.toDouble()
    ];

extension StatsticsExtensions<T extends num> on Iterable<T> {
  ClusteredData cluster(int n) => ClusteredData(data: [toList()], n: n);

  @Deprecated("use cluster")
  ClusteredData histogram(int n) => cluster(n);
}

extension HistogramND<T extends num> on List<List<T>> {
  ClusteredData cluster(int n) => ClusteredData(data: this, n: n);
}
