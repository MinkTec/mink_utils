import 'dart:async';
import 'dart:collection';

/// Fills a queue with elements of type [T].
/// When the Queue has reached [length == size] the
/// [onFilled] callback is run.
/// If no elements are added for [timeout] Duration
/// [onFilled] is called with all elements
/// currently in the buffer and the buffer is cleared.
class TimeoutBuffer<T> {
  final Duration timeout;
  final int size;
  final Function(List<T> data) onFilled;

  final Queue<T> _data = Queue();

  TimeoutBuffer({
    required this.size,
    required this.timeout,
    required this.onFilled,
  });

  Timer? _triggerTimer;

  add(T elem) {
    _data.add(elem);

    if (_data.length >= size) {
      _runAndClear();
    } else {
      _updateTimer();
    }
  }

  _updateTimer() {
    _triggerTimer?.cancel();
    _triggerTimer = Timer(timeout, _runAndClear);
  }

  _runAndClear() {
    onFilled([..._data]);
    _data.clear();
  }
}
