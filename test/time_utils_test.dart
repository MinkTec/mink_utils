import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'dart:io' show File;

import 'package:test/test.dart';

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

    final short =
        Timespan.arround(DateTime.now(), const Duration(milliseconds: 1));

    test("timespan conditions", () {
      expect(span1.intersects(span2), true);
      expect(Timespan.today().isToday, true);
      expect(span1.isToday, false);
      expect(Timespan.today().contains(short), true);
      expect(short.isToday, true);
      expect(
          Timespan(
              begin: DateTime(1993, 8, 16, 4, 0),
              end: DateTime(1993, 8, 16, 17, 0)),
          Timespan.fromOClock(
              from: 4, to: 17, reference: DateTime(1993, 8, 16)));
    });

    test("days ago", () {
      expect(Timespan.today().daysAgo(), 0);
      expect(Timespan.today(daysAgo: 1).daysAgo(), 1);

      expect(
          List<bool>.generate(
              100,
              (i) =>
                  Timespan.today(daysAgo: i)
                      .daysAgo(align: TimespanPart.middle) ==
                  i).every(id),
          true);

      expect(
          List<bool>.generate(
              100,
              (i) =>
                  Timespan.today(daysAgo: i)
                      .daysAgo(align: TimespanPart.middle) ==
                  i).every(id),
          true);
    });

    test("nearest element", () {
      final now = DateTime.now();
      final times =
          List<DateTime>.generate(20, (i) => now.subtract(Duration(minutes: i)))
              .sorted((a, b) => a.compareTo(b));

      expect(times.getNearest(now), now);
      expect(times.getNearestFromSorted(now), now);
      expect(
          times.getNearest(now.subtract(const Duration(milliseconds: 500)),
              maxDeviation: const Duration(milliseconds: 100)),
          null);
    });

    test("lerp", () {
      final now = DateTime.now();
      const delta = Duration(minutes: 10);
      final ts = Timespan.arround(now, delta);
      const limit = Duration(milliseconds: 200);

      expect(ts.lerp(0.5).difference(now) < limit, true);
      expect(ts.lerp(0.0).difference(now.subtract(delta)) < limit, true);
      expect(ts.lerp(1.0).difference(now.add(delta)) < limit, true);

      expect(
          [for (double i = 0; i <= 1; i++) ts.lerp(i)]
              .isSorted((a, b) => a.compareTo(b)),
          true);
    });

    test("reduction", () {
      final now = DateTime.now();

      final data =
          List<DateTime>.generate(13, (i) => now.add(Duration(seconds: i)));

      final data2 = List<DateTime>.generate(
          13 * 5, (i) => now.add(Duration(milliseconds: 200 * i)));

      final data3 = List<DateTime>.generate(
          13, (i) => now.add(Duration(seconds: i + 120)));

      expect(data.reduceToDelta(const Duration(seconds: 3)).length, 5);
      expect(data2.reduceToDelta(const Duration(seconds: 3)).length, 5);
      expect(
          [...data, ...data2].reduceToDelta(const Duration(seconds: 3)).length,
          5);
      expect(
          [...data, ...data3].reduceToDelta(const Duration(seconds: 3)).length,
          10);
    });
  });

  test("byte conversion", () {
    final now = DateTime.now();
    final bytes = now.toUint8List();
    expect(dateTimeFromUint8List(bytes), now);

    final x = Timespan.today();
    expect(Timespan.fromBytes(x.toBytes()), x);
  });
}
