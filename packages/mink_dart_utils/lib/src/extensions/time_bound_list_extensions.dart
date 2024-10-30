import 'dart:math' as math;
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:mink_dart_utils/src/extensions/datetime_extensions.dart';
import 'package:mink_dart_utils/src/extensions/datetime_list_extensions.dart';
import 'package:mink_dart_utils/src/extensions/duration_extensions.dart';
import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';
import 'package:mink_dart_utils/src/mixins/time_bound.dart';

import '../models/timed_data.dart';
import '../models/timespan.dart';

typedef Reduce<T> = T Function(T a, T b);

typedef TimespanGroupedList<T> = List<TimespanningData<List<T>>>;
typedef TimespanGroupedValue<T> = List<TimespanningData<T>>;

extension TimespanGroupedListReducer<T> on TimespanGroupedList<T> {
  TimespanGroupedValue<T> reduceGroups(Reduce<T> combine) => eagerMap((x) =>
      TimespanningData(timespan: x.timespan, value: x.value.reduce(combine)));

  TimespanGroupedValue<S> mapReduce<S>({
    required S Function(T value) map,
    required Reduce<S> reduce,
    T? initialElement,
  }) =>
      eagerMap((x) => TimespanningData(
          timespan: x.timespan, value: x.value.map(map).reduce(reduce)));
}

extension TimeBoundIterableExtensions<T extends TimeBound> on Iterable<T> {
  List<DateTime> get time => [for (var tb in this) tb.time];
}

extension DateTimeExtensionWrapper<T extends TimeBound> on List<T> {
  TimespanGroupedList<T> groupBy({
    required SplitType group,

    /// if timespan is null, the difference between the earliest and latest element is used
    Timespan? timespan,
    bool isSorted = false,
  }) {
    if (isEmpty) {
      return [];
    }

    int sortCallback(TimeBound a, TimeBound b) => a.time.compareTo(b.time);

    final sorted = isSorted || this.isSorted(sortCallback)
        ? this
        : this.sorted(sortCallback);

    var totalTs = timespan ??
        Timespan(
          begin: sorted.first.time,
          end: sorted.last.time,
        );
    if (totalTs.duration == Duration.zero) {
      totalTs = Timespan(
          begin: group.findBegin(sorted.first.time),
          duration: group.delta(sorted.first.time));
    }

    final List<Timespan> timespans = totalTs.splitBy(group);

    if (group == SplitType.total) {
      return [
        TimespanningData(
          timespan: timespans.first,
          value: sorted.toList(),
        ),
      ];
    }

    final queue = Queue<TimespanningData<List<T>>>();
    final innerQueue = Queue<T>();

    int index = 0;

    for (final ts in timespans) {
      while (index < length && sorted[index].time.isBefore(ts.end)) {
        innerQueue.add(sorted[index]);
        index++;
      }
      queue.add(TimespanningData(timespan: ts, value: innerQueue.toList()));
      innerQueue.clear();
    }
    return queue.toList();
  }

  Iterable<TimedData<T?>> bolster({double? maxFrequency}) sync* {
    maxFrequency ??= nchunks(100).map((x) => x.toList().time.frequency()).max;

    if (time.frequency(n: length) < maxFrequency * 0.95) {
      final int x = math.max(10, 1000 ~/ maxFrequency);

      assert(x > 0);

      int dtacc = first.time.millisecondsSinceEpoch;

      yield TimedData(time: first.time, value: first);

      int iterableIndex = 1;

      while (
          iterableIndex < length && dtacc < last.time.millisecondsSinceEpoch) {
        final val = this[iterableIndex];
        if ((val.time.millisecondsSinceEpoch - dtacc - x).abs() < x * 5) {
          yield TimedData(time: val.time, value: val);
          dtacc = val.time.millisecondsSinceEpoch;
          iterableIndex++;
        } else {
          yield TimedData(
            time: DateTime.fromMillisecondsSinceEpoch(dtacc),
            value: null,
          );
          dtacc += x;
        }
      }
    } else {
      for (var m in this) {
        yield TimedData(value: m, time: m.time);
      }
    }
  }

  TimeBound? getNearest(DateTime time, {Duration? maxDeviation}) {
    if (isEmpty) {
      return null;
    }
    final DateTime? foundTime =
        this.time.getNearest(time, maxDeviation: maxDeviation);
    return foundTime == null ? null : firstWhere((e) => e.time == foundTime);
  }

  int? getNearestIndexFromSorted(DateTime time, {Duration? maxDeviation}) {
    if (isEmpty) return null;

    int low = 0;
    int high = length - 1;
    int mid;

    while (low <= high) {
      mid = (low + high) ~/ 2;

      if (this[mid] == time) {
        return mid;
      }

      if (time.isBefore(this[mid].time)) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    return (time.firstIsClosest(this[low.clamp(0, length - 1)].time,
                this[high.clamp(0, length - 1)].time)
            ? low
            : high)
        .clamp(0, length - 1);
  }

  T? getNearestFromSorted(DateTime time, {Duration? maxDeviation}) {
    if (isEmpty) return null;

    T getClosest(DateTime time, T a, T b) =>
        time.firstIsClosest(a.time, b.time) ? a : b;

    int low = 0;
    int high = length - 1;
    int mid;

    while (low <= high) {
      mid = (low + high) ~/ 2;

      if (this[mid] == time) {
        return this[mid];
      }

      if (time.isBefore(this[mid].time)) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    final T result = low == 0
        ? getClosest(time, this[0], this[1])
        : high == length - 1
            ? getClosest(time, this[high], this[high - 1])
            : getClosest(time, this[low], this[high]);

    if (maxDeviation == null ||
        result.time.difference(time).abs() < maxDeviation) {
      return result;
    } else {
      return null;
    }
  }

  /// removes all values in List<DateTime> that are closer together,
  /// than [Duration delta].
  /// The check begins at the newest element, and works backwards.
  Iterable<T> reduceToDelta(Duration delta) {
    if (isEmpty) return [];
    sort((a, b) => b.time.compareTo(a.time));
    int i = 0;
    Queue<T> reduced = Queue.from([first]);

    while (i < length) {
      if (!(reduced.last.time.difference(this[i].time) < delta &&
          (i + 1 == length ||
              reduced.last.time.difference(this[i + 1].time) < delta * 1.2))) {
        reduced.addLast(this[i]);
      }
      i++;
    }
    return reduced;
  }

  Iterable<S> selectValues<S extends TimeBound>(Iterable<DateTime> times) {
    final Map<DateTime, S> idMap =
        Map.fromEntries(map((e) => MapEntry(e.time, e as S)));
    return [for (var time in times) idMap[time]!];
  }

  Iterable<S> takeEqualySpaced<S extends TimeBound>(int n) {
    sort((a, b) => a.time.compareTo(b.time));

    return selectValues(reduceToDelta(Duration(
            milliseconds:
                (last.time.difference(first.time).inMilliseconds / n).ceil()))
        .toList()
        .time);
  }

  Timespan timespan() {
    final (begin, end) = extrema();
    return Timespan(begin: begin.time, end: end.time);
  }

  List<T> sortedByTime({bool ascending = true}) => sorted(
        ascending
            ? (a, b) => a.time.compareTo(b.time)
            : (a, b) => b.time.compareTo(a.time),
      );
}
