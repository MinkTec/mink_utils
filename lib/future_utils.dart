import 'dart:async';

/// A Future Wrapper that completes in a minimum amount of time
class TimerFutureWrapper<T> {
  Future<bool> future;
  late Future<bool> completerFuture;
  Duration minDuration;
  bool taskCompleted = false;
  bool timerCompleted = false;
  bool success = false;

  TimerFutureWrapper({required this.future, required this.minDuration}) {
    completerFuture = timedFuture();
  }

  Future<bool> timedFuture() async {
    final completer = Completer<bool>();
    Timer(minDuration, () async {
      if (taskCompleted) completer.complete(success);
      timerCompleted = true;
    });
    future.then((value) {
      taskCompleted = true;
      success = value;
      if (timerCompleted) {
        completer.complete(success);
      }
    });
    return completer.future;
  }
}
