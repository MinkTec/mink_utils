import 'package:mink_flutter_utils/mink_flutter_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Timespan', () {
    test('basic creation and properties', () {
      final now = DateTime(2023, 1, 1, 12, 0);
      final begin = now.subtract(Duration(hours: 1));
      final end = now.add(Duration(hours: 1));
      final ts = Timespan(begin: begin, end: end);

      expect(ts.begin, begin);
      expect(ts.end, end);
      expect(ts.duration, Duration(hours: 2));
    });

    test('creation with duration only', () {
      final ts = Timespan(duration: Duration(hours: 2));

      expect(ts.duration, Duration(hours: 2));
      expect(ts.end.difference(ts.begin), Duration(hours: 2));
    });

    test('Timespan.arround', () {
      final center = DateTime(2023, 1, 1, 12, 0);
      final delta = Duration(hours: 1);
      final ts = Timespan.arround(center, delta);

      expect(ts.begin, center.subtract(delta));
      expect(ts.end, center.add(delta));
      expect(ts.duration, delta * 2);
    });

    test('Timespan.today', () {
      final today = Timespan.today();
      final now = dartClock.now();

      expect(today.begin.day, now.day);
      expect(today.begin.month, now.month);
      expect(today.begin.year, now.year);
      expect(today.begin.hour, 0);
      expect(today.begin.minute, 0);
      expect(today.begin.second, 0);
    });

    test('Timespan.fromOClock', () {
      final workday =
          Timespan.fromOClock(from: 9, to: 17, reference: DateTime(2023, 1, 1));

      expect(workday.begin.hour, 9);
      expect(workday.end.hour, 17);
      expect(workday.duration, Duration(hours: 8));
    });

    test('intersects and intersection', () {
      final ts1 = Timespan(
        begin: DateTime(2023, 1, 1, 10),
        end: DateTime(2023, 1, 1, 14),
      );
      final ts2 = Timespan(
        begin: DateTime(2023, 1, 1, 12),
        end: DateTime(2023, 1, 1, 16),
      );
      final ts3 = Timespan(
        begin: DateTime(2023, 1, 1, 15),
        end: DateTime(2023, 1, 1, 18),
      );

      expect(ts1.intersects(ts2), true);
      expect(ts1.intersects(ts3), false);
      expect(ts2.intersects(ts3), true);

      final intersection = ts1.intersection(ts2);
      expect(intersection.begin, DateTime(2023, 1, 1, 12));
      expect(intersection.end, DateTime(2023, 1, 1, 14));
      expect(intersection.duration, Duration(hours: 2));

      final emptyIntersection = ts1.intersection(ts3);
      expect(emptyIntersection.duration, Duration.zero);
    });

    test('cut method', () {
      final ts = Timespan(
        begin: DateTime(2023, 1, 1, 10),
        end: DateTime(2023, 1, 1, 14),
      );
      final cutPoint = DateTime(2023, 1, 1, 12);

      final parts = ts.cut(cutPoint);
      expect(parts.length, 2);
      expect(parts[0].begin, ts.begin);
      expect(parts[0].end, cutPoint);
      expect(parts[1].begin, cutPoint);
      expect(parts[1].end, ts.end);

      // Should throw if cut point is outside timespan
      expect(
          () => ts.cut(DateTime(2023, 1, 1, 9)), throwsA(isA<ArgumentError>()));
    });

    test('split and splitBy', () {
      final day = Timespan(
        begin: DateTime(2023, 1, 1),
        end: DateTime(2023, 1, 2),
      );

      // Split into hours
      final hourSplits = day.split(Duration(hours: 1)).toList();
      expect(hourSplits.length, 24);
      expect(hourSplits.first.begin, day.begin);
      expect(hourSplits.last.end, day.end);

      // Split by type
      final daySplits = day.splitBy(SplitType.day).toList();
      expect(daySplits.length, 1);
      expect(daySplits.first.begin.day, 1);

      final month = Timespan(
        begin: DateTime(2023, 1, 1),
        end: DateTime(2023, 3, 1),
      );

      final monthSplits = month.splitBy(SplitType.month).toList();
      expect(monthSplits.length, 2); // Jan + Feb
    });

    test('lerp', () {
      final ts = Timespan(
        begin: DateTime(2023, 1, 1, 10),
        end: DateTime(2023, 1, 1, 14),
      );

      expect(ts.lerp(0), ts.begin);
      expect(ts.lerp(1), ts.end);
      expect(ts.lerp(0.5), DateTime(2023, 1, 1, 12));
    });

    test('update', () {
      // Instead of relying on fixed clock, directly test only the explicit update behavior
      final ts = Timespan(
        begin: DateTime(2023, 1, 1, 10),
        end: DateTime(2023, 1, 1, 14),
      );

      // Update begin time
      ts.update(begin: DateTime(2023, 1, 1, 12), end: DateTime(2023, 1, 1, 14));
      expect(ts.begin, DateTime(2023, 1, 1, 12));
      expect(ts.end, DateTime(2023, 1, 1, 14));
      expect(ts.duration, Duration(hours: 2));

      // Update with duration
      ts.update(begin: DateTime(2023, 1, 1, 13), duration: Duration(hours: 1));
      expect(ts.begin, DateTime(2023, 1, 1, 13));
      expect(ts.end, DateTime(2023, 1, 1, 14));
    });

    test('serialization', () {
      final original = Timespan(
        begin: DateTime(2023, 1, 1, 10),
        end: DateTime(2023, 1, 1, 14),
      );

      final json = original.toJson();
      final bytes = original.toBytes();

      final fromJson = Timespan.fromJson(json);
      final fromBytes = Timespan.fromBytes(bytes);

      expect(fromJson.begin, original.begin);
      expect(fromJson.end, original.end);

      expect(fromBytes.begin, original.begin);
      expect(fromBytes.end, original.end);
    });
  });

  group('Timespanning mixin', () {
    test('TimespanningData class', () {
      final ts = Timespan(
        begin: DateTime(2023, 1, 1, 10),
        end: DateTime(2023, 1, 1, 14),
      );
      final data = TimespanningData(timespan: ts, value: 'test');

      expect(data.timespan, ts);
      expect(data.value, 'test');

      // Equality
      final data2 = TimespanningData(timespan: ts, value: 'test');
      expect(data == data2, true);

      final differentTs = Timespan(
        begin: DateTime(2023, 1, 1, 11),
        end: DateTime(2023, 1, 1, 15),
      );
      final data3 = TimespanningData(timespan: differentTs, value: 'test');
      expect(data == data3, false);
    });

    test('Timespan iterable extensions', () {
      final ts1 = Timespan(
        begin: DateTime(2023, 1, 1, 10),
        end: DateTime(2023, 1, 1, 14),
      );
      final ts2 = Timespan(
        begin: DateTime(2023, 1, 1, 12),
        end: DateTime(2023, 1, 1, 16),
      );
      final ts3 = Timespan(
        begin: DateTime(2023, 1, 1, 8),
        end: DateTime(2023, 1, 1, 11),
      );

      final spans = [ts1, ts2, ts3];

      // totalSpan
      final totalSpan = spans.totalSpan();
      expect(totalSpan.begin, DateTime(2023, 1, 1, 8));
      expect(totalSpan.end, DateTime(2023, 1, 1, 16));

      // intersectingElements
      final other = [
        Timespan(begin: DateTime(2023, 1, 1, 9), end: DateTime(2023, 1, 1, 13)),
        Timespan(
            begin: DateTime(2023, 1, 1, 17), end: DateTime(2023, 1, 1, 18)),
      ];

      final intersecting = spans.intersectingElements(other).toList();
      // The 9-13 timespan intersects with all three spans in the collection
      expect(intersecting.length,
          3); // Each span intersects with the 9-13 timespan
      expect(
          intersecting.every((span) => span.begin == DateTime(2023, 1, 1, 9)),
          true);
    });

    test('Timespanning list extensions', () {
      final ts1 = Timespan(
        begin: DateTime(2023, 1, 1, 10),
        end: DateTime(2023, 1, 1, 14),
      );
      final ts2 = Timespan(
        begin: DateTime(2023, 1, 1, 12),
        end: DateTime(2023, 1, 1, 16),
      );

      final data1 = TimespanningData(timespan: ts1, value: 'test1');
      final data2 = TimespanningData(timespan: ts2, value: 'test2');

      final items = [data1, data2];

      // timespan extraction
      final timespans = items.timespan.toList();
      expect(timespans.length, 2);
      expect(timespans[0], ts1);
      expect(timespans[1], ts2);

      // intersectingElements
      final other = [
        TimespanningData(
            timespan: Timespan(
                begin: DateTime(2023, 1, 1, 11), end: DateTime(2023, 1, 1, 13)),
            value: 'other'),
        TimespanningData(
            timespan: Timespan(
                begin: DateTime(2023, 1, 1, 17), end: DateTime(2023, 1, 1, 18)),
            value: 'non-intersecting'),
      ];

      final intersecting = items.intersectingElements(other).toList();
      // The first element in 'other' intersects with both items
      expect(intersecting.length, 2);
      // Both should be the same 'other' element that intersects
      expect(
          intersecting
              .every((item) => (item as TimespanningData).value == 'other'),
          true);
    });
  });
}
