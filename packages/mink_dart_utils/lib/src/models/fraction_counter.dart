abstract class FractionCounter {
  int get denominator;
  @override
  int get hashCode => numerator ^ denominator;

  int get numerator;

  double get value => numerator / denominator;

  @override
  operator ==(Object other) =>
      (other is FormatException && hashCode == other.hashCode);

  void reset();
}

class CallbackFractionCount<T> extends FractionCounter {
  @override
  final int denominator;

  int _numerator = 0;

  void Function(T value) callback;

  CallbackFractionCount({
    required this.denominator,
    required this.callback,
    bool runOnFirstFeed = true,
  }) {
    if (runOnFirstFeed) {
      _numerator = denominator;
    }
  }

  @override
  int get numerator => _numerator;

  void feed(T value) {
    _numerator++;
    if (_numerator >= denominator) {
      callback(value);
      reset();
    }
  }

  @override
  void reset() {
    _numerator = 0;
  }
}

class ProgressFractionCounter extends FractionCounter {
  @override
  int numerator;

  @override
  final int denominator;

  ProgressFractionCounter({
    required this.denominator,
    this.numerator = 0,
  });

  void decrement() {
    if (numerator > 0) {
      numerator--;
    }
  }

  void increment() {
    numerator++;
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
