// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:mink_dart_utils/mink_dart_utils.dart';

extension MinkUtilsTimeSpanningListExtensions on Iterable<Timespanning> {
  Iterable<Timespanning> intersectingElements(
      Iterable<Timespanning> other) sync* {
    for (var i in this)
      for (var j in other) if (i.timespan.intersects(j.timespan)) yield j;
  }

  Iterable<Timespan> get timespan sync* {
    for (var ts in this) {
      yield ts.timespan;
    }
  }
}
