enum TimeUnit {
  year,
  month,
  day,
  hour,
  minute,
  second,
  millisecond,
  microsecond,
  nanosecond,
  ;

  int mod({DateTime? at}) {
    switch (this) {
      case TimeUnit.year:
        return 100;
      case TimeUnit.month:
        return 12;
      case TimeUnit.day:
        return at != null ? _daysInMonth(at) : 30;
      case TimeUnit.hour:
      case TimeUnit.minute:
      case TimeUnit.second:
        return 60;
      case TimeUnit.millisecond:
        return 1000;
      case TimeUnit.microsecond:
        return 1000000;
      case TimeUnit.nanosecond:
        return 1000000000;
    }
  }
}

int _daysInMonth(DateTime time) {
  final month = time.month;
  final year = time.year;
  if (month == 2) {
    return _isLeapYear(year) ? 29 : 28;
  } else if (month == 4 || month == 6 || month == 9 || month == 11) {
    return 30;
  } else {
    return 31;
  }
}

bool _isLeapYear(int year) {
  if (year % 4 != 0) {
    return false;
  } else if (year % 100 != 0) {
    return true;
  } else if (year % 400 != 0) {
    return false;
  } else {
    return true;
  }
}
