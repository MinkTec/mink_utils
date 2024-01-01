import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:mink_dart_utils/src/extensions/datetime_extensions.dart';
import 'package:mink_dart_utils/src/extensions/datetime_list_extensions.dart';
import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';
import 'package:mink_dart_utils/src/extensions/list_extensions.dart';
import 'package:mink_dart_utils/src/extensions/time_bound_list_extensions.dart';
import 'package:mink_dart_utils/src/models/timespan.dart';

mixin TimeBound {
  abstract final DateTime time;
}

/// This class only exists becuase it isn't possible to
/// use Generics with extenions of mixins.
/// If the <T extends TimeBound>  syntax is used with an
/// extension, the Object ist cast to TimeBound and looses
/// it's original type.
/// Applying the same in a class doesn't produce te same problem.
class TimeBoundMethods {
  /// removes all values in List<DateTime> that are closer together,
  /// than [Duration delta].
  /// The check begins at the newest element, and works backwards.
  static Iterable<T> reduceToDelta<T extends TimeBound>(
      List<T> data, Duration delta) {
    if (data.isEmpty) return [];
    data.sort((a, b) => b.time.compareTo(a.time));
    int i = 0;
    Queue<T> reduced = Queue.from([data.first]);

    while (i < data.length) {
      if (!(reduced.last.time.difference(data[i].time) < delta &&
          (i + 1 == data.length ||
              reduced.last.time.difference(data[i + 1].time) < delta * 1.2))) {
        reduced.addLast(data[i]);
      }
      i++;
    }
    return reduced;
  }

  static List<S> selectValues<S extends TimeBound>(
      List<S> data, Iterable<DateTime> times) {
    final Map<DateTime, S> idMap =
        Map.fromEntries(data.map((e) => MapEntry(e.time, e)));
    return times.eagerMap((e) => idMap[e]!);
  }

  /// bruh
  @Deprecated("bruh")
  static List<S> takeSmart<S extends TimeBound>(List<S> vals) {
    if (vals.isEmpty) return [];
    if (!vals.time.isSorted((a, b) => a.compareTo(b))) {
      vals.sort((a, b) => a.time.compareTo(b.time));
    }
    final ts = Timespan(begin: vals.first.time, end: vals.last.time);
    final blocks =
        vals.time.findBlocks(Duration(seconds: ts.duration.inSeconds ~/ 30));

    final sparsestTimespan = blocks.elementAt([
      for (var t in blocks)
        vals
            .eagerWhere((e) => e.time.isIn(t))
            .time
            .diff()
            .map((e) => e.inMilliseconds.abs())
            .average
    ].indexOfMax);

    return takeEqualySpaced(
        vals,
        (vals.where((e) => e.time.isIn(sparsestTimespan)).length *
            blocks.totalDuration().inMilliseconds ~/
            sparsestTimespan.duration.inMilliseconds));
  }

  /// this function has an edgecase where -- if verey timestamp is exactly equaly
  /// spaced it selects n + 1 values
  static List<S> takeEqualySpaced<S extends TimeBound>(List<S> data, int n) {
    data.sort((a, b) => a.time.compareTo(b.time));
    return selectValues(
        data,
        reduceToDelta(
                data,
                Duration(
                    milliseconds: (data.last.time
                                .difference(data.first.time)
                                .inMilliseconds /
                            n)
                        .ceil()))
            .map((e) => e.time));
  }
}
