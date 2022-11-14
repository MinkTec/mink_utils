import 'package:mink_utils/time_utils.dart';

class Timespan {
  late DateTime begin;
  late DateTime end;
  late Duration duration;

  /// The update function handles not only the updates to an existing
  /// [Timespan] but also acts as a quasi constructor.
  /// Since all parameters are optional the default behaviour is
  /// explained in the [update]-function itself.
  void update({DateTime? begin, DateTime? end, Duration? duration}) {
    if (duration == null) {
      /// use the supplied begin or unix time = 0
      this.begin = begin ?? DateTime(1970);

      /// use the supplied end or now
      this.end = end ?? DateTime.now();

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
      this.end = end ?? DateTime.now();
      this.begin = this.end.subtract(duration);
      this.duration = duration;
    }
  }

  @override
  int get hashCode =>
      begin.microsecondsSinceEpoch +
      duration.inMicroseconds +
      end.microsecondsSinceEpoch;

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

  bool intersects(Timespan other) =>
      intersection(other).duration.inMilliseconds != 0;

  Timespan intersection(Timespan other) =>
      end.isBefore(other.begin) || other.end.isBefore(begin)
          ? Timespan(duration: Duration.zero)
          : Timespan(
              begin: begin.isAfter(other.begin) ? begin : other.begin,
              end: end.isBefore(other.end) ? end : other.end);

  /// Returns a list of two [Timespan]s.
  /// If [time] is not in [this] it throws an error
  List<Timespan> cut(DateTime time) => (time.isIn(this))
      ? [Timespan(begin: begin, end: time), Timespan(begin: time, end: end)]
      : throw ArgumentError("Given time is not inside timespan");

  bool includes(DateTime time) => begin.isBefore(time) && end.isAfter(time);

  Timespan({DateTime? begin, DateTime? end, Duration? duration}) {
    update(begin: begin, end: end, duration: duration);
  }

  /// Get Timespan of a day.
  /// if daysAgo is zero, the end of the timespan is [DateTime.now()]
  factory Timespan.today({int daysAgo = 0}) => (daysAgo == 0)
      ? Timespan(begin: DateTime.now().midnight())
      : Timespan(
          begin: DateTime.now().midnight(daysAgo: daysAgo),
          duration: const Duration(days: 1));

  /// Get a symmetric Timespan arround the given time with
  /// [delta] as the difference of begin and end from [time]
  /// thus the duration of the timespan is [2 * delta]
  factory Timespan.arround(DateTime time, Duration delta) =>
      Timespan(begin: time.subtract(delta), end: time.add(delta));

  factory Timespan.empty() => Timespan(duration: Duration.zero);

  @override
  String toString() {
    return """Timespan from $begin - $end, lasting $duration""";
  }

  /// get all weeks that overlap with a the [Timespan]
  Iterable<Timespan> get weeks sync* {
    DateTime tempTime = begin.beginOfWeek();
    final week = const Duration(days: 7) - const Duration(hours: 1);
    while (tempTime.isBefore(end)) {
      yield Timespan(begin: tempTime, duration: week);
      tempTime = tempTime.add(week);
    }
  }

  /// get all month that overlap with a the [Timespan]
  Iterable<Timespan> get month sync* {
    DateTime i = begin.beginOfMonth();
    int counter = 0;
    while (DateTime(begin.year, begin.month + counter).isBefore(end)) {
      yield Timespan(
          begin: DateTime(i.year, i.month + counter),
          end: DateTime(i.year, i.month + counter + 1).subtract(const Duration(hours: 1)));
      counter++;
    }
  }

  /// get all years that overlap with a the [Timespan]
  Iterable<Timespan> get years sync* {
    DateTime i = begin.beginOfYear();
    int counter = 0;
    do {
      yield Timespan(
          begin: DateTime(i.year + counter),
          end: DateTime(i.year + counter + 1).subtract(const Duration(hours: 1)));
      counter++;
    } while (DateTime(begin.year + counter).isBefore(end));
  }
}

extension TimespanIterableExtensions on Iterable<Timespan> {
  totalDuration() => (isNotEmpty)
      ? map((e) => e.duration).reduce((a, b) => a + b)
      : Duration.zero;
}
