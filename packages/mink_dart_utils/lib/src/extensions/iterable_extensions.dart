// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:collection';
import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:filterinio/filterinio.dart';
import 'package:mink_dart_utils/src/utils/base.dart';
import 'package:mink_dart_utils/src/utils/fmath.dart';

Iterable<int> range({required int last, int first = 0, int step = 1}) sync* {
  for (int i = first; i <= last; i += step) yield i;
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

  Iterable<T> skipLast(int n) => take(math.max(0, length - n));

  Iterable<T> takeLast(int n) => skip(math.max(0, length - n)).take(1000000);

  Iterable<T> intersperse(T value) sync* {
    final it = iterator;
    if (isNotEmpty) {
      it.moveNext();
      yield it.current;
      while (it.moveNext()) {
        yield value;
        yield it.current;
      }
    }
  }

  Iterable<T> padRight(int n, T element) sync* {
    final it = iterator;
    for (int i = 0; i < n; i++) {
      yield it.moveNext() ? it.current : element;
    }
  }

  List<T> padLeft(int n, T element) {
    return [...List<T>.filled(n - length, element), ...this];
  }

  List<S> eagerMap<S>(S Function(T x) f) =>
      [for (var element in this) f(element)];

  List<T> eagerWhere(bool Function(T) f) => [
        for (var element in this)
          if (f(element)) element
      ];

  List<S> eagerMapWhere<S>(
          {required bool Function(T e) where, required S Function(T e) map}) =>
      [
        for (var s in this)
          if (where(s)) map(s)
      ];

  (Iterable<T>, Iterable<T>) splitOnPredicate(Predicate<T> predicate) {
    final isTrue = Queue<T>();
    final isFalse = Queue<T>();

    for (var element in this) {
      if (predicate(element)) {
        isTrue.add(element);
      } else {
        isFalse.add(element);
      }
    }
    return (isTrue, isFalse);
  }

  //List<T> sorted(Comparator<T> compare) => [...this]..sort(compare);

  Iterable<(int, T)> enumerate() => List<int>.generate(length, id).zip(this);

  /// enumerates the list but inverses (just) the indices
  Iterable<(int, T)> enumerateReverse() {
    final len = length;
    return List<int>.generate(len, (x) => len - x - 1).zip(this);
  }

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

  T? mostCommon() => isNotEmpty
      ? countElements().entries.reduce((a, b) => a.value > b.value ? a : b).key
      : null;

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

extension IntIterableMethods on Iterable<int> {
  bool isMonotonicMod(int mod, {bool strict = false, bool increasing = true}) {
    final fcomp = FMath.matchComp(strict: strict, increasing: increasing);
    return lag.every(
            (v) => BinaryComparison.eq.func<int, int, num>()(v[0], v[1])) ||
        lag.every((v) => FMath.cycliccomp(v[1], v[0], mod, fcomp));
  }

  bool isIncreasingMod(int mod, {bool strict = false}) =>
      isMonotonicMod(mod, strict: strict, increasing: true);

  bool isDecreasingMod(int mod, {bool strict = false}) =>
      isMonotonicMod(mod, strict: strict, increasing: false);

  Iterable<double> makeDivisible() sync* {
    final it = iterator;
    while (it.moveNext()) {
      yield (it.current == 0) ? 0.0000001 : it.current.toDouble();
    }
  }

  Iterable<double> toDouble() sync* {
    for (final d in this) {
      yield d.toDouble();
    }
  }
}

extension Denumerate<T> on Iterable<(int, T)> {
  Iterable<T> denumerate() => map((x) => x.$2);
}
