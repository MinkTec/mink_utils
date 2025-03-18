
import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:test/test.dart';

void main() {
  group("SemVer", () {
    test("toString", () {
      final version = SemVer(major: 1, minor: 2, patch: 3, label: "alpha");
      expect(version.toString(), "1.2.3+alpha");
    });

    test("comparison operators", () {
      final v1 = SemVer(major: 1, minor: 0, patch: 0);
      final v2 = SemVer(major: 1, minor: 1, patch: 0);
      expect(v1 < v2, true);
      expect(v2 > v1, true);
      expect(v1 <= v1, true);
      expect(v1 >= v1, true);
    });
  });
}