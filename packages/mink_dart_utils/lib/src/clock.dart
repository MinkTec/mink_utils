final dartClock = ClockSingleton();

class ClockSingleton {
  static final ClockSingleton _instance = ClockSingleton._internal();

  ClockSingleton._internal();

  factory ClockSingleton() {
    return _instance;
  }

  DateTime Function() _clockFunc = DateTime.now;

  void setClock(DateTime Function() clock) => _clockFunc = clock;

  DateTime now() => _clockFunc();
}
