
import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:test/test.dart';

void main() {
  group("ByteSize", () {
    test("toByte", () {
      expect(ByteSize.kb.toByte(1), 1024);
    });

    test("fromByte", () {
      expect(ByteSize.kb.fromByte(1024), 1.0);
    });
  });
}