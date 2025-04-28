import 'package:mink_dart_utils/src/clock.dart';
import 'package:mink_dart_utils/src/models/timed_data.dart';
import 'package:mink_dart_utils/src/models/timespan.dart';

extension FutureExtensions<T> on Future<T> {
  Future<TimespanningData<T>> stopwatch() async {
    final now = dartClock.now();
    final res = await this;
    return TimespanningData(
        value: res, timespan: Timespan(begin: now, end: dartClock.now()));
  }

  Future<T?> tryAwait() async {
    try {
      return await this;
    } catch (e) {
      return null;
    }
  }
}
