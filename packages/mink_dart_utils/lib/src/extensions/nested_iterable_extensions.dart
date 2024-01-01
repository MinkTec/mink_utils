import 'package:mink_dart_utils/src/utils/base.dart';

extension MiscIterableIterable<T> on Iterable<Iterable<T>> {
  /// returns a list of t from a list of list of t
  Iterable<T> flatten() => expand(id);

  /// returns the combined length of all elements in a nexted list
  int get flattlength => map((e) => e.length).reduce((a, b) => a + b);

  List<List<T>> deepList() => map((e) => e.toList()).toList();
}

extension MoreFlatten<T> on Iterable<Iterable<Iterable<T>>> {
  List<List<List<T>>> deepList() => map((e) => e.deepList()).toList();
}
