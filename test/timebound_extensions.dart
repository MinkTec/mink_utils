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

    test("includeEmpty with sparse data", () {
      // Create data with gaps: only first and last day have data
      final sparseData = [
        TimedData(time: ref, value: 1),
        TimedData(time: ref.add(Duration(days: 6)), value: 2),
      ];
      
      final testTimespan = Timespan(
        begin: ref,
        duration: Duration(days: 7),
      );

      // Without includeEmpty, should only return days with data
      final resWithoutEmpty = sparseData.groupBy(
        group: SplitType.day,
        timespan: testTimespan,
        includeEmpty: false,
      );
      expect(resWithoutEmpty.length, 2);
      expect(resWithoutEmpty.every((x) => x.value.isNotEmpty), true);

      // With includeEmpty, should return all 7 days
      final resWithEmpty = sparseData.groupBy(
        group: SplitType.day,
        timespan: testTimespan,
        includeEmpty: true,
      );
      expect(resWithEmpty.length, 7);
      expect(resWithEmpty.where((x) => x.value.isEmpty).length, 5);
      expect(resWithEmpty.where((x) => x.value.isNotEmpty).length, 2);
    });

    test("includeEmpty with empty list and explicit timespan", () {
      final emptyData = <TimedData<int>>[];
      final testTimespan = Timespan(
        begin: ref,
        duration: Duration(days: 5),
      );

      // Without includeEmpty, should return empty list
      final resWithoutEmpty = emptyData.groupBy(
        group: SplitType.day,
        timespan: testTimespan,
        includeEmpty: false,
      );
      expect(resWithoutEmpty.length, 0);

      // With includeEmpty and explicit timespan, should return all days
      final resWithEmpty = emptyData.groupBy(
        group: SplitType.day,
        timespan: testTimespan,
        includeEmpty: true,
      );
      expect(resWithEmpty.length, 5);
      expect(resWithEmpty.every((x) => x.value.isEmpty), true);
    });
  });
}
