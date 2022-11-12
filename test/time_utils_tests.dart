import 'package:flutter_test/flutter_test.dart';
import 'package:mink_utils/time_utils.dart';

void main() {
  group("Time", () {
    test("DateTime extensions", () {
      final t1 = DateTime(2022, 5, 4);
      final t2 = DateTime(2022, 5, 8);
      final t3 = DateTime(2022, 5, 17);

      expect(t2.isBetween(t1, t3), true);
      expect(t1.isBetween(t2, t3), false);
      expect(t3.isBetween(t1, t2), false);

      expect(t2.isBetween(t2, t2), false);
      expect(t2.isBetween(t2, t3), false);
      expect(t2.isBetween(t1, t2), false);

      expect(t2.getClosest(t1, t3), t1);
      expect(t2.laterDate(t1), t2);
      expect(t2.earlierDate(t1), t1);

      expect(t1.add(const Duration(hours: 8)).midnight(), t1);
    });

    test("Duration extensions", () {
      const d1 = Duration(minutes: 1);
      const d2 = Duration(minutes: 2);
      const d3 = Duration(minutes: -1);

      expect(d1.max(d2), d2);
      expect(d2.max(d3), d2);
      expect(d1.min(d3), d3);
      expect(d1.min(d2), d1);
    });

    test("List<DateTime> findBlocks", () {
      final t1 = List<DateTime>.generate(100, (i) => DateTime(2020, 5, 5, i));
      final t2 = [
        DateTime(1910),
        DateTime(1970),
        DateTime(1971),
        DateTime(1972),
        DateTime(1975),
        DateTime(1976),
        DateTime(1977),
        DateTime(1980),
        DateTime(1981),
        DateTime(1982),
        DateTime(1983),
        DateTime(1985),
        DateTime(1986),
      ];

      expect(t1.findBlocks(const Duration(minutes: 1)).toList().length, 100);
      expect(t1.findBlocks(const Duration(days: 1)).toList().length, 1);
      expect(t2.findBlocks(const Duration(days: 366)).map((e) => e.begin.year),
          [1910, 1970, 1975, 1980, 1985]);
    });

    test("DateTime from list of int", () {
        expect([1970,1,1,0,1].toDateTime(), DateTime(1970,1,1,0,1));
        expect([1970].toDateTime(), DateTime(1970));
        expect([1970,27,1,0,1,5].toDateTime(), DateTime(1970,27,1,0,1,5));
    });
  });
}
