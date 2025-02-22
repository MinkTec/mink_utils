import 'dart:typed_data';

import 'package:mink_dart_utils/src/extensions/datetime_extensions.dart';

import '../clock.dart';
import 'date_time_precision.dart';

part 'timespan.g.dart';

enum SplitType {
  hour,
  day,
  week,
  month,
  year,
  total,
  ;

  Duration delta(DateTime time) => switch (this) {
        SplitType.hour => Duration(hours: 1),
        SplitType.day => Duration(days: 1),
        SplitType.week => Duration(days: 7),
        SplitType.month => time.endOfMonth().difference(time.beginOfMonth()),
        SplitType.year => time.endOfYear().difference(time.beginOfYear()),
        SplitType.total => Duration(days: 1000000000)
      };

  DateTime findBegin(DateTime referenceTime) => switch (this) {
        SplitType.hour => referenceTime.copyWith(
            minute: 0, second: 0, millisecond: 0, microsecond: 0),
        SplitType.day => referenceTime.copyWith(
            hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0),
        SplitType.week => referenceTime.beginOfWeek(),
        SplitType.month => referenceTime.beginOfMonth(),
        SplitType.year => referenceTime.beginOfYear(),
        SplitType.total => DateTime(1970)
      };

  List<Timespan> split(Timespan timespan) {
    switch (this) {
      case SplitType.hour:
        final ts = Timespan(
            begin: findBegin(timespan.begin),
            end: findBegin(timespan.end).add(delta(timespan.end)));

        return ts.split(delta(timespan.begin)).toList();
      case SplitType.day:
        return timespan.days.toList();
      case SplitType.week:
        return timespan.weeks.toList();
      case SplitType.month:
        return timespan.month.toList();
      case SplitType.year:
        return timespan.years.toList();
      case SplitType.total:
        return [timespan];
    }
  }

  Timespan timespan(DateTime time) =>
      Timespan(begin: findBegin(time), duration: delta(time));
}

class Timespan {
  late DateTime begin;
  late DateTime end;
  late Duration duration;

  Timespan({DateTime? begin, DateTime? end, Duration? duration}) {
    update(begin: begin, end: end, duration: duration);
  }

  /// Get a symmetric Timespan arround the given time with
  /// [delta] as the difference of begin and end from [time]
  /// thus the duration of the timespan is [2 * delta]
  factory Timespan.arround(DateTime time, Duration delta) =>
      Timespan(begin: time.subtract(delta), end: time.add(delta));

  factory Timespan.empty() => Timespan(duration: Duration.zero);

  factory Timespan.fromBytes(List<int> bytes) {
    return Timespan(
        begin: dateTimeFromUint8List(bytes.sublist(0, 8)),
        end: dateTimeFromUint8List(bytes.sublist(8)));
  }

  factory Timespan.fromJson(Map<String, dynamic> json) =>
      _$TimespanFromJson(json);

  /// generates a timespan from the specfied hours
  /// Example:
  /// [Timespan.fromOClock(from: 9, to: 17)] -> 9:00 - 17:00 (Today)
  /// If no [reference] is provieded the hours will be added to
  /// [DateTime.midnight()].
  factory Timespan.fromOClock(
      {required int from, required int to, DateTime? reference}) {
    assert(from <= to);
    reference ??= dartClock.now().midnight();
    return Timespan(
        begin: reference.add(Duration(hours: from)),
        end: reference.add(Duration(hours: to)));
  }

  /// Get Timespan of a day.
  /// if daysAgo is zero, the end of the timespan is [clock.now()]
  factory Timespan.today({int daysAgo = 0, bool fullday = false}) =>
      daysAgo != 0 || fullday
          ? Timespan(
              begin: dartClock.now().midnight(daysAgo: daysAgo),
              duration: const Duration(days: 1))
          : Timespan(begin: dartClock.now().midnight());

  factory Timespan.day(DateTime time) => Timespan(
      begin: DateTimePrecision.day(time),
      duration: const Duration(days: 1) - const Duration(microseconds: 1));

  Timespan get dreiviertelzwoelf => Timespan(
      begin: Timespan.today().lerp(0.5).subtract(const Duration(minutes: 15)),
      duration: const Duration(minutes: 15));

  @override
  int get hashCode =>
      begin.microsecondsSinceEpoch ^
      duration.inMicroseconds ^
      end.microsecondsSinceEpoch;

  bool get isToday {
    final ts = Timespan.today();
    return begin.isBetween(ts.begin, ts.end) && end.isBetween(ts.begin, ts.end);
  }

  /// get all weeks that overlap with a the [Timespan]
  Iterable<Timespan> get days sync* {
    DateTime tempTime = DateTime(begin.year, begin.month, begin.day);
    DateTime newTempTime;
    while (tempTime.isBefore(end)) {
      newTempTime = tempTime.addCalendarDay(1);
      yield Timespan(
          begin: tempTime,
          end: newTempTime.subtract(Duration(microseconds: 1)));
      tempTime = newTempTime;
    }
  }

  /// get all month that overlap with a the [Timespan]
  Iterable<Timespan> get month sync* {
    DateTime i = begin.beginOfMonth();
    int counter = 0;
    while (DateTime(begin.year, begin.month + counter).isBefore(end)) {
      yield Timespan(
          begin: DateTime(i.year, i.month + counter),
          end: DateTime(i.year, i.month + counter + 1)
              .subtract(const Duration(microseconds: 1)));
      counter++;
    }
  }

