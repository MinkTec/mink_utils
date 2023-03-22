import 'dart:collection';

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
    return [for (var time in times) idMap[time]!];
  }

  static List<S> takeEqualySpaced<S extends TimeBound>(
          List<S> data, int n) =>
      selectValues(
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
