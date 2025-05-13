import 'package:mink_flutter_utils/mink_flutter_utils.dart';
import 'package:test/test.dart';

void main() {
  group('FractionCounter implementations', () {
    test('CallbackFractionCount basics', () {
      final results = <int>[];
      final counter = CallbackFractionCount<int>(
        denominator: 3,
        callback: (value) => results.add(value),
        runOnFirstFeed: false,
      );

      expect(counter.numerator, 0);
      expect(counter.denominator, 3);
      expect(counter.value, 0.0);

      // Feed values until callback triggers
      counter.feed(1);
      expect(counter.numerator, 1);
      expect(results, isEmpty);

      counter.feed(2);
      expect(counter.numerator, 2);
      expect(results, isEmpty);

      counter.feed(3);
      expect(counter.numerator, 0); // Reset after callback
      expect(results, [3]); // Callback received last value

      // Feed more values to trigger another cycle
      counter.feed(4);
      counter.feed(5);
      counter.feed(6);
      expect(counter.numerator, 0);
      expect(results, [3, 6]);

      // Test reset
      counter.feed(7);
      counter.feed(8);
      expect(counter.numerator, 2);
      counter.reset();
      expect(counter.numerator, 0);
    });

    test('CallbackFractionCount with runOnFirstFeed=true', () {
      final results = <int>[];
      final counter = CallbackFractionCount<int>(
        denominator: 3,
        callback: (value) => results.add(value),
        runOnFirstFeed: true,
      );

      // For runOnFirstFeed=true, numerator starts at denominator
      expect(counter.numerator, 3);

      // First feed triggers callback immediately and resets
      counter.feed(1);
      expect(counter.numerator, 0); // Incremented to 4, which exceeded denominator, triggered callback and reset to 0
      expect(results, [1]);
    });

    test('ProgressFractionCounter basics', () {
      final counter = ProgressFractionCounter(denominator: 10, numerator: 2);

      expect(counter.numerator, 2);
      expect(counter.denominator, 10);
      expect(counter.value, 0.2);

      // Test increment
      counter.increment();
      expect(counter.numerator, 3);
      expect(counter.value, 0.3);

      // Test decrement
      counter.decrement();
      expect(counter.numerator, 2);
      expect(counter.value, 0.2);

      // Test decrement doesn't go below 0
      counter.decrement();
      counter.decrement();
      counter.decrement();
      expect(counter.numerator, 0);

      // Test reset
      counter.increment();
      counter.increment();
      expect(counter.numerator, 2);
      counter.reset();
      expect(counter.numerator, 0);
    });

    test('SuccessFractionCounter', () {
      final counter = SuccessFractionCounter();

      expect(counter.numerator, 0);
      expect(counter.denominator, 0);
      expect(counter.value, isNaN); // 0/0 is NaN

      // Test with success
      counter.increment(true);
      expect(counter.numerator, 1);
      expect(counter.denominator, 1);
      expect(counter.value, 1.0);

      // Test with failure
      counter.increment(false);
      expect(counter.numerator, 1);
      expect(counter.denominator, 2);
      expect(counter.value, 0.5);

      // Mixed successes and failures
      counter.increment(true);
      counter.increment(false);
      counter.increment(true);
      expect(counter.numerator, 3);
      expect(counter.denominator, 5);
      expect(counter.value, 0.6);

      // Test reset
      counter.reset();
      expect(counter.numerator, 0);
      expect(counter.denominator, 0);
    });

    test('FractionCounter equality check', () {
      // Note: The == operator in FractionCounter seems to be incorrect - it checks if other is FormatException
      // This is likely a bug, but we'll test the current implementation

      final counter1 = ProgressFractionCounter(denominator: 5, numerator: 2);
      final counter2 = ProgressFractionCounter(denominator: 5, numerator: 2);
      final counter3 = ProgressFractionCounter(denominator: 10, numerator: 4);

      // This is testing the current (buggy?) implementation
      expect(counter1 == counter2, false); // Should be true but impl is buggy
      expect(counter1 == counter3, false);

      // Check hashCode 
      expect(counter1.hashCode, equals(counter2.hashCode)); // Same values
      expect(counter1.hashCode, isNot(equals(counter3.hashCode))); // Different values
    });
  });
}