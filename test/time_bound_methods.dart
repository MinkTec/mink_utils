import 'dart:math' as math;
import 'package:mink_utils/mink_utils.dart';
import 'package:test/test.dart';

class TB with TimeBound {
  @override
  DateTime time;

  TB(this.time);

  @override
  String toString() => time.toString();
}

void main() {
  final now = DateTime.now();

  final linear =
      range(last: 100).eagerMap((i) => TB(now.add(Duration(seconds: i))));

  final randomized = range(last: 100).eagerMap(
      (e) => now.add(Duration(minutes: e, seconds: math.Random().nextInt(60))));

  group("reduceToDelta", () {
    test("basic", () {
      expect(linear.reduceToDelta(const Duration(seconds: 10)).length, 11);
      expect(randomized.reduceToDelta(const Duration(minutes: 10)).length, 10);
    });
  });

  group("take equally spaced", () {
    const n = 5;

    test("linear", () {
      final selected = TimeBoundMethods.takeEqualySpaced(linear, n);
      final diffs = selected.time.diff();

      expect(selected.length, n + 1);
      expect(diffs.every((e) => diffs.first == e), true);
    });

    test("randomized", () {
      final tb = randomized.eagerMap((e) => TB(e));
      final selected =
          TimeBoundMethods.takeEqualySpaced(tb, n).time.sortedNormal();

      expect(selected.length, n);

      final other = tb.takeEqualySpaced(n).toList().time.sortedNormal();

      print(selected);
      print(other);

      for (var (a, b) in selected.zip(other)) {
        expect(a, b);
      }

      //expect(listEquals(tb, tb.takeEqualySpaced(n).toList()), true);
    });
  });
}
