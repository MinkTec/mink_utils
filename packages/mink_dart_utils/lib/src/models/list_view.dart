/// Base class for immutable lists that wraps an underlying list.
/// This class implements [Iterable] and delegates all operations to the underlying list.
class ImmutableList<E> implements Iterable<E> {
  final List<E> _list;

  /// Creates an immutable list from the given list.
  /// The list is copied to prevent external modifications.
  ImmutableList(List<E> list) : _list = List.unmodifiable(list);

  /// Creates an immutable list from an iterable.
  ImmutableList.from(Iterable<E> iterable)
      : _list = List.unmodifiable(iterable);

  /// Creates an empty immutable list.
  ImmutableList.empty() : _list = const [];

  /// Gets the element at the specified index.
  E operator [](int index) => _list[index];

  @override
  bool any(bool Function(E element) test) => _list.any(test);

  @override
  Iterable<R> cast<R>() => _list.cast<R>();

  @override
  bool contains(Object? element) => _list.contains(element);

  @override
  E elementAt(int index) => _list.elementAt(index);

  @override
  bool every(bool Function(E element) test) => _list.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) =>
      _list.expand(toElements);

  @override
  E get first => _list.first;

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _list.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) =>
      _list.fold(initialValue, combine);

  @override
  Iterable<E> followedBy(Iterable<E> other) => _list.followedBy(other);

  @override
  void forEach(void Function(E element) action) => _list.forEach(action);

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterator<E> get iterator => _list.iterator;

  @override
  String join([String separator = ""]) => _list.join(separator);

  @override
  E get last => _list.last;

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _list.lastWhere(test, orElse: orElse);

  @override
  int get length => _list.length;

  @override
  Iterable<T> map<T>(T Function(E e) toElement) => _list.map(toElement);

  @override
  E reduce(E Function(E value, E element) combine) => _list.reduce(combine);

  @override
  E get single => _list.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _list.singleWhere(test, orElse: orElse);

  @override
  Iterable<E> skip(int count) => _list.skip(count);

  @override
  Iterable<E> skipWhile(bool Function(E value) test) => _list.skipWhile(test);

  @override
  Iterable<E> take(int count) => _list.take(count);

  @override
  Iterable<E> takeWhile(bool Function(E value) test) => _list.takeWhile(test);

  @override
  List<E> toList({bool growable = true}) => _list.toList(growable: growable);

  @override
  Set<E> toSet() => _list.toSet();

  @override
  Iterable<E> where(bool Function(E element) test) => _list.where(test);

  @override
  Iterable<T> whereType<T>() => _list.whereType<T>();

  @override
  String toString() => _list.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImmutableList<E>) return false;
    if (runtimeType != other.runtimeType) return false;
    if (_list.length != other._list.length) return false;

    for (int i = 0; i < _list.length; i++) {
      if (_list[i] != other._list[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    int hash = 0;
    for (final item in _list) {
      hash = hash ^ item.hashCode;
    }
    return hash;
  }
}

/// A view of a list that provides immutable access to a range of elements.
/// Unlike [ImmutableList], this class provides a view into an underlying list
/// using start and end indices, similar to a sublist but without copying.
class ImmutableListView<E> extends ImmutableList<E> {
  final int startIndex;
  final int endIndex;

  /// Creates a list view from the given list with optional start and end indices.
  /// The indices define the visible range of the list.
  ImmutableListView(
    List<E> list, {
    int? startIndex,
    int? endIndex,
  })  : startIndex = startIndex ?? 0,
        endIndex = endIndex ?? list.length - 1,
        super(list);

  /// Creates a list view from an iterable.
  ImmutableListView.from(
    Iterable<E> iterable, {
    int? startIndex,
    int? endIndex,
  })  : startIndex = startIndex ?? 0,
        endIndex = endIndex ?? iterable.length - 1,
        super.from(iterable);

  /// Creates an empty list view.
  ImmutableListView.empty()
      : startIndex = 0,
        endIndex = -1,
        super.empty();

  /// Translates a view index to the underlying data index
  int _toDataIndex(int viewIndex) {
    if (viewIndex < 0 || viewIndex >= length) {
      throw RangeError.index(viewIndex, this, 'index', null, length);
    }
    return startIndex + viewIndex;
  }

  @override
  int get length {
    if (endIndex < startIndex) return 0;
    return endIndex - startIndex + 1;
  }

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => length > 0;

  @override
  E get first {
    if (isEmpty) throw StateError('No element');
    return _list[startIndex];
  }

  @override
  E get last {
    if (isEmpty) throw StateError('No element');
    return _list[endIndex];
  }

  @override
  E operator [](int index) => _list[_toDataIndex(index)];

  @override
  E elementAt(int index) => _list[_toDataIndex(index)];

  @override
  bool contains(Object? element) {
    if (element is! E) return false;
    for (int i = startIndex; i <= endIndex; i++) {
      if (_list[i] == element) return true;
    }
    return false;
  }

  @override
  bool any(bool Function(E element) test) {
    for (int i = startIndex; i <= endIndex; i++) {
      if (test(_list[i])) return true;
    }
    return false;
  }

  @override
  bool every(bool Function(E element) test) {
    for (int i = startIndex; i <= endIndex; i++) {
      if (!test(_list[i])) return false;
    }
    return true;
  }

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    for (int i = startIndex; i <= endIndex; i++) {
      if (test(_list[i])) return _list[i];
    }
    if (orElse != null) return orElse();
    throw StateError('No element');
  }

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    for (int i = endIndex; i >= startIndex; i--) {
      if (test(_list[i])) return _list[i];
    }
    if (orElse != null) return orElse();
    throw StateError('No element');
  }

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    E? result;
    bool found = false;
    for (int i = startIndex; i <= endIndex; i++) {
      if (test(_list[i])) {
        if (found) throw StateError('Too many elements');
        result = _list[i];
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
  E get single {
    if (length == 0) throw StateError('No element');
    if (length > 1) throw StateError('Too many elements');
    return _list[startIndex];
  }

  @override
  Iterator<E> get iterator => _ListViewIterator<E>(this);

  @override
  void forEach(void Function(E element) action) {
    for (int i = startIndex; i <= endIndex; i++) {
      action(_list[i]);
    }
  }

  @override
  Iterable<R> map<R>(R Function(E e) toElement) {
    return _getRange().map(toElement);
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    return _getRange().where(test);
  }

  @override
  Iterable<R> whereType<R>() {
    return _getRange().whereType<R>();
  }

  @override
  Iterable<R> expand<R>(Iterable<R> Function(E element) toElements) {
    return _getRange().expand(toElements);
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    T result = initialValue;
    for (int i = startIndex; i <= endIndex; i++) {
      result = combine(result, _list[i]);
    }
    return result;
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    if (isEmpty) throw StateError('No element');
    E result = _list[startIndex];
    for (int i = startIndex + 1; i <= endIndex; i++) {
      result = combine(result, _list[i]);
    }
    return result;
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    return _getRange().followedBy(other);
  }

  @override
  Iterable<E> skip(int count) {
    return _getRange().skip(count);
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    return _getRange().skipWhile(test);
  }

  @override
  Iterable<E> take(int count) {
    return _getRange().take(count);
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    return _getRange().takeWhile(test);
  }

  @override
  List<E> toList({bool growable = true}) {
    if (isEmpty) return growable ? <E>[] : List<E>.empty(growable: false);
    return _list.sublist(startIndex, endIndex + 1);
  }

  @override
  Set<E> toSet() {
    return _getRange().toSet();
  }

  @override
  String join([String separator = ""]) {
    return _getRange().join(separator);
  }

  @override
  Iterable<R> cast<R>() {
    return _getRange().cast<R>();
  }

  /// Helper method to get the range as an iterable
  Iterable<E> _getRange() {
    if (isEmpty) return const Iterable.empty();
    return _list.getRange(startIndex, endIndex + 1);
  }

  @override
  String toString() {
    if (isEmpty) return '[]';
    return '[${_getRange().join(', ')}]';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImmutableListView<E>) return false;
    if (runtimeType != other.runtimeType) return false;
    if (startIndex != other.startIndex) return false;
    if (endIndex != other.endIndex) return false;
    if (_list.length != other._list.length) return false;

    // Compare only the underlying list elements (not indices)
    for (int i = 0; i < _list.length; i++) {
      if (_list[i] != other._list[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    int hash = Object.hash(startIndex, endIndex);
    for (final item in _list) {
      hash = hash ^ item.hashCode;
    }
    return hash;
  }
}

/// Iterator for ListView
class _ListViewIterator<E> implements Iterator<E> {
  final ImmutableListView<E> _view;
  int _currentIndex = -1;

  _ListViewIterator(this._view);

  @override
  E get current {
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
