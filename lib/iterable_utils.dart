// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:mink_utils/fmath.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';

import 'basic_utils.dart';
import 'berzier_approximation.dart';

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

extension MiscIterableIterable<T> on Iterable<Iterable<T>> {
  /// returns a list of t from a list of list of t
  Iterable<T> flatten() => expand(id);

  /// returns the combined length of all elements in a nexted list
  int get flattlength => map((e) => e.length).reduce((a, b) => a + b);

  List<List<T>> deepList() => map((e) => e.toList()).toList();
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

extension MoreFlatten<T> on Iterable<Iterable<Iterable<T>>> {
  List<List<List<T>>> deepList() => map((e) => e.deepList()).toList();
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

  Iterable<T> skipLast(int n) => take(length - n);

  List<S> eagerMap<S>(S Function(T e) f) => [for (var s in this) f(s)];

  List<T> eagerWhere(bool Function(T e) f) => [
        for (var s in this)
          if (f(s)) s
      ];

  List<S> eagerMapWhere<S>(
          {required bool Function(T e) where, required S Function(T e) map}) =>
      [
        for (var s in this)
          if (where(s)) map(s)
      ];

  Iterable<(int, T)> enumerate() => List<int>.generate(length, id).zip(this);

  Iterable<(T, S)> zip<S>(Iterable<S> s) sync* {
    final i1 = iterator;
    final i2 = s.iterator;

    while (i1.moveNext() && i2.moveNext()) {
      yield (i1.current, i2.current);
    }
  }

  Iterable<(int, (T, S))> zipIndexed<S>(Iterable<S> s) sync* {
    final i1 = iterator;
    final i2 = s.iterator;

    int c = 0;

    while (i1.moveNext() && i2.moveNext()) {
      yield (c, (i1.current, i2.current));
      c++;
    }
  }

  T mostCommon() =>
      countElements().entries.reduce((a, b) => a.value > b.value ? a : b).key;

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

  /// split iterable into chunks of size n
  Iterable<Iterable<T>> chunks(int n) sync* {
    final count = length / n;

    if (n == 0 || n.isNegative || n.isInfinite) {
      throw ArgumentError("cant create chunks of size $n");
    } else if (count.floor() == 0) {
      throw ArgumentError(
          "cant create chunks larger then the iterables length");
    }
    int i = 0;

    for (i; i < count.floor(); i++) {
      yield skip(i * n).take(n);
    }
    if (count.floor() != count) {
      yield skip(i * n);
    }
  }

  /// split iterable into n chuncks of as equal size and fille
  /// the last chunk with the remaining elements
  Iterable<Iterable<T>> nchunks(int n) => chunks((length / n).ceil());

  Iterable<Iterable<T>> nTimes(int n) => [for (int i = 0; i < n; i++) this];

  Map<T, int> countElements() {
    final Map<T, int> m = {};
    for (var i in this) {
      m[i] = (m[i] ?? 0) + 1;
    }
    return m;
  }

  Map<S, int> countElementsMap<S>(S Function(T) f) {
    final Map<S, int> m = {};
    S temp;
    for (var i in this) {
      temp = f(i);
      m[temp] = (m[temp] ?? 0) + 1;
    }
    return m;
  }

  int? findIndex(T target, {List<int> forbidden = const []}) {
    int index = 0;
    final it = iterator;
    while (it.moveNext()) {
      if (target == it.current && !forbidden.contains(index)) {
        return index;
      } else {
        index++;
      }
    }
    return null;
  }

  Iterable<T> lastN(int i) {
    final l = length;
    return skip(l - i);
  }

  Iterable<T> pysublist(int i1, int i2) {
    if (i1 >= 0) {
      if (i2 >= 0) {
        assert(i1 < i2);
        return skip(i1).take(i2 - i1);
      } else {
        return skip(i1).take(length - i2 + 1);
      }
    } else {
      assert(i1 < i2 && i2 < 0);
      final l = length;
      return skip(l + i1 + 1).take(i2 - i1);
    }
  }

  T at(int i) {
    if (i < 0) {
      return at(length - i);
    } else {
      final it = iterator;
      for (int j = 0; j <= i; j++) it.moveNext();
      return it.current;
    }
  }
}

extension QueueExtensions<T> on Queue<T> {
  void pushn(T val, int n) {
    addLast(val);
    if (length > n) {
      removeFirst();
    }
  }

  void shift(T val) {
    if (isNotEmpty) {
      removeFirst();
    }
    addLast(val);
  }

  void shiftn(T val, int n) => pushn(val, n);
}

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
    return lag.every((val) => f(val[1], val[0]));
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
    final Iterable<T> s = sorted((a, b) => b.compareTo(a)).take(n);
    final List<int> indices = [];
    for (var e in s) {
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

  Iterable<double> bezier() {
    final list = toList();
    final degree = list.length - 1;
    return list.mapIndexed((i, e) => nthBezier(degree, i / list.length, list));
  }

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

extension IntIterableMethods on Iterable<int> {
  bool isMonotonicMod(int mod, {bool strict = false, bool increasing = true}) {
    final fcomp = FMath.matchComp(strict: strict, increasing: increasing);
    return lag.every((v) => FComp.eq.func(v[0], v[1])) ||
        lag.every((v) => FMath.cycliccomp(v[1], v[0], mod, fcomp));
  }

  bool isIncreasingMod(int mod, {bool strict = false}) =>
      isMonotonicMod(mod, strict: strict, increasing: true);

  bool isDecreasingMod(int mod, {bool strict = false}) =>
      isMonotonicMod(mod, strict: strict, increasing: false);
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
