import 'package:mink_utils/mink_utils.dart';
import 'package:test/test.dart';

main() {
  group("time bound extensions", () {
    final ref = DateTime(2022);

    const n = 1000;

    final data = List<TimedData<int>>.generate(
        6 * n,
        (i) => TimedData(
              time: ref.add(Duration(minutes: 10 * i)),
              value: i,
            ));

    test("hour", () {
      final res = data.groupBy(group: SplitType.hour);
      expect(res.length, n);
      expect(res.every((x) => x.value.length == 6), true);
    });

    test("day", () {
      final res = data.groupBy(group: SplitType.day);

      for (var (a, b) in res
          .mapReduce(
            map: (x) => x.value,
            reduce: (a, b) => a + b,
          )
          .skipLast(1)
          .lag) {
        expect(a.value < b.value, true);
      }

      expect(res.length, (n / 24).ceil());
      expect(res.skipLast(1).every((x) => x.value.length == 144), true);
    });

    test("total", () {
      final res = data.groupBy(group: SplitType.total);
      expect(res.length, 1);
      expect(res.first.value.length, data.length);
    });
  });
}
