
import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:test/test.dart';

void main() {
  group("ListExtensions", () {
    test("rotate", () {
      final list = [1, 2, 3, 4];
      expect(list.rotate(1).toList(), [2, 3, 4, 1]);
    });

    test("shuffled", () {
      final list = [1, 2, 3, 4];
      expect(list.shuffled.length, list.length);
    });
  });
}