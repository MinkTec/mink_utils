import 'package:mink_utils/iterable_utils.dart';

import 'classes/timespan.dart';


// DateTime ago(Duration d) => DateTime.now().subtract(d);

extension ToDateTime on int {
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this);
}

extension Comparisons on DateTime {
  bool isBetween(DateTime begin, DateTime end) =>
      isAfter(begin) && isBefore(end);
  bool isIn(Timespan t) => isBetween(t.begin, t.end);

  DateTime getClosest(DateTime t1, DateTime t2) =>
      firstIsClosest(t1, t2) ? t1 : t2;

  bool firstIsClosest(DateTime t1, DateTime t2) =>
      difference(t1).abs() < difference(t2).abs();

  bool isOlder(Duration duration) =>
      isBefore(DateTime.now().subtract(duration));

  DateTime laterDate(DateTime other) => isBefore(other) ? other : this;
  DateTime earlierDate(DateTime other) => isAfter(other) ? other : this;

  DateTime midnight({int daysAgo = 0}) => DateTime(year, month, day - daysAgo);

  Duration get ago => DateTime.now().difference(this);

  String toShortWeekday() {
    switch (weekday) {
      case 1:
        return "Mo";
      case 2:
        return "Di";
      case 3:
        return "Mi";
      case 4:
        return "Do";
      case 5:
        return "Fr";
      case 6:
        return "Sa";
      case 7:
        return "So";
      default:
        return "invalid day";
    }
  }
}

extension GeneralDurationUtils on Duration {
  DateTime get ago => DateTime.now().subtract(this);

  Duration get zeroOrAbove => isNegative ? Duration.zero : this;
  Duration max(Duration d) => this > d ? this : d;
  Duration min(Duration d) => this < d ? this : d;
}

extension DateTimeListExtension on List<DateTime> {
  Iterable<Duration> diff() => lag.map((e) => e.last.difference(e.first));

  Iterable<Timespan> findBlocks([Duration delta = const Duration(minutes: 2)]) {
    return [0, ...diff().findIndices((e) => e > delta), length]
        .lag
        .map((e) => Timespan(begin: this[e.first], end: this[e.last - 1]));
  }
}

extension ListTimestampParser on List<int> {
  DateTime toDateTime() {
    final year = this[0] < 100 ? 2000 + this[0] : this[0];
    if (length == 8) {
      return DateTime(year, this[1], this[2], this[3], this[4], this[5], this[6], this[7],);
    }
    if (length == 7) {
      return DateTime( year, this[1], this[2], this[3], this[4], this[5], this[6],);
    }
    if (length == 6) {
      return DateTime( year, this[1], this[2], this[3], this[4], this[5],);
    } else if (length == 5) {
      return DateTime(year, this[1], this[2], this[3], this[4]);
    } else if (length == 4) {
      return DateTime(year, this[1], this[2], this[3]);
    } else if (length == 3) {
      return DateTime(year, this[1], this[2]);
    } else if (length == 2) {
      return DateTime(year, this[1]);
    } else if (length == 1) {
      return DateTime(year);
    } else {
      throw ArgumentError.value("Invalid Number of elements");
    }
  }
}
