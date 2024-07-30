import 'dart:typed_data';

import 'package:mink_dart_utils/src/models/timespan.dart';
import 'package:mink_dart_utils/src/utils/base.dart';

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

  String get yymmdd =>
      "$year-${month.toString().padLeft(2, "0")}-${day.toString().padLeft(2, "0")}";

  String get hhmm => "$hour:${twoDigits(minute.remainder(60))}";
  String get hhmmss =>
      "$hour:${twoDigits(minute.remainder(60))}:${twoDigits(second.remainder(60))}";
  String get hhmmssms =>
      "$hour:${twoDigits(minute.remainder(60))}:${twoDigits(second.remainder(60))}.$millisecond";
  String humanReadable() => "$hour:${twoDigits(minute)}:${twoDigits(second)}";

  Uint8List toUint8List() => Uint8List(8)
    ..buffer.asByteData().setUint64(0, microsecondsSinceEpoch, Endian.big);

  static DateTime fromUint8List(Uint8List list) {
    return DateTime.fromMicrosecondsSinceEpoch(
        list.buffer.asByteData().getInt64(0));
  }
}

DateTime dateTimeFromUint8List(Uint8List list) =>
    DateTime.fromMicrosecondsSinceEpoch(list.buffer.asByteData().getUint64(0));
