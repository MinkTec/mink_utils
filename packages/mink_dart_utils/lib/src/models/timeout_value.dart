import 'dart:async';

class TimeoutValue<T> {
  T _value;
  final Duration timeout;
  final Function(T value) onTimeout;

  TimeoutValue({
    required T value,
    required this.timeout,
    required this.onTimeout,
  }) : _value = value;

  Timer? _triggerTimer;

  T get value => _value;

  set value(T value) {
    _value = value;
    _updateTimer();
  }

  _updateTimer() {
    _triggerTimer?.cancel();
    _triggerTimer = Timer(timeout, () => onTimeout(_value));
  }
}

class CountingTimeoutValue<T> extends TimeoutValue<T> {
  int _count = 0;
  final int countLimit;

  CountingTimeoutValue({
    required super.value,
    required super.timeout,
    required super.onTimeout,
    required this.countLimit,
  });

  @override
  set value(T newValue) {
    super.value = newValue;
    _count++;
    if (_count >= countLimit) {
      _count = 0;
      onTimeout(newValue);
    }
  }
}
