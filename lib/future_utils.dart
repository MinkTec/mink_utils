import 'dart:async';

/// A Future Wrapper that completes in a minimum amount of time
class TimerFutureWrapper<T> {
  Future<T> future;
  late Future<T> completerFuture;
  Duration minDuration;
  bool taskCompleted = false;
  bool timerCompleted = false;

  TimerFutureWrapper({required this.future, required this.minDuration}) {
    completerFuture = timedFuture();
  }

  Future<T> timedFuture() async {
    final completer = Completer<T>();
    Timer(minDuration, () async {
      if (taskCompleted) completer.complete();
      timerCompleted = true;
    });
    future.then((value) {
      taskCompleted = true;
      if (timerCompleted) completer.complete();
    });
    return completer.future;
  }
}
