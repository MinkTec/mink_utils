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
