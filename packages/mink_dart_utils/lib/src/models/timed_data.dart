import 'package:mink_dart_utils/mink_dart_utils.dart';

class TimedData<T> with TimeBound {
  T value;

  @override
  DateTime time;

  TimedData({required this.value, DateTime? time})
      : time = time ?? DateTime.now();
}

class MaybeTimedData<T> {
  T value;
  DateTime? time;

  MaybeTimedData({required this.value, this.time});
}
