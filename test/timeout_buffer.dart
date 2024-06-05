import 'dart:async';
import 'dart:math';

import 'package:test/test.dart';
import 'package:mink_utils/mink_utils.dart';

main() async {
  group("timeout value", () {
    int counter = 0;

    final value = TimeoutValue<int>(
        value: 0,
        timeout: Duration(milliseconds: 100),
        onTimeout: (x) {
          counter = x;
        });

    test("baseline", () {
      expect(value.value, 0);
      expect(counter, 0);
    });

    test("set value", () async {
      int counter = 0;
      final value = TimeoutValue<int>(
          value: 0,
          timeout: Duration(milliseconds: 100),
          onTimeout: (x) {
            counter = x;
          });

      value.value = 1;
      expect(value.value, 1);
      expect(counter, 0);

      await sleepms(110);
      expect(value.value, 1);
      counter = 1;
    });
  });

  group("timeout buffer", () {
    final List<int> callbackCounter = [];
    final buffer = TimeoutBuffer<int>(
      onFilled: (x) => callbackCounter.add(x.length),
      timeout: Duration(milliseconds: 100),
      size: 50,
    );

    test("callback", () async {
      for (int i = 0; i < 120; i++) {
        buffer.add(i);
      }
      expect(callbackCounter.length, 2);
      expect(callbackCounter[0], 50);
      expect(callbackCounter[1], 50);

      await Future.delayed(Duration(milliseconds: 120));
      expect(callbackCounter.length, 3);

      expect(callbackCounter[2], 20);
    });

    test("timeout", () async {
      callbackCounter.clear();

      final completer = Completer();

      Timer.periodic(Duration(milliseconds: 80), (i) {
        if (i.tick < 10) {
          buffer.add(i.tick);
        } else {
          completer.complete();
          i.cancel();
        }
      });

      await completer.future;

      expect(callbackCounter.length, 0);

      await Future.delayed(Duration(milliseconds: 120));
      expect(callbackCounter.length, 1);
    });
  });
}
