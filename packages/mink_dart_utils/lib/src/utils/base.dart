String twoDigits(int n) => n.toString().padLeft(2, "0");

T id<T>(T a) => a;

Future<void> sleepms(int ms) => Future.delayed(Duration(milliseconds: ms));
