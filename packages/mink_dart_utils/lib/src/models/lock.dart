class AsyncLock<T> {
  bool _locked = false;

  final T _value;

  AsyncLock(this._value);

  Future<T> get wait async {
    while (_locked) {
      await Future.delayed(Duration(milliseconds: 1));
    }
    return _value;
  }

  lock() {
    _locked = true;
  }

  unlock() {
    _locked = false;
  }

  bool get isLocked => _locked;
}
