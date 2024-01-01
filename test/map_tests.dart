import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:mink_utils/mink_utils.dart';
import 'package:test/test.dart';

void main() {
  final linear = List<int>.generate(10, (i) => i);

  group("base", () {
    test("base", () {
      final map = {1: 0};

      expect(map.addIfNew([2], 0), {1: 0, 2: 0});
    });
  });
}
