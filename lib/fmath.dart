enum FComp {
  gt,
  geq,
  le,
  leq,
  eq,
  neq;
}

typedef FCompFunc = bool Function(num a, num b);

extension FCompFuncs on FComp {
  FCompFunc get func {
    switch (this) {
      case FComp.gt:
        return (num a, num b) => a > b;
      case FComp.geq:
        return (num a, num b) => a >= b;
      case FComp.le:
        return (num a, num b) => a < b;
      case FComp.leq:
        return (num a, num b) => a <= b;
      case FComp.eq:
        return (num a, num b) => a == b;
      case FComp.neq:
        return (num a, num b) => a != b;
    }
  }
}

class FMath {
  static FComp matchComp({bool strict = false, bool increasing = true}) =>
      increasing
          ? strict
              ? FComp.gt
              : FComp.geq
          : strict
              ? FComp.le
              : FComp.leq;

  static int mod(int a, int mod) => a % mod;

  /// https://stackoverflow.com/questions/47832475/check-if-cyclic-modulo-16-number-is-larger-than-another
  static bool cycliccomp(int a, int b, int mod, FComp comp, {int? maxStep}) =>
      comp.func((b + mod - a) % mod, (maxStep ?? mod ~/ 2));

  static bool modeq(int a, int b, int mod, FComp comp) =>
      comp.func(a % mod, b % mod);
}
