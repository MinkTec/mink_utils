import 'dart:math' as math;

enum ByteSize {
  byte,
  kb,
  mb,
  gb,
  tb;

  int toByte(int x) => x * math.pow(1024, index).toInt();

  int fromByte(int x) => x ~/ math.pow(1024, index);
}
