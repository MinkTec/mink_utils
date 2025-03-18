import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:test/test.dart';

void main() {
  group("ParallelAsyncTaskQueue", () {
    final input = List<int>.generate(100, (i) => i);
    test("execute tasks", () async {
      final queue = ParallelAsyncTaskQueue<int, int>(
        input: input,
        maxParallel: 2,
        map: (input) async => input * 2,
      );
      final results = await queue.run();
      expect(results, input.eagerMap((e) => e * 2));
    });
  });
}
