
import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:test/test.dart';

void main() {
  group('PlatformInfo', () {
    test('isMobile', () {
      expect(PlatformInfo.isMobile, isNotNull);
    });

    test('pathSeparator', () {
      expect(PlatformInfo.pathSeperator, isNotEmpty);
    });
  });
}