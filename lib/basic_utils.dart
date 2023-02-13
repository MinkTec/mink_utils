import 'dart:async';

T id<T>(T a) => a;

Future<void> sleep(Duration d) {
  final c = Completer<void>();
  Timer(d, () => c.complete());
  return c.future;
}

Future<void> sleepms(int ms) {
  final c = Completer<void>();
  Timer(Duration(milliseconds: ms), () => c.complete());
  return c.future;
}
