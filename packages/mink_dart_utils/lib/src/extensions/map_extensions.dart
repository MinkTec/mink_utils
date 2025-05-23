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

  void addIfNotNull(T key, S? val) {
    if (val != null) {
      this[key] = val;
    }
  }

  Map<T, S> doublesToStringAsFixed(int places) {
    final map = copy();
    map.forEach((key, value) {
      if (value is double) {
        map[key] = value.toStringAsFixed(places) as S;
      } else if (value is Map) {
        map[key] = (value as Map).doublesToStringAsFixed(places) as S;
      } else if (value is List) {
        map[key] = (value).map((e) {
          if (e is double) {
            return e.toStringAsFixed(places);
          } else if (e is Map) {
            return e.doublesToStringAsFixed(places);
          } else {
            return e;
          }
        }).toList() as S;
      }
    });
    return map;
  }

  Map<T, S> replaceNanWithZero() {
    final map = copy();
    map.forEach((key, value) {
      if (value is double && (value.isNaN || value.isInfinite)) {
        map[key] = -1.0 as S;
      } else if (value is Map) {
        map[key] = (value as Map).replaceNanWithZero() as S;
      } else if (value is List) {
        map[key] = (value).map((e) {
          if (e is double && (e.isNaN || e.isInfinite)) {
            return -1.0;
          } else if (e is Map) {
            return e.replaceNanWithZero();
          } else {
            return e;
          }
        }).toList() as S;
      }
    });
    return map;
  }
}

extension NumericMapExtensions<T> on Map<T, int> {
  void increment(T key) => add(key, 1);

  void decrement(T key) => add(key, -1);

  void add(T key, int value) {
    this[key] ??= 0;
    this[key] = this[key]! + value;
  }
}
