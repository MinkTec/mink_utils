import 'package:mink_dart_utils/src/clock.dart';
import 'package:mink_dart_utils/src/models/timespan.dart';

/// DateTime bucketed to a fractional part of an hour.
class HourFractionPrecisionDate extends DateTime {
  final DateTime _dateTime;
  final int bucketMinutes;

  HourFractionPrecisionDate(DateTime dateTime, int bucketMinutes)
      : _dateTime = dateTime,
        bucketMinutes = _validateBucketMinutes(bucketMinutes),
        super(
          _bucketStart(dateTime, bucketMinutes).year,
          _bucketStart(dateTime, bucketMinutes).month,
          _bucketStart(dateTime, bucketMinutes).day,
          _bucketStart(dateTime, bucketMinutes).hour,
          _bucketStart(dateTime, bucketMinutes).minute,
        );

  factory HourFractionPrecisionDate.now(int bucketMinutes) =>
      HourFractionPrecisionDate(dartClock.now(), bucketMinutes);

  factory HourFractionPrecisionDate.fromTimestamp(
    String timestamp,
    int bucketMinutes,
  ) {
    if (timestamp.length != 11 || !timestamp.contains('_')) {
      throw ArgumentError('Invalid timestamp format. Expected: yymmdd_hhmm');
    }

    final parts = timestamp.split('_');
    if (parts.length != 2 || parts[0].length != 6 || parts[1].length != 4) {
      throw ArgumentError('Invalid timestamp format. Expected: yymmdd_hhmm');
    }

    final year = 2000 + int.parse(parts[0].substring(0, 2));
    final month = int.parse(parts[0].substring(2, 4));
    final day = int.parse(parts[0].substring(4, 6));
    final hour = int.parse(parts[1].substring(0, 2));
    final minute = int.parse(parts[1].substring(2, 4));

    _validateBucketMinuteAlignment(minute, bucketMinutes);

    return HourFractionPrecisionDate(
      DateTime(year, month, day, hour, minute),
      bucketMinutes,
    );
  }

  factory HourFractionPrecisionDate.fromYYmmDDHHmm(
    String string,
    int bucketMinutes,
  ) {
    var [yymmdd, hhmm] = string.split('_');
    if (!yymmdd.contains('-')) {
      yymmdd =
          '20${yymmdd.substring(0, 2)}-${yymmdd.substring(2, 4)}-${yymmdd.substring(4, 6)}';
    }

    final hour = int.parse(hhmm.substring(0, 2));
    final minute = int.parse(hhmm.substring(2, 4));

    _validateBucketMinuteAlignment(minute, bucketMinutes);

    return HourFractionPrecisionDate(
      DateTime.parse(yymmdd).add(Duration(hours: hour, minutes: minute)),
      bucketMinutes,
    );
  }

  static int _validateBucketMinutes(int bucketMinutes) {
    if (bucketMinutes <= 0 || bucketMinutes > 60 || 60 % bucketMinutes != 0) {
      throw ArgumentError.value(
        bucketMinutes,
        'bucketMinutes',
        'bucketMinutes must be between 1 and 60 and divide 60 evenly.',
      );
    }
    return bucketMinutes;
  }

  static void _validateBucketMinuteAlignment(int minute, int bucketMinutes) {
    _validateBucketMinutes(bucketMinutes);
    if (minute % bucketMinutes != 0) {
      throw ArgumentError.value(
        minute,
        'timestamp',
        'Timestamp minute must align with the bucket size.',
      );
    }
  }

  static DateTime _bucketStart(DateTime dateTime, int bucketMinutes) {
    _validateBucketMinutes(bucketMinutes);
    final minute = (dateTime.minute ~/ bucketMinutes) * bucketMinutes;
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      minute,
    );
  }

  double get hourFraction => bucketMinutes / 60;

  DateTime get dateTime => _dateTime;

  DateTime get bucketStart => _bucketStart(_dateTime, bucketMinutes);

  String get yymmddhhmm {
    final dt = bucketStart;
    final year = (dt.year % 100).toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${year}${month}${day}_$hour$minute';
  }

  Timespan get bucketTimespan => Timespan(
        begin: bucketStart,
        end: bucketStart.add(Duration(minutes: bucketMinutes)),
      );

  bool isSameBucket(DateTime other) =>
      HourFractionPrecisionDate(other, bucketMinutes) == this;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HourFractionPrecisionDate &&
        other.bucketMinutes == bucketMinutes &&
        other.bucketStart.year == bucketStart.year &&
        other.bucketStart.month == bucketStart.month &&
        other.bucketStart.day == bucketStart.day &&
        other.bucketStart.hour == bucketStart.hour &&
        other.bucketStart.minute == bucketStart.minute;
  }

  @override
  int get hashCode => Object.hash(
        bucketMinutes,
        bucketStart.year,
        bucketStart.month,
        bucketStart.day,
        bucketStart.hour,
        bucketStart.minute,
      );

  @override
  int compareTo(DateTime other) =>
      super.compareTo(HourFractionPrecisionDate(other, bucketMinutes));
}
