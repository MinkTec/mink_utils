import 'package:mink_dart_utils/src/models/predicates.dart';

typedef BinaryCompFunc = bool Function(num a, num b);

typedef TernaryCompFunc = bool Function(num a, num b, num c);

sealed class ComparisonEnum {}

enum BinaryComparison implements ComparisonEnum {
  gt,
  geq,
  le,
  leq,
  eq,
  neq,
  ;

  BinaryCompFunc get func => switch (this) {
        BinaryComparison.gt => (num a, num b) => a > b,
        BinaryComparison.geq => (num a, num b) => a >= b,
        BinaryComparison.le => (num a, num b) => a < b,
        BinaryComparison.leq => (num a, num b) => a <= b,
        BinaryComparison.eq => (num a, num b) => a == b,
        BinaryComparison.neq => (num a, num b) => a != b
      };

  Predicate<num> predicate(num reference) {
    return (num value) => func(value, reference);
  }
}

enum TernaryComparison {
  inside,
  insideEq,
  outside,
  outsideEq,
  ;

  Predicate<num> predicate(num lower, num upper) =>
      (num value) => func(value, lower, upper);

  TernaryCompFunc get func => switch (this) {
        TernaryComparison.inside => (
            num a,
            num b,
            num c,
          ) =>
              b < a && a < c,
        TernaryComparison.insideEq => (
            num a,
            num b,
            num c,
          ) =>
              b <= a && a <= c,
        TernaryComparison.outside => (
            num a,
            num b,
            num c,
          ) =>
              a < b || a > c,
        TernaryComparison.outsideEq => (
            num a,
            num b,
            num c,
          ) =>
              a <= b || a >= c,
      };
}

class FMath {
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

  /// https://stackoverflow.com/questions/47832475/check-if-cyclic-modulo-16-number-is-larger-than-another
  static bool cycliccomp(int a, int b, int mod, BinaryComparison comp,
          {int? maxStep}) =>
      comp.func((b + mod - a) % mod, (maxStep ?? mod ~/ 2));

  static bool modeq(int a, int b, int mod, BinaryComparison comp) =>
      comp.func(a % mod, b % mod);
}
