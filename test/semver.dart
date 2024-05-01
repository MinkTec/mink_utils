import 'package:mink_utils/mink_utils.dart';
import 'package:test/test.dart';

void main() {
  group("semver", () {
    test("equality", () async {
      final a = SemVer.fromList([5, 0, 0]);
      final b = SemVer(major: 5);
      final c = SemVer.parse("5.0.0");

      expect(a == b, true);
      expect(a == c, true);
      expect(b == c, true);
    });

    test("comparision", () async {
      final a = SemVer.fromList([5, 0, 1]);
      final b = SemVer(major: 4, minor: 9, patch: 1);
      final c = SemVer.parse("5.0.2");

      expect(a > b, true);
      expect(a < c, true);
      expect(a <= a, true);
      expect(a < a, false);
    });
  });
}
