// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:mink_dart_utils/mink_dart_utils.dart';

extension MinkUtilsTimespanIterableExtensions on Iterable<Timespan> {
  Timespan totalSpan() {
    final Timespan ts = firstOrNull ?? Timespan(duration: Duration.zero);
    for (var elem in this) {
      if (elem.begin.isBefore(ts.begin))
        ts.update(begin: elem.begin, end: ts.end);
      if (elem.end.isAfter(ts.end)) ts.update(begin: ts.begin, end: elem.end);
    }
    return ts;
  }

  Iterable<Timespan> intersectingElements(Iterable<Timespan> other) sync* {
    for (var i in this) for (var j in other) if (i.intersects(j)) yield j;
  }
}
