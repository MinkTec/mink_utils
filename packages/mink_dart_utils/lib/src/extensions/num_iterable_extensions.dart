import 'dart:math' as math;

import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';
import 'package:mink_dart_utils/src/utils/fmath.dart';

extension NumIteratorExtensions<T extends num> on Iterable<T> {
  T get sum => (isNotEmpty) ? reduce((a, b) => a + b as T) : 0 as T;
  T get max => (isNotEmpty) ? reduce((a, b) => math.max(a, b)) : 0 as T;
  T get min => (isNotEmpty) ? reduce((a, b) => math.min(a, b)) : 0 as T;

  double get average => sum / length;

  List<T> get extrema {
    T min = first;
    T max = first;
    for (var e in this) {
      if (e.isNaN) {
        continue;
      } else if (e < min) {
        min = e;
      } else if (e > max) {
        max = e;
      }
    }
    return [min, max];
  }

  bool isMonotonic({bool strict = false, bool increasing = true}) {
    final f = FMath.matchComp(strict: strict, increasing: increasing).func;
    return lag.every((val) => f<T, T, num>()(val[1], val[0]));
  }

  bool isIncreasing({bool strict = false}) =>
      isMonotonic(increasing: true, strict: strict);

  bool isDecreasing({bool strict = false}) =>
      isMonotonic(increasing: false, strict: strict);

  Iterable<T> get absdiff sync* {
    final it = iterator;
    it.moveNext();
    T last = it.current;
    while (it.moveNext()) {
      yield (last.abs() - it.current.abs()).abs() as T;
      last = it.current;
    }
  }

  /// get an iterator of the n indices coresponding to the
  /// n largest values in descending order
  List<int> topIndices(int n) {
    if (n > length) {
      throw ArgumentError("n is larger than the number of elements in list");
    }
    final copy = [...this];
    copy.sort((a, b) => b.compareTo(a));
    final List<int> indices = [];
    for (var e in copy.take(n)) {
      indices.add(findIndex(e, forbidden: indices)!);
    }
    return indices;
  }

  /// returns a list with elements standarized
  /// to have a ||x||₂ = 1
  List<double> norm() {
    double acc = 0.0;
    for (var e in this) {
      acc += e * e;
    }
    final double normFactor = 1 / math.sqrt(acc);
    final res = List<double>.filled(length, 0);
    int counter = 0;
    for (var e in this) {
      res[counter] = e * normFactor;
      counter++;
    }
    return res;
  }

  /// returns the difference between each elemnt
  Iterable<T> get diff sync* {
    final i1 = iterator;
    final i2 = iterator;
    i2.moveNext();
    while (i1.moveNext() && i2.moveNext()) {
      yield (i2.current - i1.current) as T;
    }
  }

  Iterable<double> toDouble() sync* {
    for (final d in this) {
      yield d.toDouble();
    }
  }

  Iterable<double> group(int n) sync* {
    double acc = 0;
    int c = 1;
    for (var e in this) {
      acc += e;
      if ((c % n) == 0) {
        yield (acc / n);
        acc = 0;
      }
      c++;
    }
  }

  double get avg => isNotEmpty ? sum / length : 0;

  Iterable<double> get middleAverages => lag.map((e) => e.sum / 2);

  Iterable<T> get realabsdiff sync* {
    final it = iterator;
    it.moveNext();
    T last = it.current;
    while (it.moveNext()) {
      yield (last - it.current).abs() as T;
      last = it.current;
    }
  }

  double takesmooth([int n = 4]) {
    try {
      return (pysublist(-n - 1, -1)).sum / n;
    } catch (e) {
      return 0;
    }
  }
}
