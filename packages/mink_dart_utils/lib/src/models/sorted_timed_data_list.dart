import 'dart:math';

import 'package:mink_dart_utils/mink_dart_utils.dart';

class SortedTimeBoundDataListView<T extends TimeBound>
    extends SortedTimeBoundDataList<T> {
  int startIndex;
  int endIndex;

  SortedTimeBoundDataListView(
    super._data, {
    super.isSorted,
    int? startIndex,
    int? endIndex,
  })  : startIndex = startIndex ?? 0,
        endIndex = endIndex ?? _data.length - 1;

  /// Translates a view index to the underlying data index
  int _toDataIndex(int viewIndex) {
    if (viewIndex < 0 || viewIndex >= length) {
      throw RangeError.index(viewIndex, this, 'index', null, length);
    }
    return startIndex + viewIndex;
  }

  /// Translates a data index to a view index (returns null if out of bounds)
  int? _toViewIndex(int dataIndex) {
    if (dataIndex < startIndex || dataIndex > endIndex) return null;
    return dataIndex - startIndex;
  }

  @override
  int get length => max(0, endIndex - startIndex + 1);

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => length > 0;

  @override
  T get first {
    if (isEmpty) throw StateError('No element');
    return _data[startIndex];
  }

  @override
  T get last {
    if (isEmpty) throw StateError('No element');
    return _data[endIndex];
  }

  @override
  T operator [](int index) => _data[_toDataIndex(index)];

  @override
  void operator []=(int index, T value) {
    _data[_toDataIndex(index)] = value;
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  T elementAt(int index) => _data[_toDataIndex(index)];

  @override
  List<T> sublist(int start, [int? end]) {
    final viewEnd = end ?? length;
    if (start < 0 || start > length) {
      throw RangeError.range(start, 0, length, 'start');
    }
    if (viewEnd < start || viewEnd > length) {
      throw RangeError.range(viewEnd, start, length, 'end');
    }
    return _data.sublist(
      startIndex + start,
      startIndex + viewEnd,
    );
  }

  @override
  Iterable<T> getRange(int start, int end) {
    if (start < 0 || start > length) {
      throw RangeError.range(start, 0, length, 'start');
    }
    if (end < start || end > length) {
      throw RangeError.range(end, start, length, 'end');
    }
    return _data.getRange(startIndex + start, startIndex + end);
  }

  @override
  int indexOf(T element, [int start = 0]) {
    final dataIndex = _data.indexOf(element, startIndex + start);
    if (dataIndex == -1 || dataIndex > endIndex) return -1;
    return _toViewIndex(dataIndex) ?? -1;
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    final searchStart =
        start == null ? endIndex : min(startIndex + start, endIndex);
    final dataIndex = _data.lastIndexOf(element, searchStart);
    if (dataIndex == -1 || dataIndex < startIndex) return -1;
    return _toViewIndex(dataIndex) ?? -1;
  }

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    for (int i = start; i < length; i++) {
      if (test(_data[startIndex + i])) return i;
    }
    return -1;
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    final searchStart = start ?? length - 1;
    for (int i = searchStart; i >= 0; i--) {
      if (test(_data[startIndex + i])) return i;
    }
    return -1;
  }

  @override
  bool contains(Object? element) {
    if (element is! T) return false;
    final dataIndex = _data.indexOf(element, startIndex);
    return dataIndex != -1 && dataIndex <= endIndex;
  }

  @override
  bool any(bool Function(T element) test) {
    for (int i = startIndex; i <= endIndex; i++) {
      if (test(_data[i])) return true;
    }
    return false;
  }

  @override
  bool every(bool Function(T element) test) {
    for (int i = startIndex; i <= endIndex; i++) {
      if (!test(_data[i])) return false;
    }
    return true;
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    for (int i = startIndex; i <= endIndex; i++) {
      if (test(_data[i])) return _data[i];
    }
    if (orElse != null) return orElse();
    throw StateError('No element');
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    for (int i = endIndex; i >= startIndex; i--) {
      if (test(_data[i])) return _data[i];
    }
    if (orElse != null) return orElse();
    throw StateError('No element');
  }

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    T? result;
    bool found = false;
    for (int i = startIndex; i <= endIndex; i++) {
      if (test(_data[i])) {
        if (found) throw StateError('Too many elements');
        result = _data[i];
        found = true;
      }
    }
    if (!found) {
      if (orElse != null) return orElse();
      throw StateError('No element');
    }
    return result!;
  }

  @override
  T get single {
    if (length == 0) throw StateError('No element');
    if (length > 1) throw StateError('Too many elements');
    return _data[startIndex];
  }

  @override
  Iterator<T> get iterator => _ViewIterator<T>(this);

  @override
  Iterable<T> get reversed =>
      _data.getRange(startIndex, endIndex + 1).toList().reversed;

  @override
  void forEach(void Function(T element) action) {
    for (int i = startIndex; i <= endIndex; i++) {
      action(_data[i]);
    }
  }

  @override
  Iterable<R> map<R>(R Function(T e) toElement) {
    return _data.getRange(startIndex, endIndex + 1).map(toElement);
  }

  @override
  Iterable<T> where(bool Function(T element) test) {
    return _data.getRange(startIndex, endIndex + 1).where(test);
  }

  @override
  Iterable<R> whereType<R>() {
    return _data.getRange(startIndex, endIndex + 1).whereType<R>();
  }

  @override
  Iterable<R> expand<R>(Iterable<R> Function(T element) toElements) {
    return _data.getRange(startIndex, endIndex + 1).expand(toElements);
  }

  @override
  R fold<R>(R initialValue, R Function(R previousValue, T element) combine) {
    R result = initialValue;
    for (int i = startIndex; i <= endIndex; i++) {
      result = combine(result, _data[i]);
    }
    return result;
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    if (isEmpty) throw StateError('No element');
    T result = _data[startIndex];
    for (int i = startIndex + 1; i <= endIndex; i++) {
      result = combine(result, _data[i]);
    }
    return result;
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    return _data.getRange(startIndex, endIndex + 1).followedBy(other);
  }

  @override
  Iterable<T> skip(int count) {
    return _data.getRange(startIndex, endIndex + 1).skip(count);
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    return _data.getRange(startIndex, endIndex + 1).skipWhile(test);
  }

  @override
  Iterable<T> take(int count) {
    return _data.getRange(startIndex, endIndex + 1).take(count);
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    return _data.getRange(startIndex, endIndex + 1).takeWhile(test);
  }

  @override
  List<T> toList({bool growable = true}) {
    return _data.sublist(startIndex, endIndex + 1);
  }

  @override
  Set<T> toSet() {
    return _data.getRange(startIndex, endIndex + 1).toSet();
  }

  @override
  Map<int, T> asMap() {
    final result = <int, T>{};
    for (int i = 0; i < length; i++) {
      result[i] = _data[startIndex + i];
    }
    return result;
  }

  @override
  String join([String separator = ""]) {
    return _data.getRange(startIndex, endIndex + 1).join(separator);
  }

  @override
  Timespan totalTimespan() {
    if (isEmpty) return Timespan(duration: Duration.zero);
    return Timespan(
      begin: _data[startIndex].time,
      end: _data[endIndex].time,
    );
  }

  // Mutation operations throw UnsupportedError as views should be read-only
  @override
  void add(T value) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void addAll(Iterable<T> iterable) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void insert(int index, T element) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  bool remove(Object? value) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  T removeAt(int index) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  T removeLast() {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void removeRange(int start, int end) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void removeWhere(bool Function(T element) test) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void retainWhere(bool Function(T element) test) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void clear() {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void shuffle([Random? random]) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  set first(T value) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  set last(T value) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }

  @override
  set length(int newLength) {
    throw UnsupportedError('Cannot modify an unmodifiable list view');
  }
}

