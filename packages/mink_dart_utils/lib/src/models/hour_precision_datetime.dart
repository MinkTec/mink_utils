import 'package:meta/meta.dart';
import 'package:mink_dart_utils/src/clock.dart';
import 'package:mink_dart_utils/src/models/timespan.dart';

/// Hour precision date utility for file naming
class HourPrecisionDate extends DateTime {
  final DateTime _dateTime;

  HourPrecisionDate(this._dateTime)
      : super(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          _dateTime.hour,
        );

  factory HourPrecisionDate.now() => HourPrecisionDate(dartClock.now());

  factory HourPrecisionDate.fromTimestamp(String timestamp) {
    if (timestamp.length != 9 || !timestamp.contains('_')) {
      throw ArgumentError('Invalid timestamp format. Expected: yymmdd_hh');
    }

    final parts = timestamp.split('_');
    if (parts.length != 2 || parts[0].length != 6 || parts[1].length != 2) {
      throw ArgumentError('Invalid timestamp format. Expected: yymmdd_hh');
    }

    final year = 2000 + int.parse(parts[0].substring(0, 2));
    final month = int.parse(parts[0].substring(2, 4));
    final day = int.parse(parts[0].substring(4, 6));
    final hour = int.parse(parts[1]);

    return HourPrecisionDate(DateTime(year, month, day, hour));
  }

  String get yymmddhh {
    final dt = _dateTime;
    final year = (dt.year % 100).toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    return "${year}${month}${day}_$hour";
  }

  DateTime get dateTime => _dateTime;

  /// Get the hour timespan this date represents (from hour start to hour end)
  Timespan get hourTimespan => Timespan(
        begin: DateTime(
            _dateTime.year, _dateTime.month, _dateTime.day, _dateTime.hour),
        end: DateTime(
            _dateTime.year, _dateTime.month, _dateTime.day, _dateTime.hour + 1),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HourPrecisionDate &&
        other._dateTime.year == _dateTime.year &&
        other._dateTime.month == _dateTime.month &&
        other._dateTime.day == _dateTime.day &&
        other._dateTime.hour == _dateTime.hour;
  }

  @override
  int get hashCode {
    return Object.hash(
        _dateTime.year, _dateTime.month, _dateTime.day, _dateTime.hour);
  }

  @visibleForTesting
  static DateTime? mockTime;

  factory HourPrecisionDate.fromYYmmDDHH(String string) {
    var [yymmdd, h] = string.split("_");
    if (!yymmdd.contains("-")) {
      yymmdd =
          "20${yymmdd.substring(0, 2)}-${yymmdd.substring(2, 4)}-${yymmdd.substring(4, 6)}";
    }
    return HourPrecisionDate(
        DateTime.parse(yymmdd).add(Duration(hours: int.parse(h))));
  }

  @override
  int compareTo(DateTime other) => super.compareTo(HourPrecisionDate(other));
}
