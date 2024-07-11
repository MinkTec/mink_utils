import 'package:filterinio/filterinio.dart';

class FMath {
  /// https://stackoverflow.com/questions/47832475/check-if-cyclic-modulo-16-number-is-larger-than-another
  static bool cycliccomp(int a, int b, int mod, BinaryComparison comp,
          {int? maxStep}) =>
      comp.func<int, int, num>()((b + mod - a) % mod, (maxStep ?? mod ~/ 2));

  static BinaryComparison matchComp(
          {bool strict = false, bool increasing = true}) =>
      increasing
          ? strict
              ? BinaryComparison.gt
              : BinaryComparison.geq
          : strict
              ? BinaryComparison.le
              : BinaryComparison.leq;

  static int mod(int a, int mod) => a % mod;

  static bool modeq(int a, int b, int mod, BinaryComparison comp) =>
      comp.func<int, int, num>()(a % mod, b % mod);
}
