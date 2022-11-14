import 'dart:math' as math;
import 'dart:typed_data';
import 'package:tuple/tuple.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import 'basic_utils.dart';

/// creates a list of 2-element lists with pairs
/// of a and be values.
/// example:
///     zip([1,2,3],[4,5,6]) -> [[1,4],[2,5],[3,6]]
//List<List<T>> zip<T>(List<T> a, List<T> b) =>
//    a.mapIndexed((index, element) => [element, b[index]]).toList();

Iterable<int> range({required int last, int first = 0, int step = 1}) sync* {
  for (int i = first; i <= last; i += step) {
    yield i;
  }
}

/// combine two lists into one with alternating elemnts
/// [a1, a2, a3], [b1, b2, b3] -> [a1, b1, a2, b2, a3, b3 ...]
Float32List weave(List<num> a, List<num> b) {
  final res = Float32List.fromList(List<double>.filled(a.length + b.length, 0));
  for (int i = 0; i < a.length; i++) {
    res[2 * i] = a[i].toDouble();
    res[2 * i + 1] = b[i].toDouble();
  }
  return res;
}

/// adds the [elem] to the end of [l].
/// if n is given the first element is popped,
/// if the list is longer than [n]
void shift<T>(List<T> l, T elem, [int? n]) {
  l.add(elem);
  if (n != null && l.length > n) l.removeAt(0);
}

extension Flatten<T> on Iterable<Iterable<T>> {
  /// returns a list of t from a list of list of t
  Iterable<T> flatten() => expand(id);

  /// returns the combined length of all elements in a nexted list
  int get flattlength => map((e) => e.length).reduce((a, b) => a + b);
}

extension TypedZip2<T, S> on Tuple2<List<T>, List<S>> {
  List<Tuple2<T, S>> zip() {
    List<Tuple2<T, S>> l = [];
    for (int i = 0; i < item1.length; i++) {
      l.add(Tuple2(item1[i], item2[i]));
    }
    return l;
  }
}

extension TypedZip3<T, S, X> on Tuple3<List<T>, List<S>, List<X>> {
  List<Tuple3<T, S, X>> zip() {
    List<Tuple3<T, S, X>> l = [];
    for (int i = 0; i < item1.length; i++) {
      l.add(Tuple3(item1[i], item2[i], item3[i]));
    }
    return l;
  }
}

extension TypedZip4<T, S, X, Z> on Tuple4<List<T>, List<S>, List<X>, List<Z>> {
  List<Tuple4<T, S, X, Z>> zip() {
    List<Tuple4<T, S, X, Z>> l = [];
    for (int i = 0; i < item1.length; i++) {
      l.add(Tuple4(item1[i], item2[i], item3[i], item4[i]));
    }
    return l;
  }
}

extension BasicIteratorMethods<T> on Iterable<T> {
  /// keep every nth element of an iterable starting with the first
  /// [1,2,3,4,5,6,7,8,9].takeEveryNth(3) -> [1,4,7]
  Iterable<T> takeEveryNth(int n) => whereIndexed((i, _) => i % n == 0);

  /// keep every other element than the nth
  /// [1,2,3,4,5,6,7,8,9].takeEveryNth(3) -> [2,3,5,6,8,9]
  Iterable<T> takeEveryNotNth(int n) => whereIndexed((i, _) => i % n != 0);

  /// keep n equaly spaced elements of an array
  Iterable<T> decimate(int n) => takeEveryNth(math.max(1, length ~/ n));

  Iterable<T> rotate([int n = 1]) sync* {
    var it = iterator;
    final int l = length;
    int c = 0;
    while (c < n % l) {
      it.moveNext();
      c++;
    }
    while (it.moveNext()) {
      yield it.current;
    }
    it = iterator;
    it.moveNext();
    c = 0;
    while (c < n % l) {
      yield it.current;
      c++;
      it.moveNext();
    }
  }

  Iterable<List<T>> get lag sync* {
    final i = iterator;
    i.moveNext();
    T temp = i.current;
    while (i.moveNext()) {
      yield [temp, i.current];
      temp = i.current;
    }
  }

  /// return the indices, that satisfy the condition
  Iterable<int> findIndices(bool Function(T element) test) sync* {
    var index = 0;
    for (var element in this) {
      index++;
      if (test(element)) yield index;
    }
  }

  Iterable<T> get firstHalf sync* {
    final cut = length / 2;
    final it = iterator;
    int c = 0;
    while (c < cut) {
      it.moveNext();
      yield it.current;
      c++;
    }
  }

  Iterable<T> get secondHalf sync* {
    final cut = length / 2;
    final it = iterator;
    int c = 0;
    while (c < cut) {
      it.moveNext();
      c++;
    }
    while (it.moveNext()) {
      yield it.current;
    }
  }
}

extension NumIteratorExtensions<T extends num> on Iterable<T> {
  T get sum => (isNotEmpty) ? reduce((a, b) => a + b as T) : 0.0 as T;
  T get max => (isNotEmpty) ? reduce((a, b) => math.max(a, b)) : 0.0 as T;
  T get min => (isNotEmpty) ? reduce((a, b) => math.min(a, b)) : 0.0 as T;

  double get average => sum / length;

  Iterable<T> get absdiff sync* {
    final it = iterator;
    it.moveNext();
    T last = it.current;
    while (it.moveNext()) {
      yield (last.abs() - it.current.abs()).abs() as T;
      last = it.current;
    }
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
      yield i1.current + i2.current as T;
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

  double get avg => sum / length;

  Iterable<double> get middleAverages => lag.map((e) => e.sum / 2);
}

extension IntListConversion on List<int> {
  Iterable<double> makeDivisible() sync* {
    for (int i = 0; i < length; i++) {
      yield (this[i] == 0) ? 0.001 : this[i].toDouble();
    }
  }

  Iterable<double> toDouble() sync* {
    for (final d in this) {
      yield d.toDouble();
    }
  }
}
