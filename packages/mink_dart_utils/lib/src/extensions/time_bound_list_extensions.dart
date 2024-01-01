import 'dart:collection';

import 'package:mink_dart_utils/src/extensions/datetime_list_extensions.dart';
import 'package:mink_dart_utils/src/mixins/time_bound.dart';

extension DateTimeExtensionWrapper<T extends TimeBound> on List<TimeBound> {
  List<DateTime> get time => [for (var tb in this) tb.time];

  TimeBound? getNearest(DateTime time, {Duration? maxDeviation}) {
    final DateTime? foundTime =
        this.time.getNearest(time, maxDeviation: maxDeviation);
    return foundTime == null ? null : firstWhere((e) => e.time == foundTime);
  }

  /// removes all values in List<DateTime> that are closer together,
  /// than [Duration delta].
  /// The check begins at the newest element, and works backwards.
  Iterable<TimeBound> reduceToDelta(Duration delta) {
    if (isEmpty) return [];
    sort((a, b) => b.time.compareTo(a.time));
    int i = 0;
    Queue<TimeBound> reduced = Queue.from([first]);

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
}
