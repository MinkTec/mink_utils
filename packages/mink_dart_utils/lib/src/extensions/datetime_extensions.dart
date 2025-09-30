import 'dart:typed_data';

import 'package:mink_dart_utils/src/clock.dart';
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
      isBefore(dartClock.now().subtract(duration));

  DateTime laterDate(DateTime other) => isBefore(other) ? other : this;
  DateTime earlierDate(DateTime other) => isAfter(other) ? other : this;

  /// get the current day with all small time units equal to zero
  DateTime midnight({int daysAgo = 0}) => DateTime(year, month, day - daysAgo);

  Duration get ago => dartClock.now().difference(this);

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

  DateTime addCalendarDay(int days) => DateTime(
      year, month, day + days, minute, second, millisecond, microsecond);

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
      "$hour:${twoDigits(minute.remainder(60))}:${twoDigits(second.remainder(60))}.${millisecond.toString().padRight(3, "0")}";
  String humanReadable() =>
      "$hour:${twoDigits(minute)}:${twoDigits(second)}".padRight(12, "0");

  Uint8List toUint8List() {
    final bytes = Uint8List(8);
    final bd = bytes.buffer.asByteData();
    writeUint64(bd, microsecondsSinceEpoch);
    return bytes;
  }

  static DateTime fromUint8List(Uint8List list) {
    final bd = list.buffer.asByteData();
    final micros = readUint64(bd);
    return DateTime.fromMicrosecondsSinceEpoch(micros);
  }
}

/*
DateTime dateTimeFromUint8List(List<int> list) =>
    DateTime.fromMicrosecondsSinceEpoch(
        Uint8List.fromList(list).buffer.asByteData().getUint64(0));
*/

DateTime dateTimeFromUint8List(List<int> list) {
  final bytes = Uint8List.fromList(list);
  final micros = readUint64(bytes.buffer.asByteData());

  return DateTime.fromMicrosecondsSinceEpoch(micros);
}

int readUint64(ByteData data, [int offset = 0]) {
  final high = data.getUint32(offset, Endian.big);
  final low = data.getUint32(offset + 4, Endian.big);
  return ((BigInt.from(high) << 32) | BigInt.from(low)).toInt();
}

/// Write a 64-bit unsigned integer (big endian) to [data] at [offset].
void writeUint64(ByteData data, int value, [int offset = 0]) {
  final big = BigInt.from(value);
  final high = (big >> 32).toInt();
  final low = (big & BigInt.from(0xFFFFFFFF)).toInt();
  data.setUint32(offset, high, Endian.big);
  data.setUint32(offset + 4, low, Endian.big);
}

class MsDateTime implements DateTime {
  int _time;

  MsDateTime(this._time);

  factory MsDateTime.fromDateTime(DateTime dt) =>
      MsDateTime(dt.millisecondsSinceEpoch);

  toDateTime() => DateTime.fromMillisecondsSinceEpoch(_time);

  @override
  MsDateTime add(Duration duration) =>
      MsDateTime(_time + duration.inMilliseconds);

  @override
  int compareTo(DateTime other) {
    return _time.compareTo(other.millisecondsSinceEpoch);
  }

  @override
  int get day => DateTime.fromMillisecondsSinceEpoch(_time).day;

  @override
  Duration difference(DateTime other) {
    if (other is MsDateTime) {
      return Duration(milliseconds: _time - other._time);
    } else {
      return Duration(milliseconds: _time - other.millisecondsSinceEpoch);
    }
  }

  @override
  int get hour => DateTime.fromMillisecondsSinceEpoch(_time).hour;

  @override
  bool isAfter(DateTime other) {
    return _time > other.millisecondsSinceEpoch;
  }

  @override
  bool isAtSameMomentAs(DateTime other) {
    return _time == other.millisecondsSinceEpoch;
  }

  @override
  bool isBefore(DateTime other) {
    return _time < other.millisecondsSinceEpoch;
  }

  @override
  bool get isUtc => true;

  @override
  int get microsecond => 0;

  @override
  int get microsecondsSinceEpoch => _time * 1000;

  @override
  int get millisecond => _time.remainder(1000);

  @override
  int get millisecondsSinceEpoch => _time;

  @override
  int get minute => _time.remainder(3600000) ~/ 60000;

  @override
  int get month => DateTime.fromMillisecondsSinceEpoch(_time).month;

  @override
  int get second => _time.remainder(60000) ~/ 1000;

  @override
  MsDateTime subtract(Duration duration) {
    return MsDateTime(_time - duration.inMilliseconds);
  }

  @override
  String get timeZoneName => 'UTC';

  @override
  Duration get timeZoneOffset => const Duration(hours: 0);

  @override
  String toIso8601String() {
    return DateTime.fromMillisecondsSinceEpoch(_time).toIso8601String();
  }

  @override
  DateTime toLocal() {
    return DateTime.fromMillisecondsSinceEpoch(_time).toLocal();
  }

  @override
  MsDateTime toUtc() {
    return this;
  }

  @override
  int get weekday => DateTime.fromMillisecondsSinceEpoch(_time).weekday;

  @override
  int get year => DateTime.fromMillisecondsSinceEpoch(_time).year;
}
