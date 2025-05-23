import 'package:mink_flutter_utils/mink_flutter_utils.dart';
import 'package:test/test.dart';
import 'package:mink_dart_utils/mink_dart_utils.dart';

import 'iterable_test.dart' as iterables;
import 'time_utils_test.dart' as time;
import 'histogram_test.dart' as histogram;
import 'map_tests.dart' as map;
import 'transform_test.dart' as transform;
import 'curve_fitting_test.dart' as curves;
import 'time_bound_methods.dart' as timebound;
import 'lock_test.dart' as lock;
import 'semver.dart' as semver;
import 'timeout_buffer.dart' as timeout_buffer;
import 'element_reduction.dart' as element_reduction;
import 'timebound_extensions.dart' as timebound_extensions;
import 'parallel_async_task_queue.dart' as parallel_async_task_queue;
import 'sequential_processor.dart' as sequential_processor;
import 'mink_utils_extensions_test.dart' as mink_utils_extensions_test;
import 'fraction_counter_test.dart' as fraction_counter_test;
import 'timespan_test.dart' as timespan_test;

void runAdditionalExtensionTests() {
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
  });
}

void main() {
  sequential_processor.main();
  parallel_async_task_queue.main();
  timebound_extensions.main();
  element_reduction.main();
  timeout_buffer.main();
  curves.main();
  iterables.main();
  time.main();
  histogram.main();
  map.main();
  transform.main();
  timebound.main();
  lock.main();
  semver.main();
  mink_utils_extensions_test.main();
  fraction_counter_test.main();
  timespan_test.main();
  runAdditionalExtensionTests();
}
