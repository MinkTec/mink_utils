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

extension FiniteDouble on double {
  /// return 0.0 if this.isFinite is false
  double get finite => isFinite ? this : 0.0;
}

extension FiniteNum on num {
  /// return 0.0 if this.isFinite is false
  num get finite => isFinite ? this : 0.0;
}
