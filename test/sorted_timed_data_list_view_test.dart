import 'package:flutter_test/flutter_test.dart';
import 'package:mink_utils/mink_utils.dart';

void main() {
  group('SortedTimeBoundDataListView', () {
    late List<TimedData<int>> testData;
    late SortedTimeBoundDataList<TimedData<int>> fullList;

    setUp(() {
      // Create test data with values 0-9 at times 0-9 seconds from epoch
      testData = List.generate(
        10,
        (i) => TimedData(
          value: i,
          time: DateTime.fromMillisecondsSinceEpoch(i * 1000),
        ),
      );
      fullList = SortedTimeBoundDataList(testData, isSorted: true);
    });

    group('Constructor and Basic Properties', () {
      test('creates view with default bounds', () {
        final view = SortedTimeBoundDataListView(testData, isSorted: true);
        expect(view.length, equals(10));
        expect(view.startIndex, equals(0));
        expect(view.endIndex, equals(9));
      });

      test('creates view with custom bounds', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 7,
        );
        expect(view.length, equals(6)); // indices 2-7 inclusive
        expect(view.startIndex, equals(2));
        expect(view.endIndex, equals(7));
      });

      test('handles empty view when start > end', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 5,
          endIndex: 3,
        );
        expect(view.length, equals(0));
        expect(view.isEmpty, isTrue);
        expect(view.isNotEmpty, isFalse);
      });

      test('single element view', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 5,
          endIndex: 5,
        );
        expect(view.length, equals(1));
        expect(view.first.value, equals(5));
        expect(view.last.value, equals(5));
      });
    });

    group('Element Access', () {
      late SortedTimeBoundDataListView<TimedData<int>> view;

      setUp(() {
        view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 7,
        );
      });

      test('accesses elements by index', () {
        expect(view[0].value, equals(2)); // startIndex 2
        expect(view[1].value, equals(3));
        expect(view[5].value, equals(7)); // endIndex 7
      });

      test('first returns correct element', () {
        expect(view.first.value, equals(2));
      });

      test('last returns correct element', () {
        expect(view.last.value, equals(7));
      });

      test('single throws for multiple elements', () {
        expect(() => view.single, throwsStateError);
      });

      test('elementAt returns correct element', () {
        expect(view.elementAt(2).value, equals(4));
      });

      test('throws RangeError for invalid index', () {
        expect(() => view[6], throwsRangeError);
        expect(() => view[-1], throwsRangeError);
      });

      test('throws StateError for empty view', () {
        final emptyView = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 5,
          endIndex: 3,
        );
        expect(() => emptyView.first, throwsStateError);
        expect(() => emptyView.last, throwsStateError);
      });
    });

    group('Sublist Operations', () {
      late SortedTimeBoundDataListView<TimedData<int>> view;

      setUp(() {
        view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 7,
        );
      });

      test('sublist returns correct range', () {
        final sub = view.sublist(1, 4);
        expect(sub.length, equals(3));
        expect(sub[0].value, equals(3));
        expect(sub[2].value, equals(5));
      });

      test('sublist with only start', () {
        final sub = view.sublist(3);
        expect(sub.length, equals(3)); // from index 3 to end
        expect(sub[0].value, equals(5));
        expect(sub[2].value, equals(7));
      });

      test('getRange returns correct iterable', () {
        final range = view.getRange(1, 4).toList();
        expect(range.length, equals(3));
        expect(range[0].value, equals(3));
        expect(range[2].value, equals(5));
      });

      test('sublist throws on invalid range', () {
        expect(() => view.sublist(-1, 3), throwsRangeError);
        expect(() => view.sublist(0, 10), throwsRangeError);
        expect(() => view.sublist(4, 2), throwsRangeError);
      });
    });

    group('Search Operations', () {
      late SortedTimeBoundDataListView<TimedData<int>> view;

      setUp(() {
        view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 7,
        );
      });

      test('indexOf finds element in view', () {
        expect(view.indexOf(testData[4]),
            equals(2)); // view index 2 = data index 4
      });

      test('indexOf returns -1 for element outside view', () {
        expect(view.indexOf(testData[0]), equals(-1));
        expect(view.indexOf(testData[9]), equals(-1));
      });

      test('lastIndexOf finds element', () {
        expect(view.lastIndexOf(testData[7]), equals(5));
      });

      test('indexWhere finds first matching element', () {
        final index = view.indexWhere((e) => e.value > 4);
        expect(index, equals(3)); // value 5 at view index 3
      });

      test('lastIndexWhere finds last matching element', () {
        final index = view.lastIndexWhere((e) => e.value < 6);
        expect(index, equals(3)); // value 5 at view index 3
      });

      test('contains returns true for element in view', () {
        expect(view.contains(testData[5]), isTrue);
      });

      test('contains returns false for element outside view', () {
        expect(view.contains(testData[0]), isFalse);
        expect(view.contains(testData[9]), isFalse);
      });
    });

    group('Iteration', () {
      late SortedTimeBoundDataListView<TimedData<int>> view;

      setUp(() {
        view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 5,
        );
      });

      test('iterator iterates over view elements', () {
        final values = <int>[];
        for (final item in view) {
          values.add(item.value);
        }
        expect(values, equals([2, 3, 4, 5]));
      });

      test('forEach applies function to all elements', () {
        final values = <int>[];
        view.forEach((e) => values.add(e.value));
        expect(values, equals([2, 3, 4, 5]));
      });

      test('map transforms elements', () {
        final mapped = view.map((e) => e.value * 2).toList();
        expect(mapped, equals([4, 6, 8, 10]));
      });

      test('where filters elements', () {
        final filtered = view.where((e) => e.value % 2 == 0).toList();
        expect(filtered.length, equals(2));
        expect(filtered[0].value, equals(2));
        expect(filtered[1].value, equals(4));
      });

      test('reversed returns reversed iterable', () {
        final reversed = view.reversed.toList();
        expect(reversed.length, equals(4));
        expect(reversed[0].value, equals(5));
        expect(reversed[3].value, equals(2));
      });
    });

    group('Boolean Operations', () {
      late SortedTimeBoundDataListView<TimedData<int>> view;

      setUp(() {
        view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 5,
        );
      });

      test('any returns true when predicate matches', () {
        expect(view.any((e) => e.value == 3), isTrue);
        expect(view.any((e) => e.value == 10), isFalse);
      });

      test('every returns true when all match', () {
        expect(view.every((e) => e.value >= 2), isTrue);
        expect(view.every((e) => e.value < 5), isFalse);
      });

      test('firstWhere finds first matching element', () {
        final result = view.firstWhere((e) => e.value > 3);
        expect(result.value, equals(4));
      });

      test('firstWhere calls orElse when no match', () {
        final result = view.firstWhere(
          (e) => e.value > 10,
          orElse: () => TimedData(value: -1, time: DateTime.now()),
        );
        expect(result.value, equals(-1));
      });

      test('lastWhere finds last matching element', () {
        final result = view.lastWhere((e) => e.value < 5);
        expect(result.value, equals(4));
      });

      test('singleWhere finds single matching element', () {
        final result = view.singleWhere((e) => e.value == 3);
        expect(result.value, equals(3));
      });

      test('singleWhere throws when multiple matches', () {
        expect(
          () => view.singleWhere((e) => e.value > 2),
          throwsStateError,
        );
      });
    });

    group('Aggregate Operations', () {
      late SortedTimeBoundDataListView<TimedData<int>> view;

      setUp(() {
        view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 5,
        );
      });

      test('fold accumulates values', () {
        final sum = view.fold<int>(0, (prev, e) => prev + e.value);
        expect(sum, equals(14)); // 2+3+4+5
      });

      test('reduce combines elements', () {
        final result = view.reduce((a, b) => TimedData(
              value: a.value + b.value,
              time: b.time,
            ));
        expect(result.value, equals(14));
      });

      test('reduce throws on empty view', () {
        final emptyView = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 5,
          endIndex: 3,
        );
        expect(() => emptyView.reduce((a, b) => a), throwsStateError);
      });
    });

    group('Collection Operations', () {
      late SortedTimeBoundDataListView<TimedData<int>> view;

      setUp(() {
        view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 5,
        );
      });

      test('toList creates new list', () {
        final list = view.toList();
        expect(list.length, equals(4));
        expect(list[0].value, equals(2));
        expect(list[3].value, equals(5));
      });

      test('toSet creates set', () {
        final set = view.toSet();
        expect(set.length, equals(4));
      });

      test('asMap creates map with indices', () {
        final map = view.asMap();
        expect(map.length, equals(4));
        expect(map[0]!.value, equals(2));
        expect(map[3]!.value, equals(5));
      });

      test('join concatenates elements', () {
        final joined = view.map((e) => e.value.toString()).join(',');
        expect(joined, equals('2,3,4,5'));
      });

      test('skip skips elements', () {
        final skipped = view.skip(2).toList();
        expect(skipped.length, equals(2));
        expect(skipped[0].value, equals(4));
      });

      test('take takes elements', () {
        final taken = view.take(2).toList();
        expect(taken.length, equals(2));
        expect(taken[0].value, equals(2));
        expect(taken[1].value, equals(3));
      });

      test('expand flattens elements', () {
        final expanded = view.expand((e) => [e.value, e.value * 10]).toList();
        expect(expanded, equals([2, 20, 3, 30, 4, 40, 5, 50]));
      });

      test('followedBy chains iterables', () {
        final followed = view.followedBy([
          TimedData(value: 100, time: DateTime.now()),
        ]).toList();
        expect(followed.length, equals(5));
        expect(followed[4].value, equals(100));
      });
    });

    group('Timespan Operations', () {
      test('totalTimespan returns correct span for view', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 7,
        );
        final timespan = view.totalTimespan();
        expect(
          timespan.begin,
          equals(DateTime.fromMillisecondsSinceEpoch(2000)),
        );
        expect(
          timespan.end,
          equals(DateTime.fromMillisecondsSinceEpoch(7000)),
        );
      });

      test('totalTimespan returns zero duration for empty view', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 5,
          endIndex: 3,
        );
        final timespan = view.totalTimespan();
        expect(timespan.duration, equals(Duration.zero));
      });
    });

    group('Immutability', () {
      late SortedTimeBoundDataListView<TimedData<int>> view;

      setUp(() {
        view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 2,
          endIndex: 5,
        );
      });

      test('add throws UnsupportedError', () {
        expect(
          () => view.add(TimedData(value: 99, time: DateTime.now())),
          throwsUnsupportedError,
        );
      });

      test('addAll throws UnsupportedError', () {
        expect(
          () => view.addAll([TimedData(value: 99, time: DateTime.now())]),
          throwsUnsupportedError,
        );
      });

      test('insert throws UnsupportedError', () {
        expect(
          () => view.insert(0, TimedData(value: 99, time: DateTime.now())),
          throwsUnsupportedError,
        );
      });

      test('remove throws UnsupportedError', () {
        expect(
          () => view.remove(testData[2]),
          throwsUnsupportedError,
        );
      });

      test('removeAt throws UnsupportedError', () {
        expect(
          () => view.removeAt(0),
          throwsUnsupportedError,
        );
      });

      test('removeLast throws UnsupportedError', () {
        expect(
          () => view.removeLast(),
          throwsUnsupportedError,
        );
      });

      test('clear throws UnsupportedError', () {
        expect(
          () => view.clear(),
          throwsUnsupportedError,
        );
      });

      test('sort throws UnsupportedError', () {
        expect(
          () => view.sort(),
          throwsUnsupportedError,
        );
      });

      test('set length throws UnsupportedError', () {
        expect(
          () => view.length = 5,
          throwsUnsupportedError,
        );
      });

      test('set first throws UnsupportedError', () {
        expect(
          () => view.first = TimedData(value: 99, time: DateTime.now()),
          throwsUnsupportedError,
        );
      });

      test('set last throws UnsupportedError', () {
        expect(
          () => view.last = TimedData(value: 99, time: DateTime.now()),
          throwsUnsupportedError,
        );
      });
    });

    group('Edge Cases', () {
      test('view of entire list behaves like full list', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 0,
          endIndex: 9,
        );
        expect(view.length, equals(testData.length));
        expect(view.first.value, equals(testData.first.value));
        expect(view.last.value, equals(testData.last.value));
      });

      test('view at end of list', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 8,
          endIndex: 9,
        );
        expect(view.length, equals(2));
        expect(view.first.value, equals(8));
        expect(view.last.value, equals(9));
      });

      test('view at start of list', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 0,
          endIndex: 1,
        );
        expect(view.length, equals(2));
        expect(view.first.value, equals(0));
        expect(view.last.value, equals(1));
      });

      test('iterator on empty view', () {
        final view = SortedTimeBoundDataListView(
          testData,
          isSorted: true,
          startIndex: 5,
          endIndex: 3,
        );
        final items = <TimedData<int>>[];
        for (final item in view) {
          items.add(item);
        }
        expect(items, isEmpty);
      });
    });
  });
}
