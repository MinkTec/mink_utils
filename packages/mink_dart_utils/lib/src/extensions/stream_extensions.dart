import 'dart:collection';

import 'package:mink_dart_utils/src/clock.dart';
import 'package:mink_dart_utils/src/mixins/time_bound.dart';

extension MinkUtilsStreamExtension<T> on Stream<T> {
  /// only pick on element at most after [duration]
  Stream<T> pickSample(
    Duration duration, {
    double tolerance = 0,
  }) {
    DateTime? last;

    DateTime current = dartClock.now();

    final toleratedDuration = duration * (1 - tolerance);

    return where((x) {
      current = dartClock.now();
      if (last == null || current.difference(last!) > toleratedDuration) {
        last = current;
        return true;
      } else {
        return false;
      }
    });
  }
}

extension MinkUtilsTimeBoundStreamExtension<T extends TimeBound> on Stream<T> {
  /// only pick on element at most after [duration]
  Stream<T> pickTimeBoundSample(
    Duration duration, {
    double tolerance = 0,

    /// for using synthetic data for testing
    bool allowTimetravel = false,
  }) {
    DateTime? last;
    DateTime current;
    final toleratedDuration = duration * (1 - tolerance);

    return where((x) {
      current = x.time;
      if (last == null ||
          current.difference(last!) > toleratedDuration ||
          (allowTimetravel && current.isBefore(last!))) {
        last = current;
        return true;
      } else {
        return false;
      }
    });
  }

  Stream<T> pickSampleWithRollingOverflowWindow({
    required Duration window,
    required int maxCount,
    Duration? minAcceptanceDelta,
  }) async* {
    final acceptedTimes = Queue<DateTime>();
    await for (final measurement in this) {
      final now = measurement.time;

      // 1) Remove old accepted timestamps that are outside the 1-second window.
      while (acceptedTimes.isNotEmpty &&
          now.difference(acceptedTimes.first) >= window) {
        acceptedTimes.removeFirst();
      }

      // 2) Check how many we have left in the last second.
      if (acceptedTimes.length < maxCount &&
          (acceptedTimes.isEmpty ||
              minAcceptanceDelta == null ||
              now.difference(acceptedTimes.last) >= minAcceptanceDelta)) {
        // We can accept this measurement
        yield measurement;
        acceptedTimes.addLast(now);
      }
      // else -> We discard the measurement (because we already have 5 in the last second).
    }
  }
}
