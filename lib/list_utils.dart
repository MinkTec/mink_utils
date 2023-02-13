import 'dart:math' as math;
import 'dart:typed_data';

import 'package:mink_utils/iterable_utils.dart';

/// ads list methods that should have (mostly) been included in the
/// stdlib from the beginning for list of with elemnts of type
/// num, int, or double
extension BasicsListMethods<T extends num> on List<T> {
  T sumBefore(int index) => sublist(0, index).sum;

  /// weighted average of this
  Iterable<double> get smooth sync* {
    for (int i = 0; i < length - 4; i++) {
      yield (this[i + 1] - this[i]).toDouble();
    }
  }

  double takesmooth([int n = 4]) {
    try {
      return (pysublist(-n - 1, -1)).sum / n;
    } catch (e) {
      return 0;
    }
  }

  int get indexOfMax => indexOf(reduce(math.max));
  int get indexOfMin => indexOf(reduce(math.min));

}

extension BasicsDouble on List<double> {
  /// replace all zeros with a value close to
  /// zero to allow safe elementwise division
  void makeDivisible() {
    for (int i = 0; i < length; i++) {
      this[i] = (this[i] == 0) ? 0.001 : this[i];
    }
  }
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

  Iterable<T> takeRandom(int n) sync* {
    Set<int> indices = {};
    while (indices.length < n) {
      indices.add(math.Random().nextInt(length));
    }
    for (var i in indices) {
      yield this[i];
    }
  }

  T? get lastOrNull => isNotEmpty ? last : null;
  T? get firstOrNull => isNotEmpty ? last : null;
}

extension BasicsInt16List on Int16List {
  List<int> pysublist(int firstIndex, int lastIndex) => sublist(
      ((firstIndex < 0) ? length + firstIndex + 1 : firstIndex),
      ((lastIndex < 0) ? length + lastIndex + 1 : lastIndex));
}
