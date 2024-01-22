extension BigIfTrue<T, S> on Map<T, S> {
  Map<T, S> copy() {
    final Map<T, S> map = {};
    map.addAll(this);
    return map;
  }

  Map<T, S> addIfNew(Iterable<T> keys, S val) {
    final map = copy();
    for (var key in keys) {
      if (!containsKey(key)) {
        map[key] = val;
      }
    }
    return map;
  }

  /// createds a copy of [this]
  Map<T, S> combined(Map<T, S> other) {
    final newDict = copy();
    newDict.addAll(other);
    return newDict;
  }
}
