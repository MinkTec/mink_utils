import 'package:mink_dart_utils/src/mixins/time_bound.dart';

extension MinkUtilsStreamExtension<T> on Stream<T> {
  /// only pick on element at most after [duration]
  Stream<T> pickSample(
    Duration duration, {
    double tolerance = 0,
  }) {
    DateTime? last;

    DateTime current = DateTime.now();

    final toleratedDuration = duration * (1 - tolerance);

    return where((x) {
      current = DateTime.now();
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
}
