import 'dart:math';

extension TrigNum<T extends num> on T {
  double toRad() => this * pi / 180;
  double toDeg() => this * 180 / pi;

  T clamp(T n, T lower, T upper) => max(min(n, upper), lower);

  String get disp {
    final string = toStringAsFixed(0);
    return string == "-0" ? string.replaceAll("-", "") : string;
  }

  String get trigDisp {
    final string = toDeg().toStringAsFixed(0);
    return """${string == "-0" ? string.replaceAll("-", "") : string}°""";
  }

  /// return 0.0 if this.isFinite is false
  num get finite => isFinite ? this : 0.0;
}
