import 'dart:collection';

import 'package:mink_dart_utils/src/clock.dart';
import 'package:mink_dart_utils/src/extensions/datetime_extensions.dart';
import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';
import 'package:mink_dart_utils/src/models/timespan.dart';

extension DateTimeListExtension on List<DateTime> {
  /// get Duration between each elemnt of a [List] of [DateTime]s
  Iterable<Duration> diff() => lag.map((e) => e.$2.difference(e.$1));

  /// find continuous blocks of [DateTime]s in a [List<DateTime>].
  /// Every section of one or more blocks where the [Duration] between each
  /// element and its neighbours is less than [delta] is counted as a block
  Iterable<Timespan> findBlocks([Duration delta = const Duration(minutes: 2)]) {
    if (isEmpty) return [];
    sort((a, b) => a.compareTo(b));
    return [0, ...diff().findIndices((e) => e > delta), length]
        .lag
        .map((e) => Timespan(begin: this[e.$1], end: this[e.$2 - 1]));
  }

  void sortNormal({bool ascending = true}) =>
      sort(ascending ? (a, b) => a.compareTo(b) : (b, a) => a.compareTo(b));

  List<DateTime> sortedNormal({bool ascending = true}) {
    final copy = [...this];
    copy.sort(ascending ? (a, b) => a.compareTo(b) : (b, a) => a.compareTo(b));
    return copy;
  }

  /// calculate the frequency of the give iterable
  /// either n (number of elements) or duration can be set
  /// setting both results in an ArgumentError.
  /// If none is set, all values will be evaluated.
  /// The function assumes that the list is sorted.
  /// If it's not sorted calculations with [n] ore none specified
  /// can return wrong results.
  /// If realtime is the the functions assumes that the timer interval
  /// ends [clock.now()] otherwise the lasts elements timestamp
  /// will be used.
  double frequency({int? n, Duration? duration, bool realTime = false}) {
    if (isEmpty) return 0;

    final DateTime startTime;
    final Iterable<DateTime> vals;

    if (duration != null) {
      startTime = last.subtract(duration);
      vals = where((e) => e.isAfter(startTime));
    } else if (n != null) {
      vals = reversed.take(n);
      startTime = vals.last;
    } else {
      vals = this;
      startTime = first;
    }

    final endTime = realTime ? dartClock.now() : last;

    return (vals.length / endTime.difference(startTime).inMilliseconds) * 1000;
  }

  DateTime? getNearest(DateTime time, {Duration? maxDeviation}) {
    final res = reduce(
        (a, b) => a.difference(time).abs() > b.difference(time).abs() ? b : a);
    return (maxDeviation == null ||
            res.difference(time).abs() < maxDeviation.abs())
        ? res
        : null;
  }

  DateTime? getNearestFromSorted(DateTime time, {Duration? maxDeviation}) {
    if (isEmpty) return null;

    int low = 0;
    int high = length - 1;
    int mid;

    while (low <= high) {
      mid = (low + high) ~/ 2;

      if (this[mid] == time) {
        return this[mid];
      }

      if (time.isBefore(this[mid])) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    final result = low == 0
        ? time.getClosest(this[0], this[1])
        : high == length - 1
            ? time.getClosest(this[high], this[high - 1])
            : time.getClosest(this[low], this[high]);

    if (maxDeviation == null || result.difference(time).abs() < maxDeviation) {
      return result;
    } else {
      return null;
    }
  }

  /// removes all values in List<DateTime> that are closer together,
  /// than [Duration delta].
  /// The check begins at the newest element, and works backwards.
  Iterable<DateTime> reduceToDelta(Duration delta) {
    if (isEmpty) return [];
    sort((a, b) => b.compareTo(a));
    int i = 0;
    Queue<DateTime> reduced = Queue.from([first]);

    while (i < length) {
      if (!(reduced.last.difference(this[i]) < delta &&
          (i + 1 == length ||
              reduced.last.difference(this[i + 1]) < delta * 1.2))) {
        reduced.addLast(this[i]);
      }
      i++;
    }
    return reduced;
  }

  Iterable<DateTime> takeEqualySpaced(int n) {
    sort((a, b) => a.compareTo(b));
    return reduceToDelta(Duration(
        milliseconds: (last.difference(first).inMilliseconds / n).ceil()));
  }
}
