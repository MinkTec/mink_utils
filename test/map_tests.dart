import 'package:mink_dart_utils/src/extensions/map_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('MapExtensions', () {
    group('copy', () {
      test('Empty map', () {
        final Map<String, dynamic> original = {};
        final Map<String, dynamic> copy = original.copy();
        expect(copy, {});
        expect(copy, isNot(same(original)));
      });

      test('Non-empty map', () {
        final Map<String, dynamic> original = {'a': 1, 'b': 'hello'};
        final Map<String, dynamic> copy = original.copy();
        expect(copy, {'a': 1, 'b': 'hello'});
        expect(copy, isNot(same(original))); // Ensure it's a new instance
      });

      test('Map with nested objects', () {
        final Map<String, dynamic> original = {
          'a': [1, 2],
          'b': {'c': 3}
        };
        final Map<String, dynamic> copy = original.copy();
        expect(copy, original);
        expect(copy, isNot(same(original)));
        expect((copy['a'] as List), original['a']);
        expect((copy['a'] as List), (same(original['a'])));
      });
    });

    group('addIfNew', () {
      test('Empty map, empty keys', () {
        final Map<String, int> map = {};
        final result = map.addIfNew([], 5);
        expect(result, {});
      });

      test('Empty map, non-empty keys', () {
        final Map<String, int> map = {};
        final result = map.addIfNew(['a', 'b'], 5);
        expect(result, {'a': 5, 'b': 5});
      });

      test('Non-empty map, new keys', () {
        final Map<String, int> map = {'a': 1};
        final result = map.addIfNew(['b', 'c'], 5);
        expect(result, {'a': 1, 'b': 5, 'c': 5});
      });

      test('Non-empty map, existing keys', () {
        final Map<String, int> map = {'a': 1};
        final result = map.addIfNew(['a', 'b'], 5);
        expect(result, {'a': 1, 'b': 5});
      });

      test('Mixed existing and new keys', () {
        final Map<String, int> map = {'a': 1};
        final result = map.addIfNew(['a', 'b', 'c'], 5);
        expect(result, {'a': 1, 'b': 5, 'c': 5});
      });
    });

    group('combined', () {
      test('Empty maps', () {
        final Map<String, int> map1 = {};
        final Map<String, int> map2 = {};
        final result = map1.combined(map2);
        expect(result, {});
      });

      test('One empty map', () {
        final Map<String, int> map1 = {'a': 1};
        final Map<String, int> map2 = {};
        final result = map1.combined(map2);
        expect(result, {'a': 1});

        final result2 = map2.combined(map1);
        expect(result2, {'a': 1});
      });

      test('Non-overlapping maps', () {
        final Map<String, int> map1 = {'a': 1};
        final Map<String, int> map2 = {'b': 2};
        final result = map1.combined(map2);
        expect(result, {'a': 1, 'b': 2});
      });

      test('Overlapping maps', () {
        final Map<String, int> map1 = {'a': 1, 'b': 2};
        final Map<String, int> map2 = {'b': 3, 'c': 4};
        final result = map1.combined(map2);
        expect(result, {'a': 1, 'b': 3, 'c': 4}); // map2's value for 'b' wins
      });
    });

    group('addIfNotNull', () {
      test('Value is null', () {
        final Map<String, int> map = {};
        map.addIfNotNull('a', null);
        expect(map, {});
      });

      test('Value is not null', () {
        final Map<String, int> map = {};
        map.addIfNotNull('a', 5);
        expect(map, {'a': 5});
      });

      test('Key already exists, value is not null', () {
        final Map<String, int> map = {'a': 1};
        map.addIfNotNull('a', 5);
        expect(map, {'a': 5});
      });
    });

    group('replaceNanWithZero', () {
      test('Empty map', () {
        final Map<String, dynamic> emptyMap = {};
        final result = emptyMap.replaceNanWithZero();
        expect(result, {});
      });

      test('Map with no NaN values', () {
        final Map<String, dynamic> map = {
          'a': 1,
          'b': 'string',
          'c': 3.14,
          'd': [1, 2, 3],
          'e': {'f': 42}
        };
        final result = map.replaceNanWithZero();
        expect(result, map);
      });

      test('Map with NaN double value', () {
        final Map<String, dynamic> map = {'a': double.nan};
        final result = map.replaceNanWithZero();
        expect(result, {'a': -1.0});
      });

      test('Map with nested NaN in map', () {
        final Map<String, dynamic> map = {
          'a': {'b': double.nan}
        };
        final result = map.replaceNanWithZero();
        expect(result, {
          'a': {'b': -1.0}
        });
      });

      test('Map with nested NaN in list', () {
        final Map<String, dynamic> map = {
          'a': [1, double.nan, 3]
        };
        final result = map.replaceNanWithZero();
        expect(result, {
          'a': [1, -1.0, 3]
        });
      });

      test('Map with nested NaN in list within map', () {
        final Map<String, dynamic> map = {
          'a': {
            'b': [1, double.nan, 3]
          }
        };
        final result = map.replaceNanWithZero();
        expect(result, {
          'a': {
            'b': [1, -1.0, 3]
          }
        });
      });

      test('Map with multiple NaN values at different levels', () {
        final Map<String, dynamic> map = {
          'a': double.nan,
          'b': {'c': double.nan, 'd': 1},
          'e': [
            double.nan,
            2,
            {'f': double.nan}
          ]
        };
        final result = map.replaceNanWithZero();
        expect(result, {
          'a': -1.0,
          'b': {'c': -1.0, 'd': 1},
          'e': [
            -1.0,
            2,
            {'f': -1.0}
          ]
        });
      });

      test('Map with non-double NaN', () {
        final Map<String, dynamic> map = {'a': double.nan.toString()};
        final result = map.replaceNanWithZero();
        expect(result, map); // String should not be touched.
      });

      test('Map with null value', () {
        final Map<String, dynamic> map = {'a': null};
        final result = map.replaceNanWithZero();
        expect(result, map); // Null should not be touched.
      });

      test('Map with a mix of types and NaN', () {
        final Map<String, dynamic> map = {
          'int': 1,
          'double': 3.14,
          'string': 'hello',
          'bool': true,
          'list': [1, 'a', double.nan],
          'map': {'nestedDouble': double.nan, 'nestedString': 'world'},
          'nanDouble': double.nan,
          'nullValue': null,
        };
        final expected = {
          'int': 1,
          'double': 3.14,
          'string': 'hello',
          'bool': true,
          'list': [1, 'a', -1.0],
          'map': {'nestedDouble': -1.0, 'nestedString': 'world'},
          'nanDouble': -1.0,
          'nullValue': null,
        };
        final result = map.replaceNanWithZero();
        expect(result, expected);
      });
    });
  });

  group('NumericMapExtensions', () {
    test('increment', () {
      final Map<String, int> map = {};
      map.increment('a');
      expect(map, {'a': 1});

      map.increment('a');
      expect(map, {'a': 2});
    });

    test('decrement', () {
      final Map<String, int> map = {};
      map.decrement('a');
      expect(map, {'a': -1});

      map.decrement('a');
      expect(map, {'a': -2});
    });

    test('add', () {
      final Map<String, int> map = {};
      map.add('a', 5);
      expect(map, {'a': 5});

      map.add('a', -2);
      expect(map, {'a': 3});
    });
  });
}
