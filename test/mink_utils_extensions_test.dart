import 'package:test/test.dart';
import 'package:mink_dart_utils/mink_dart_utils.dart';

void main() {
  group('mink_dart_utils uncovered extensions', () {
    test('record_zip extensions', () {
      final a = [1, 2, 3];
      final b = ['a', 'b', 'c'];
      final zipped2 = (a, b).zip();
      expect(zipped2, [(1, 'a'), (2, 'b'), (3, 'c')]);
      final c = [true, false, true];
      final zipped3 = (a, b, c).zip();
      expect(zipped3, [(1, 'a', true), (2, 'b', false), (3, 'c', true)]);
    });
    test('function_extensions time()', () {
      int f() => 42;
      expect(f.time('test'), 42);
    });
    test('num_extensions', () {
      expect(90.toRad(), closeTo(1.5708, 0.001));
      expect(1.5708.toDeg(), closeTo(90, 0.1));
      expect(5.clamp(0, 10), 5);
      expect((-0.0).disp, '0');
      expect(90.trigDisp, '5157°');
      expect(double.infinity.finite, 0.0);
    });
    test('string_extensions', () {
      expect('01:02:03'.durationFromTimestamp(),
          Duration(hours: 1, minutes: 2, seconds: 3));
      expect('äöüÄÖÜß'.replaceUmlaute(), 'aeoeueAeOeUess');
      expect('foo bar'.replaceWhitespace('_'), 'foo_bar');
      expect('Hello'.capitalizeFirst(), 'Hello');
      expect('2020-01-02'.dateTimeFromString(), DateTime(2020, 1, 2));
      expect('[abc]'.removeBrackets(), 'abc');
      expect('CamelCase'.toSnakeCase(), '_camel_case');
      expect('abcdef'.elipsify(3), 'abc...');
      expect((null as String?).isEmptyOrNull, true);
      expect(''.isEmptyOrNull, true);
      expect('not empty'.isEmptyOrNull, false);
    });
    test('double_extensions', () {
      expect((42.0).finite, 42.0);
      expect(double.nan.finite, 0.0);
    });
    // More tests for uncovered extensions
    test('FutureExtensions tryAwait', () async {
      Future<int> good() async => 1;
      Future<int> bad() async => throw Exception('fail');
      expect(await good().tryAwait(), 1);
      expect(await bad().tryAwait(), null);
    });
    test('NumIteratorExtensions', () {
      final nums = [1, 2, 3, 4, 5];
      expect(nums.sum, 15);
      expect(nums.max, 5);
      expect(nums.min, 1);
      expect(nums.average, 3);
      expect(nums.isMonotonic(), true);
      expect(nums.isIncreasing(), true);
      expect(nums.isDecreasing(), false);
      expect(nums.absdiff.toList(), [1, 1, 1, 1]);
    });
    test('MiscIterableIterable flatten', () {
      final nested = [
        [1, 2],
        [3, 4]
      ];
      expect(nested.flatten().toList(), [1, 2, 3, 4]);
      expect(nested.flattlength, 4);
      expect(nested.deepList(), [
        [1, 2],
        [3, 4]
      ]);
    });
    test('MapExtensions addIfNew', () {
      final map = {1: 'a'};
      final result = map.addIfNew([2, 3], 'b');
      expect(result, {1: 'a', 2: 'b', 3: 'b'});
    });
    test('DurationExtensions', () {
      final d = Duration(hours: 1, minutes: 2, seconds: 3);
      expect(d.hhmm, '1:02');
      expect(d.hhmmss, '1:02:03');
      expect(d.zeroOrAbove, d);
      expect(d.max(Duration.zero), d);
      expect(d.min(Duration(hours: 2)), d);
    });
  });
}
