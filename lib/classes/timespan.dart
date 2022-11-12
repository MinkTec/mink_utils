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

  bool intersects(Timespan other) =>
      intersection(other).duration.inMilliseconds != 0;

  Timespan intersection(Timespan other) =>
      end.isBefore(other.begin) || other.end.isBefore(begin)
          ? Timespan(duration: Duration.zero)
          : Timespan(
              begin: begin.isAfter(other.begin) ? begin : other.begin,
              end: end.isBefore(other.end) ? end : other.end);

  List<Timespan> cut(DateTime time) => (time.isIn(this))
      ? [Timespan(begin: begin, end: time), Timespan(begin: time, end: end)]
      : throw ArgumentError("Given time is not inside timespan");

  bool includes(DateTime time) => begin.isBefore(time) && end.isAfter(time);

  Timespan({DateTime? begin, DateTime? end, Duration? duration}) {
    update(begin: begin, end: end, duration: duration);
  }

  factory Timespan.today({int daysAgo = 0}) => (daysAgo == 0)
      ? Timespan(begin: DateTime.now().midnight())
      : Timespan(
          begin: DateTime.now().midnight(daysAgo: daysAgo),
          duration: const Duration(days: 1));

  factory Timespan.arround(DateTime time, Duration delta) =>
      Timespan(begin: time.subtract(delta), end: time.add(delta));

  factory Timespan.empty() => Timespan(duration: Duration.zero);

  @override
  String toString() {
    return """Timespan from $begin - $end, lasting $duration""";
  }
}

extension TimespanIterableExtensions on Iterable<Timespan> {
  totalDuration() => (isNotEmpty)
      ? map((e) => e.duration).reduce((a, b) => a + b)
      : Duration.zero;
}
