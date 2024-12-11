import 'dart:math';

import 'package:mink_utils/mink_utils.dart';
import 'package:test/test.dart';

Future<void> main() async {
  group("parallel async task queue", () {
    final input = List.generate(100, (index) => index);

    int current = 0;
    int total = 0;

    ParallelAsyncTaskQueue<int, int> queue = ParallelAsyncTaskQueue(
      input: input,
      map: (input) async => input,
      maxParallel: 30,
      progressCallback: (current, total) {
        current = current;
        total = total;
      },
    );

    test("empty input", () async {
      final output = await queue.copyWith(input: []).run();
      expect(output, []);
    });

    test("generic", () async {
      final output = await queue.run();
      expect(current, total);
      expect(output, input);
    });

    test("sequencial", () async {
      final output = await queue.copyWith(maxParallel: 1).run();
      expect(current, total);
      expect(output, input);
    });

    test("all", () async {
      final output = await queue.copyWith(maxParallel: 100000).run();
      expect(current, total);
      expect(output, input);
    });

    test("order", () async {
      final output = await queue
          .copyWith(
              map: (input) async {
                await Future.delayed(
                    Duration(milliseconds: Random().nextInt(200)));
                return input;
              },
              maxParallel: 100)
          .run();
      expect(current, total);
      expect(output, input);
    });

    test("error handling", () async {
      final output = await ParallelAsyncTaskQueue<int, int>(
        input: input,
        map: (input) async {
          if (input == 50) {
            throw Exception("error");
          }
          return input;
        },
        maxParallel: 30,
        onError: (e, x) async {
          return 0;
        },
        progressCallback: (current, total) {
          current = current;
          total = total;
        },
      ).run();
      expect(current, total);
      expect(output, List.generate(100, (index) => index == 50 ? 0 : index));
    });
  });
}
