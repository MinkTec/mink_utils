// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:mink_dart_utils/src/extensions/num_iterable_extensions.dart';

/// ads list methods that should have (mostly) been included in the
/// stdlib from the beginning for list of with elemnts of type
/// num, int, or double
extension BasicsListMethods<T extends num> on List<T> {
  T sumBefore(int index) => sublist(0, index).sum;

  /// weighted average of this
  Iterable<double> get smooth sync* {
    for (int i = 0; i < length - 4; i++)
      yield (this[i + 1] - this[i]).toDouble();
  }

  List<double> makeDivisible() =>
      [for (var e in this) e == 0 ? 0.00001 : e.toDouble()];

  double takesmooth([int n = 4]) {
    try {
      return (pysublist(-n - 1, -1)).sum / n;
    } catch (e) {
      return 0;
    }
  }

  int get indexOfMax => indexOf(reduce(math.max));
  int get indexOfMin => indexOf(reduce(math.min));

  Iterable<T> nLargest(int n) sync* {
    for (var i in topIndices(n)) yield this[i];
  }

  List<T> takeEveryNth(int n) => [for (int i = 0; i < length; i += n) this[i]];

  List<T> decimate(int n) => takeEveryNth(math.max(1, length ~/ n));
}

extension BasicsDouble on List<double> {
  Float32List toFloat32List() => Float32List.fromList(this);
}

/// ads list methods that should have (mostly) been included in the
/// stdlib from the beginning
extension Basics<T> on List<T> {
  /// moves all elements of a list on index to the left
  /// and ads a new element to the end of a list
  void shift(T elem) {
    for (int i = 0; i < length - 1; i++) {
      this[i] = this[i + 1];
    }
    this[length - 1] = elem;
  }

  List<T> copy() => List<T>.generate(length, (i) => this[i]);

  T lerp(double t) => this[(t * length).round()];

  /// adds the [elem] to the end of [this]
  /// if n is given the first element is popped,
  /// if the list is longer than [n]
  void shiftn(T elem, int len) => (length >= len) ? shift(elem) : add(elem);

  /// provides python like list indexing which accepts negative values
  List<T> pysublist(int firstIndex, int lastIndex) => sublist(
      ((firstIndex < 0) ? length + firstIndex + 1 : firstIndex),
      ((lastIndex < 0) ? length + lastIndex + 1 : lastIndex));

  T at(int index) {
    return (index >= 0) ? this[index] : this[length + index];
  }

  Iterable<T> rotate([int n = 1]) sync* {
    for (int i = 0; i < length; i++) {
      yield this[(i + n) % length];
    }
  }

  List<T> get shuffled {
    shuffle();
    return this;
  }

  List<List<T>> nTimes(int n) => [for (int i = 0; i < n; i++) this];

  T randomElement() => this[math.Random().nextInt(length)];

  Iterable<T> takeRandom(int n) sync* {
    Set<int> indices = {};
    while (indices.length < n) {
      indices.add(math.Random().nextInt(length));
    }
    for (var i in indices) {
      yield this[i];
    }
  }
}

extension BasicsInt16List on Int16List {
  List<int> pysublist(int firstIndex, int lastIndex) => sublist(
      ((firstIndex < 0) ? length + firstIndex + 1 : firstIndex),
      ((lastIndex < 0) ? length + lastIndex + 1 : lastIndex));
}

extension LinearAlgebraUtils2D<T> on List<List<T>> {
  List<List<T>> get transposed {
    if (isEmpty) return [];
    if (first.isEmpty) return [[]];

    assert(every((e) => e.length == first.length));

    return [
      for (int x = 0; x < first.length; x++)
        [for (int y = 0; y < length; y++) this[y][x]]
    ];
  }

  // https://stackoverflow.com/questions/57754481/cartesian-product-in-dart-language/57757354#57757354
  Iterable<List<T>> cartesian() sync* {
    if (isEmpty) {
      yield List<T>.filled(0, null as T);
      return;
    }
    var indices = List<int>.filled(length, 0);
    int cursor = length - 1;
    outer:
    do {
      yield [for (int i = 0; i < indices.length; i++) this[i][indices[i]]];
      do {
        int next = indices[cursor] += 1;
        if (next < this[cursor].length) {
          cursor = length - 1;
          break;
        }
        indices[cursor] = 0;
        cursor--;
        if (cursor < 0) break outer;
      } while (true);
    } while (true);
  }
}
