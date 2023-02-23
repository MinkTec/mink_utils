import 'package:flutter_test/flutter_test.dart';
import 'package:mink_utils/classes/timespan.dart';
import 'package:mink_utils/time_utils.dart';
import 'dart:io' show File;

List<DateTime> readTestData() => File("./test/measurements.csv")
    .readAsLinesSync()
    .map((e) =>
        DateTime.fromMillisecondsSinceEpoch(int.parse(e.split(",").last)))
    .toList();

void main() {
  group("Time", () {
    test("DateTime extensions", () {
      final t1 = DateTime(2022, 5, 4);
      final t2 = DateTime(2022, 5, 8);
      final t3 = DateTime(2022, 5, 17);

      expect(t2.isBetween(t1, t3), true);
      expect(t1.isBetween(t2, t3), false);
      expect(t3.isBetween(t1, t2), false);

      expect(t2.isBetween(t2, t2), true);
      expect(t2.isBetween(t2, t2, strict: true), false);
      expect(t2.isBetween(t2, t3, strict: true), false);
      expect(t2.isBetween(t1, t2), true);

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

      final t3 = readTestData();

      expect(t1.findBlocks(const Duration(minutes: 1)).toList().length, 100);
      expect(t1.findBlocks(const Duration(days: 1)).toList().length, 1);
      expect(t2.findBlocks(const Duration(days: 366)).map((e) => e.begin.year),
          [1910, 1970, 1975, 1980, 1985]);
      expect(t3.findBlocks(const Duration(seconds: 6)).length, 14);
      expect(
          t3
              .findBlocks(const Duration(seconds: 6))
              .any((e) => e.duration == Duration.zero),
          false);
    });

    test("DateTime from list of int", () {
      expect([1970, 1, 1, 0, 1].toDateTime(), DateTime(1970, 1, 1, 0, 1));
      expect([22].toDateTime(), DateTime(2022));
      expect(
          [1970, 27, 1, 0, 1, 5].toDateTime(), DateTime(1970, 27, 1, 0, 1, 5));
    });

    const m5 = Duration(minutes: 5);
    final span1 =
        Timespan(duration: const Duration(minutes: 10), end: DateTime(2021));
    final span2 = Timespan(
        duration: const Duration(minutes: 10),
        end: DateTime(2021).subtract(m5));
    final span3 = Timespan.arround(DateTime(2021), m5);

    final t1 = DateTime(2021).subtract(m5);

    test("timespan", () {
      expect(span1.cut(t1).first.duration, m5);
      expect(span1.cut(t1).last.duration, m5);

      expect(span1.intersection(span2), Timespan(end: t1, duration: m5));

      expect(Timespan.arround(t1, m5), span1);

      expect(span1.weeks.length, 1);
      expect(span3.weeks.length, 1);
      expect(span3.month.length, 2);
      expect(span3.years.length, 2);
    });


    final short = Timespan.arround(DateTime.now(), const Duration(milliseconds: 1));

    test("timespan conditions", () {
      expect(span1.intersects(span2), true);
      expect(Timespan.today().isToday, true);
      expect(Timespan.today().contains(short), true);
      expect(short.isToday, true);
    });
  });
}
