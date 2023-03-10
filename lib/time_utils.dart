import 'package:flutter/painting.dart';
import 'package:mink_utils/iterable_utils.dart';

import 'classes/timespan.dart';

// DateTime ago(Duration d) => DateTime.now().subtract(d);

extension ToDateTime on int {
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this);
}

extension Comparisons on DateTime {
  /// check if a [DateTime] is between two other [DateTime]s.
  /// If strict is false [isBetween] is also true if [this] is equal
  /// to one of the interval borders.
  bool isBetween(DateTime begin, DateTime end, {bool strict = false}) =>
      (isAfter(begin) && isBefore(end)) ||
      (!strict && (this == begin || this == end));

  /// same as [isBetween] but with a timespan as argument
  bool isIn(Timespan t, {bool strict = false}) =>
      isBetween(t.begin, t.end, strict: strict);

  DateTime getClosest(DateTime t1, DateTime t2) =>
      firstIsClosest(t1, t2) ? t1 : t2;

  bool firstIsClosest(DateTime t1, DateTime t2) =>
      difference(t1).abs() < difference(t2).abs();

  bool isOlder(Duration duration) =>
      isBefore(DateTime.now().subtract(duration));

  DateTime laterDate(DateTime other) => isBefore(other) ? other : this;
  DateTime earlierDate(DateTime other) => isAfter(other) ? other : this;

  /// get the current day with all small time units equal to zero
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

  DateTime mostRecentWeekday(int weekday) =>
      DateTime(year, month, day - (this.weekday - weekday) % 7);

  DateTime beginOfWeek() => mostRecentWeekday(DateTime.monday);

  DateTime beginOfMonth({int monthAgo = 0}) => DateTime(year, month);
  DateTime endOfMonth({int monthAgo = 0}) => DateTime(year, month + 1);

  DateTime beginOfYear() => DateTime(year);
  DateTime endOfYear() => DateTime(year + 1);
}

extension GeneralDurationUtils on Duration {
  DateTime get ago => DateTime.now().subtract(this);

  Duration get zeroOrAbove => max(Duration.zero);

  Duration max(Duration d) => this > d ? this : d;
  Duration min(Duration d) => this < d ? this : d;

  String toExplainerString() {
    return """${inHours > 0 ? "$inHours Stunden und": ""} ${inMinutes % 60} Minuten""";
  }
}

extension DateTimeListExtension on List<DateTime> {
  /// get Duration between each elemnt of a [List] of [DateTime]s
  Iterable<Duration> diff() => lag.map((e) => e.last.difference(e.first));

  /// find continuous blocks of [DateTime]s in a [List<DateTime>].
  /// Every section of one or more blocks where the [Duration] between each
  /// element and its neighbours is less than [delta] is counted as a block
  Iterable<Timespan> findBlocks([Duration delta = const Duration(minutes: 2)]) {
    if (isEmpty) return [];
    sort((a, b) => a.compareTo(b));
    return [0, ...diff().findIndices((e) => e > delta), length]
        .lag
        .map((e) => Timespan(begin: this[e.first], end: this[e.last - 1]));
  }

  /// calculate the frequency of the give iterable
  /// either n (number of elements) or duration can be set
  /// setting both results in an ArgumentError.
  /// If none is set, all values will be evaluated.
  /// The function assumes that the list is sorted.
  /// If it's not sorted calculations with [n] ore none specified
  /// can return wrong results.
  /// If realtime is the the functions assumes that the timer interval
  /// ends [DateTime.now()] otherwise the lasts elements timestamp
  /// will be used.
  double frequency({int? n, Duration? duration, bool realTime = false}) {
    if (isEmpty) return 0;

    final DateTime startTime;
    final Iterable<DateTime> vals;

    if (duration != null) {
      startTime = last.subtract(duration);
      vals = where((e) => e.isAfter(startTime));
    } else if (n != null) {
      vals = reversed.take(n);
      startTime = vals.last;
    } else {
      vals = this;
      startTime = first;
    }

    final endTime = realTime ? DateTime.now() : last;

    return (vals.length / endTime.difference(startTime).inMilliseconds) * 1000;
  }

  DateTime? getNearest(DateTime time, {Duration? maxDeviation}) {
    if (isEmpty) return null;
    final res = reduce(
        (a, b) => a.difference(time).abs() > b.difference(time).abs() ? b : a);
    return (maxDeviation == null ||
            res.difference(time).abs() < maxDeviation.abs())
        ? res
        : null;
  }
}

extension ListTimestampParser on List<int> {
  /// read timestamps in the format of
  /// [1934, 5, 4] -> [DateTime(1934, 5, 4)]
  /// [22, 11, 11] -> [DateTime(2022, 11, 11)]
  /// If the [first] is less than 100 it will be
  /// interpreted as [2000 + first]
  DateTime toDateTime() {
    final year = this[0] < 100 ? 2000 + this[0] : this[0];
    if (length == 8) {
      return DateTime(
        year,
        this[1],
        this[2],
        this[3],
        this[4],
        this[5],
        this[6],
        this[7],
      );
    }
    if (length == 7) {
      return DateTime(
        year,
        this[1],
        this[2],
        this[3],
        this[4],
        this[5],
        this[6],
      );
    }
    if (length == 6) {
      return DateTime(
        year,
        this[1],
        this[2],
        this[3],
        this[4],
        this[5],
      );
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
