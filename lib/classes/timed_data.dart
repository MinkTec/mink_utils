class TimedData<T> {
  T value;
  DateTime time;

  TimedData({required this.value, DateTime? time})
      : time = time ?? DateTime.now();
}

class MaybeTimedData<T> {
  T value;
  DateTime? time;

  MaybeTimedData({required this.value, this.time});
}