/// Iterator for SortedTimeBoundDataListView
class _ViewIterator<T extends TimeBound> implements Iterator<T> {
  final SortedTimeBoundDataListView<T> _view;
  int _currentIndex = -1;

  _ViewIterator(this._view);

  @override
  T get current {
    if (_currentIndex < 0 || _currentIndex >= _view.length) {
      throw StateError('No current element');
    }
    return _view[_currentIndex];
  }

  @override
  bool moveNext() {
    if (_currentIndex + 1 < _view.length) {
      _currentIndex++;
      return true;
    }
    return false;
  }
}

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

  @Deprecated("Use getTimespanView unless you need a modifiable list")
  SortedTimeBoundDataList<T> getTimespan(Timespan timespan) {
    final startIndex = _data.getNearestIndexFromSorted(timespan.begin);
    final endIndex = _data.getNearestIndexFromSorted(timespan.end);
    return SortedTimeBoundDataListView(
        startIndex == null && endIndex == null
            ? []
            : _data.sublist(startIndex ?? 0, endIndex ?? _data.length - 1),
        isSorted: true);
  }

  SortedTimeBoundDataListView<T> getTimespanView(Timespan timespan) {
    final startIndex = _data.getNearestIndexFromSorted(timespan.begin);
    final endIndex = _data.getNearestIndexFromSorted(timespan.end);
    return SortedTimeBoundDataListView(
      this._data,
      startIndex: startIndex,
      endIndex: endIndex,
      isSorted: true,
    );
  }

  Timespan totalTimespan() {
    if (_data.isEmpty) return Timespan(duration: Duration.zero);
    return Timespan(
      begin: _data.first.time,
      end: _data.last.time,
    );
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