  /// get all weeks that overlap with a the [Timespan]
  Iterable<Timespan> get weeks sync* {
    DateTime tempTime = begin.beginOfWeek();
    final week = const Duration(days: 7);
    while (tempTime.isBefore(end)) {
      yield Timespan(
          begin: tempTime, duration: week - Duration(microseconds: 1));
      tempTime = tempTime.add(week);
    }
  }

  /// get all years that overlap with a the [Timespan]
  Iterable<Timespan> get years sync* {
    DateTime i = begin.beginOfYear();
    int counter = 0;
    do {
      yield Timespan(
          begin: DateTime(i.year + counter),
          end: DateTime(i.year + counter + 1)
              .subtract(const Duration(microseconds: 1)));
      counter++;
    } while (DateTime(begin.year + counter).isBefore(end));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (runtimeType != other.runtimeType) {
      return false;
    } else {
      return other.hashCode == hashCode;
    }
  }

  Timespan combine(Timespan other) => Timespan(
      begin: begin.earlierDate(other.begin), end: end.laterDate(other.end));

  bool contains(Timespan timespan) => intersection(timespan) == timespan;

  /// Returns a list of two [Timespan]s.
  /// If [time] is not in [this] it throws an error
  List<Timespan> cut(DateTime time) => (time.isIn(this))
      ? [Timespan(begin: begin, end: time), Timespan(begin: time, end: end)]
      : throw ArgumentError("Given time is not inside timespan");

  /// check how many days ago a timespan is.
  /// The [align] parameter is used to set which part
  /// of the timespan is used and defaults to [this.end]
  int daysAgo({TimespanPart align = TimespanPart.end}) {
    final mn = dartClock.now().midnight();
    return mn.isBefore(align.get(this))
        ? 0
        : align.get(this).difference(mn).abs().inDays + 1;
  }

  bool includes(DateTime time) => begin.isBefore(time) && end.isAfter(time);

  Timespan intersection(Timespan other) =>
      end.isBefore(other.begin) || other.end.isBefore(begin)
          ? Timespan(duration: Duration.zero)
          : Timespan(
              begin: begin.laterDate(other.begin),
              end: end.earlierDate(other.end));

  bool intersects(Timespan other) =>
      intersection(other).duration.inMilliseconds != 0;

  /// Interpolate linear within the timespan
  DateTime lerp(double x) =>
      DateTime.fromMillisecondsSinceEpoch((begin.millisecondsSinceEpoch +
              x * (end.millisecondsSinceEpoch - begin.millisecondsSinceEpoch))
          .toInt());

  Iterable<Timespan> split(Duration duration) sync* {
    DateTime tempTime = begin;
    while (tempTime.isBefore(end)) {
      yield Timespan(begin: tempTime, duration: duration);
      tempTime = tempTime.add(duration);
    }
  }

  List<Timespan> splitBy(SplitType type) => type.split(this);

  Uint8List toBytes() => (BytesBuilder(copy: false)
        ..add(begin.toUint8List())
        ..add(end.toUint8List()))
      .takeBytes();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'begin': begin.toIso8601String(),
        'end': end.toIso8601String(),
      };

  @override
  String toString() {
    if (duration >= Duration(days: 3)) {
      return """Timespan(${begin.yymmdd} - ${end.yymmdd}})""";
    } else if (duration >= Duration(hours: 3)) {
      return """Timespan(begin: ${begin.yymmdd} ${begin.hhmm} end: ${end.yymmdd} ${end.hhmm})""";
    } else {
      return "Timespan(begin: $begin, end: $end)";
    }
  }

  /// The update function handles not only the updates to an existing
  /// [Timespan] but also acts as a quasi constructor.
  /// Since all parameters are optional the default behaviour is
  /// explained in the [update]-function itself.
  void update({DateTime? begin, DateTime? end, Duration? duration}) {
    if (duration == null) {
      /// use the supplied begin or unix time = 0
      this.begin = begin ?? DateTime(1970);

      /// use the supplied end or now
      this.end = end ?? dartClock.now();

      /// calc resulting duration
      this.duration = this.end.difference(this.begin);
    } else if (begin != null && end != null) {
      /// If this condition is reached, all arguments are given.
      /// Hence the duration needs to match the begin and end times.
      if (begin.difference(end).compareTo(duration) == 0) {
        this.begin = begin;
        this.end = end;
        this.duration = duration;
      } else {
        throw ArgumentError("Starttime endtime and duration do not match");
      }

      /// if only begin and duration are given,
      /// calc the end time from begin + duration
    } else if (begin != null) {
      this.begin = begin;
      this.end = begin.add(duration);
      this.duration = duration;

      /// if only end and duration are given,
      /// calc the begin time from end - duration
    } else {
      this.end = end ?? dartClock.now();
      this.begin = this.end.subtract(duration);
      this.duration = duration;
    }
  }
}

enum TimespanPart {
  begin,
  end,
  middle,
}

extension GetTimes on TimespanPart {
  DateTime get(Timespan timespan) => switch (this) {
        TimespanPart.begin => timespan.begin,
        TimespanPart.end => timespan.end,
        TimespanPart.middle => timespan.lerp(0.5)
      };
}

extension TimespanIterableExtensions on Iterable<Timespan> {
  Duration totalDuration() => (isNotEmpty)
      ? map((e) => e.duration).reduce((a, b) => a + b)
      : Duration.zero;
}
