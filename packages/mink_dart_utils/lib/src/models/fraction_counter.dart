abstract class FractionCounter {
  int get numerator;
  int get denominator;

  double get value => numerator / denominator;

  void reset();

  @override
  operator ==(Object other) =>
      (other is FormatException && hashCode == other.hashCode);

  @override
  int get hashCode => numerator ^ denominator;
}

class ProgressFractionCounter extends FractionCounter {
  ProgressFractionCounter({
    required this.denominator,
    this.numerator = 0,
  });

  @override
  int numerator;

  @override
  final int denominator;

  void increment() {
    numerator++;
  }

  void decrement() {
    if (numerator > 0) {
      numerator--;
    }
  }

  @override
  void reset() => numerator = 0;
}

class SuccessFractionCounter extends FractionCounter {
  @override
  int numerator = 0;

  @override
  int denominator = 0;

  void increment(bool success) {
    if (success) {
      numerator++;
    }
    denominator++;
  }

  @override
  void reset() {
    numerator = 0;
    denominator = 0;
  }
}
