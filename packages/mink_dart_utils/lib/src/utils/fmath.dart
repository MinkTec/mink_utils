import 'package:mink_dart_utils/src/models/predicates.dart';

typedef BinaryCompFunc<R extends S, T extends S, S extends Comparable<S>> = bool
    Function(R a, T b);

typedef TernaryCompFunc<Q extends T, R extends T, S extends T,
        T extends Comparable<T>>
    = bool Function(Q a, R b, S c);

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

  BinaryCompFunc<R, T, S>
      func<R extends S, T extends S, S extends Comparable<S>>() =>
          switch (this) {
            BinaryComparison.gt => (R a, T b) => a.compareTo(b) > 0,
            BinaryComparison.geq => (R a, T b) => a.compareTo(b) >= 0,
            BinaryComparison.le => (R a, T b) => a.compareTo(b) < 0,
            BinaryComparison.leq => (R a, T b) => a.compareTo(b) <= 0,
            BinaryComparison.eq => (R a, T b) => a.compareTo(b) == 0,
            BinaryComparison.neq => (R a, T b) => a.compareTo(b) != 0,
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

  Predicate<R> predicate<R extends S, T extends S, S extends Comparable<S>>(
      T reference) {
    return (R value) => func<R, T, S>()(value, reference);
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

  TernaryCompFunc<Q, R, T, S>
      func<Q extends S, R extends S, T extends S, S extends Comparable<S>>() =>
          switch (this) {
            TernaryComparison.inside => (Q a, R b, T c) =>
                a.compareTo(b) > 0 && a.compareTo(c) < 0,
            TernaryComparison.insideEq => (Q a, R b, T c) =>
                a.compareTo(b) >= 0 && a.compareTo(c) <= 0,
            TernaryComparison.outside => (Q a, R b, T c) =>
                a.compareTo(b) < 0 || a.compareTo(c) > 0,
            TernaryComparison.outsideEq => (Q a, R b, T c) =>
                a.compareTo(b) <= 0 || a.compareTo(c) >= 0,
          };

  @override
  String get label => switch (this) {
        TernaryComparison.inside => "< x <",
        TernaryComparison.insideEq => "<= x <=",
        TernaryComparison.outside => "> x <",
        TernaryComparison.outsideEq => ">= x =<"
      };

  Predicate<Q>
      predicate<Q extends S, R extends S, T extends S, S extends Comparable<S>>(
              R lower, T upper) =>
          (Q value) => func<Q, R, T, S>()(value, lower, upper);
}
