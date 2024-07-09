import 'package:mink_dart_utils/src/models/predicates.dart';

typedef BinaryCompFunc = bool Function(num a, num b);

typedef TernaryCompFunc = bool Function(num a, num b, num c);

enum BinaryComparison implements ComparisonEnum {
  gt,
  geq,
  le,
  leq,
  eq,
  neq,
  ;

  @override
  String get description => switch (this) {
        BinaryComparison.gt => "greater",
        BinaryComparison.geq => "greater or equal",
        BinaryComparison.le => "less",
        BinaryComparison.leq => "less or equal",
        BinaryComparison.eq => "equal",
        BinaryComparison.neq => "not equal",
      };

  @override
  String get enumName => name;

  BinaryCompFunc get func => switch (this) {
        BinaryComparison.gt => (num a, num b) => a > b,
        BinaryComparison.geq => (num a, num b) => a >= b,
        BinaryComparison.le => (num a, num b) => a < b,
        BinaryComparison.leq => (num a, num b) => a <= b,
        BinaryComparison.eq => (num a, num b) => a == b,
        BinaryComparison.neq => (num a, num b) => a != b
      };

  @override
  String get label => switch (this) {
        BinaryComparison.gt => ">",
        BinaryComparison.geq => ">=",
        BinaryComparison.le => "<",
        BinaryComparison.leq => "<=",
        BinaryComparison.eq => "==",
        BinaryComparison.neq => "!=",
      };

  Predicate<num> predicate(num reference) {
    return (num value) => func(value, reference);
  }
}

sealed class ComparisonEnum {
  String get description;
  String get enumName;
  String get label;
}

class FMath {
  /// https://stackoverflow.com/questions/47832475/check-if-cyclic-modulo-16-number-is-larger-than-another
  static bool cycliccomp(int a, int b, int mod, BinaryComparison comp,
          {int? maxStep}) =>
      comp.func((b + mod - a) % mod, (maxStep ?? mod ~/ 2));

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
      comp.func(a % mod, b % mod);
}

enum TernaryComparison implements ComparisonEnum {
  inside,
  insideEq,
  outside,
  outsideEq,
  ;

  @override
  String get description => switch (this) {
        TernaryComparison.inside => "between",
        TernaryComparison.insideEq => "between or equal",
        TernaryComparison.outside => "outside",
        TernaryComparison.outsideEq => "outside or equal"
      };

  @override
  String get enumName => name;

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

  @override
  String get label => switch (this) {
        TernaryComparison.inside => "< x <",
        TernaryComparison.insideEq => "<= x <=",
        TernaryComparison.outside => "> x <",
        TernaryComparison.outsideEq => ">= x =<"
      };

  Predicate<num> predicate(num lower, num upper) =>
      (num value) => func(value, lower, upper);
}
