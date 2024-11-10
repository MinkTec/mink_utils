import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:mink_dart_utils/src/clock.dart';

class TimedData<T> with TimeBound {
  T value;

  @override
  DateTime time;

  TimedData({required this.value, DateTime? time})
      : time = time ?? dartClock.now();
}

class MaybeTimedData<T> {
  T value;
  DateTime? time;

  MaybeTimedData({required this.value, this.time});
}

class TimedComparable<T extends Comparable<T>>
    implements Comparable, TimedData<T> {
  @override
  int compareTo(other) {
    if (other is TimedData<T>) {
      return value.compareTo(other.value);
    } else if (other is T) {
      return this.value.compareTo(other);
    } else if (other is TimedData) {
      return this.time.compareTo(other.time);
    } else if (other is DateTime) {
      return this.time.compareTo(other);
    } else {
      throw ArgumentError('Cannot compare $other to $this');
    }
  }

  @override
  T value;
  @override
  DateTime time;

  TimedComparable({required this.value, required this.time});
}

class TimespanningData<T> with Timespanning {
  @override
  final Timespan timespan;

  final T value;

  const TimespanningData({
    required this.timespan,
    required this.value,
  });
}
