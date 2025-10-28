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
  final FutureOr<void> Function(List<T> data) onFilled;

  final Queue<T> data = Queue();

  TimeoutBuffer({
    required this.size,
    required this.timeout,
    required this.onFilled,
  });

  Timer? _triggerTimer;

  void add(T elem) {
    data.add(elem);
    _checkOnFilledExecution();
  }

  void addAll(Iterable<T> elements) {
    data.addAll(elements);
    _checkOnFilledExecution();
  }

  FutureOr<void> flush() {
    if (data.isNotEmpty) {
      _triggerTimer?.cancel();
      return _runAndClear();
    } else {
      return null;
    }
  }

  FutureOr<void> _checkOnFilledExecution() {
    if (data.length >= size) {
      _triggerTimer?.cancel();
      return _runAndClear();
    } else {
      _updateTimer();
    }
  }

  void _updateTimer() {
    _triggerTimer?.cancel();
    _triggerTimer = Timer(timeout, _runAndClear);
  }

  Future<void> _runAndClear() async {
    if (data.isEmpty) return;
    final dataToProcess = [...data];
    data.clear();
    await onFilled(dataToProcess);
  }
}
