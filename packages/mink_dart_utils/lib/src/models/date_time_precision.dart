enum DateTimePrecision {
  year,
  month,
  day,
  hour,
  minute,
  second,
  millisecond,
  microsecond,
  ;

  static DateTimePrecision parse(String value) {
    switch (value) {
      case 'year':
        return DateTimePrecision.year;
      case 'month':
        return DateTimePrecision.month;
      case 'day':
        return DateTimePrecision.day;
      case 'hour':
        return DateTimePrecision.hour;
      case 'minute':
        return DateTimePrecision.minute;
      case 'second':
        return DateTimePrecision.second;
      case 'millisecond':
        return DateTimePrecision.millisecond;
      case 'microsecond':
        return DateTimePrecision.microsecond;
      default:
        throw ArgumentError('Invalid DateTimePrecision value: $value');
    }
  }

  DateTime convert(DateTime time) => switch (this) {
        DateTimePrecision.year => DateTime(
            time.year,
          ),
        DateTimePrecision.month => DateTime(
            time.year,
            time.month,
          ),
        DateTimePrecision.day => DateTime(
            time.year,
            time.month,
            time.day,
          ),
        DateTimePrecision.hour => DateTime(
            time.year,
            time.month,
            time.day,
            time.hour,
          ),
        DateTimePrecision.minute => DateTime(
            time.year,
            time.month,
            time.day,
            time.hour,
            time.minute,
          ),
        DateTimePrecision.second => DateTime(
            time.year,
            time.month,
            time.day,
            time.hour,
            time.minute,
            time.second,
          ),
        DateTimePrecision.millisecond => DateTime(
            time.year,
            time.month,
            time.day,
            time.hour,
            time.minute,
            time.second,
            time.millisecond,
          ),
        DateTimePrecision.microsecond => DateTime(
            time.year,
            time.month,
            time.day,
            time.hour,
            time.minute,
            time.second,
            time.millisecond,
            time.microsecond)
      };
}

extension ToPrecision on DateTime {
  DateTime toPrecision(DateTimePrecision precision) => precision.convert(this);
}
