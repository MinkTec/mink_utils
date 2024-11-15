import 'dart:async';

import 'package:mink_utils/mink_utils.dart';
import 'package:test/test.dart';

Future<void> main() async {
  test("lock base", () async {
    final lock = AsyncLock("str");

    expect(lock.isLocked, false);
    lock.lock();
    expect(lock.isLocked, true);

    final now = DateTime.now();
    final lockDuration = Duration(milliseconds: 50);

    Timer(lockDuration, lock.unlock);

    expect(lock.isLocked, true);

    expect(await lock.wait.then((_) => lock.isLocked), false);
    expect(
        await lock.wait.then((_) => DateTime.now().difference(now)) >=
            lockDuration,
        true);
  });
}
