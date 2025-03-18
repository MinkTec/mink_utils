import 'dart:math';

import 'package:mink_dart_utils/mink_dart_utils.dart';

class SortedTimeBoundDataList<T extends TimeBound>
    extends AbstractSortedTimeboundDataList<T> {
  @override
  final List<T> _data;

  SortedTimeBoundDataList(this._data, {bool isSorted = false}) {
    if (!isSorted) {
      assert(_data.isSorted((a, b) => a.time.compareTo(b.time)));
    }
  }

  T? getNearest(DateTime time, {Duration? maxDeviation}) {
    return _data.getNearestFromSorted(time, maxDeviation: maxDeviation);
  }

  int? getNearestIndexFromSorted(DateTime time, {Duration? maxDeviation}) {
    return _data.getNearestIndexFromSorted(time, maxDeviation: maxDeviation);
  }

  (int, int) getTimespanIndices(Timespan timespan) {
    final startIndex = _data.getNearestIndexFromSorted(timespan.begin);
    final endIndex = _data.getNearestIndexFromSorted(timespan.end);
    return (startIndex ?? 0, endIndex ?? _data.length - 1);
  }

  SortedTimeBoundDataList<T> getTimespan(Timespan timespan) {
    final startIndex = _data.getNearestIndexFromSorted(timespan.begin);
    final endIndex = _data.getNearestIndexFromSorted(timespan.end);
    return SortedTimeBoundDataList(
        startIndex == null && endIndex == null
            ? []
            : _data.sublist(startIndex ?? 0, endIndex ?? _data.length - 1),
        isSorted: true);
  }
}

abstract class AbstractSortedTimeboundDataList<T extends TimeBound>
    implements List<T> {
  List<T> get _data;

  @override
  T get first => _data.first;

  @override
  T get last => _data.last;

  @override
  int get length => _data.length;

  @override
  List<T> operator +(List<T> other) {
    final combined = List<T>.from(_data)..addAll(other);
    combined.sort((a, b) => a.time.compareTo(b.time));
    return combined;
  }

  @override
  T operator [](int index) => _data[index];

  @override
  void operator []=(int index, T value) {
    _data[index] = value;
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  void add(T value) {
    _data.add(value);
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  void addAll(Iterable<T> iterable) {
    _data.addAll(iterable);
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  bool any(bool Function(T element) test) => _data.any(test);

  @override
  Map<int, T> asMap() => _data.asMap();

  @override
  List<R> cast<R>() => _data.cast<R>();

  @override
  void clear() => _data.clear();

  @override
  bool contains(Object? element) => _data.contains(element);

  @override
  T elementAt(int index) => _data.elementAt(index);

  @override
  bool every(bool Function(T element) test) => _data.every(test);

  @override
  Iterable<R> expand<R>(Iterable<R> Function(T element) toElements) =>
      _data.expand(toElements);

  @override
  void fillRange(int start, int end, [T? fillValue]) =>
      _data.fillRange(start, end, fillValue);

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _data.firstWhere(test, orElse: orElse);

  @override
  R fold<R>(R initialValue, R Function(R previousValue, T element) combine) =>
      _data.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => _data.followedBy(other);

  @override
  void forEach(void Function(T element) action) => _data.forEach(action);

  @override
  Iterable<T> getRange(int start, int end) => _data.getRange(start, end);

  @override
  int indexOf(T element, [int start = 0]) => _data.indexOf(element, start);

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) =>
      _data.indexWhere(test, start);

  @override
  void insert(int index, T element) {
    _data.insert(index, element);
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _data.insertAll(index, iterable);
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  String join([String separator = ""]) => _data.join(separator);

  @override
  int lastIndexOf(T element, [int? start]) => _data.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) =>
      _data.lastIndexWhere(test, start);

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _data.lastWhere(test, orElse: orElse);

  @override
  Iterable<R> map<R>(R Function(T e) toElement) => _data.map(toElement);

  @override
  bool remove(Object? value) => _data.remove(value);

  @override
  T removeAt(int index) => _data.removeAt(index);

  @override
  T removeLast() => _data.removeLast();

  @override
  void removeRange(int start, int end) => _data.removeRange(start, end);

  @override
  void removeWhere(bool Function(T element) test) => _data.removeWhere(test);

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) =>
      _data.replaceRange(start, end, replacements);

  @override
  void retainWhere(bool Function(T element) test) => _data.retainWhere(test);

  @override
  void setAll(int index, Iterable<T> iterable) => _data.setAll(index, iterable);

  @override
  void setRange(int start, int end, Iterable<T> iterable,
          [int skipCount = 0]) =>
      _data.setRange(start, end, iterable, skipCount);

  @override
  void shuffle([Random? random]) => _data.shuffle(random);

  @override
  Iterable<T> skip(int count) => _data.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => _data.skipWhile(test);

  @override
  void sort([int Function(T a, T b)? compare]) => _data.sort(compare);

  @override
  List<T> sublist(int start, [int? end]) => _data.sublist(start, end);

  @override
  Iterable<T> take(int count) => _data.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => _data.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) => _data.toList(growable: growable);

  @override
  Set<T> toSet() => _data.toSet();

  @override
  Iterable<T> where(bool Function(T element) test) => _data.where(test);

  @override
  Iterable<R> whereType<R>() => _data.whereType<R>();

  @override
  set first(T value) {
    _data.first = value;
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  set last(T value) {
    _data.last = value;
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  set length(int newLength) {
    _data.length = newLength;
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  // TODO: implement iterator
  Iterator<T> get iterator => _data.iterator;

  @override
  T reduce(T Function(T value, T element) combine) => _data.reduce(combine);

  @override
  Iterable<T> get reversed => _data.reversed;

  @override
  T get single => _data.single;

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _data.singleWhere(test, orElse: orElse);
}
