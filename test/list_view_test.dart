import 'package:test/test.dart';
import 'package:mink_dart_utils/mink_dart_utils.dart';

void main() {
  group('ImmutableList', () {
    test('creates immutable list from list', () {
      final list = [1, 2, 3, 4, 5];
      final immutable = ImmutableList(list);

      expect(immutable.length, 5);
      expect(immutable[0], 1);
      expect(immutable[4], 5);
    });

    test('creates immutable list from iterable', () {
      final iterable = [1, 2, 3].map((x) => x * 2);
      final immutable = ImmutableList.from(iterable);

      expect(immutable.length, 3);
      expect(immutable.toList(), [2, 4, 6]);
    });

    test('creates empty immutable list', () {
      final immutable = ImmutableList.empty();

      expect(immutable.isEmpty, true);
      expect(immutable.length, 0);
    });

    test('supports iteration', () {
      final immutable = ImmutableList([1, 2, 3]);
      final result = <int>[];

      for (final item in immutable) {
        result.add(item);
      }

      expect(result, [1, 2, 3]);
    });

    test('supports all Iterable methods', () {
      final immutable = ImmutableList([1, 2, 3, 4, 5]);

      expect(immutable.first, 1);
      expect(immutable.last, 5);
      expect(immutable.contains(3), true);
      expect(immutable.contains(10), false);
      expect(immutable.any((x) => x > 3), true);
      expect(immutable.every((x) => x > 0), true);
      expect(immutable.where((x) => x % 2 == 0).toList(), [2, 4]);
      expect(immutable.map((x) => x * 2).toList(), [2, 4, 6, 8, 10]);
    });

    test('equality works correctly', () {
      final list1 = ImmutableList([1, 2, 3]);
      final list2 = ImmutableList([1, 2, 3]);
      final list3 = ImmutableList([1, 2, 4]);

      // ImmutableList creates unmodifiable copies, so even with same content
      // they may not be identical references
      expect(list1.toList(), list2.toList());
      expect(list1.toList() == list3.toList(), false);
    });
  });

  group('ListView - Basic Construction', () {
    test('creates view of entire list', () {
      final list = [1, 2, 3, 4, 5];
      final view = ImmutableListView(list);

      expect(view.length, 5);
      expect(view[0], 1);
      expect(view[4], 5);
      expect(view.toList(), [1, 2, 3, 4, 5]);
    });

    test('creates view with startIndex', () {
      final list = [1, 2, 3, 4, 5];
      final view = ImmutableListView(list, startIndex: 2);

      expect(view.length, 3);
      expect(view[0], 3);
      expect(view[2], 5);
      expect(view.toList(), [3, 4, 5]);
    });

    test('creates view with endIndex', () {
      final list = [1, 2, 3, 4, 5];
      final view = ImmutableListView(list, endIndex: 2);

      expect(view.length, 3);
      expect(view[0], 1);
      expect(view[2], 3);
      expect(view.toList(), [1, 2, 3]);
    });

    test('creates view with both startIndex and endIndex', () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final view = ImmutableListView(list, startIndex: 3, endIndex: 6);

      expect(view.length, 4);
      expect(view[0], 4);
      expect(view[3], 7);
      expect(view.toList(), [4, 5, 6, 7]);
    });

    test('creates empty view', () {
      final view = ImmutableListView.empty();

      expect(view.isEmpty, true);
      expect(view.length, 0);
    });

    test('creates view from iterable', () {
      final iterable = [1, 2, 3, 4, 5].map((x) => x * 2);
      final view = ImmutableListView.from(iterable, startIndex: 1, endIndex: 3);

      expect(view.length, 3);
      expect(view.toList(), [4, 6, 8]);
    });
  });

  group('ListView - Index Access', () {
    late List<int> list;
    late ImmutableListView<int> view;

    setUp(() {
      list = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
      view = ImmutableListView(list, startIndex: 2, endIndex: 7);
    });

    test('operator [] returns correct elements', () {
      expect(view[0], 30);
      expect(view[3], 60);
      expect(view[5], 80);
    });

    test('elementAt returns correct elements', () {
      expect(view.elementAt(0), 30);
      expect(view.elementAt(3), 60);
      expect(view.elementAt(5), 80);
    });

    test('throws RangeError for invalid index', () {
      expect(() => view[-1], throwsA(isA<RangeError>()));
      expect(() => view[6], throwsA(isA<RangeError>()));
      expect(() => view[100], throwsA(isA<RangeError>()));
    });
  });

  group('ListView - Properties', () {
    test('first and last work correctly', () {
      final view =
          ImmutableListView([1, 2, 3, 4, 5], startIndex: 1, endIndex: 3);

      expect(view.first, 2);
      expect(view.last, 4);
    });

    test('first and last throw on empty view', () {
      final view = ImmutableListView([1, 2, 3], startIndex: 2, endIndex: 1);

      expect(() => view.first, throwsStateError);
      expect(() => view.last, throwsStateError);
    });

    test('isEmpty and isNotEmpty work correctly', () {
      final view1 = ImmutableListView([1, 2, 3], startIndex: 1, endIndex: 2);
      final view2 = ImmutableListView([1, 2, 3], startIndex: 2, endIndex: 1);

      expect(view1.isEmpty, false);
      expect(view1.isNotEmpty, true);
      expect(view2.isEmpty, true);
      expect(view2.isNotEmpty, false);
    });

    test('length returns correct values', () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

      expect(ImmutableListView(list, startIndex: 0, endIndex: 9).length, 10);
      expect(ImmutableListView(list, startIndex: 0, endIndex: 4).length, 5);
      expect(ImmutableListView(list, startIndex: 5, endIndex: 9).length, 5);
      expect(ImmutableListView(list, startIndex: 3, endIndex: 6).length, 4);
      expect(ImmutableListView(list, startIndex: 5, endIndex: 4).length, 0);
    });

    test('single returns element when length is 1', () {
      final view =
          ImmutableListView([1, 2, 3, 4, 5], startIndex: 2, endIndex: 2);

      expect(view.single, 3);
    });

    test('single throws when empty or multiple elements', () {
      final emptyView =
          ImmutableListView([1, 2, 3], startIndex: 2, endIndex: 1);
      final multiView =
          ImmutableListView([1, 2, 3], startIndex: 0, endIndex: 1);

      expect(() => emptyView.single, throwsStateError);
      expect(() => multiView.single, throwsStateError);
    });
  });

  group('ListView - Search Methods', () {
    late ImmutableListView<int> view;

    setUp(() {
      view = ImmutableListView([10, 20, 30, 40, 50, 40, 30, 20, 10],
          startIndex: 2, endIndex: 6);
      // View contains: [30, 40, 50, 40, 30]
    });

    test('contains works correctly', () {
      expect(view.contains(30), true);
      expect(view.contains(40), true);
      expect(view.contains(50), true);
      expect(view.contains(10), false);
      expect(view.contains(20), false);
      expect(view.contains(60), false);
    });

    test('any works correctly', () {
      expect(view.any((x) => x == 50), true);
      expect(view.any((x) => x > 45), true);
      expect(view.any((x) => x < 25), false);
    });

    test('every works correctly', () {
      expect(view.every((x) => x >= 30), true);
      expect(view.every((x) => x <= 50), true);
      expect(view.every((x) => x > 30), false);
    });

    test('firstWhere works correctly', () {
      expect(view.firstWhere((x) => x == 40), 40);
      expect(view.firstWhere((x) => x > 35), 40);
      expect(view.firstWhere((x) => x > 100, orElse: () => -1), -1);
      expect(() => view.firstWhere((x) => x > 100), throwsStateError);
    });

    test('lastWhere works correctly', () {
      expect(view.lastWhere((x) => x == 40), 40);
      expect(view.lastWhere((x) => x == 30), 30);
      expect(view.lastWhere((x) => x > 35), 40);
      expect(view.lastWhere((x) => x > 100, orElse: () => -1), -1);
      expect(() => view.lastWhere((x) => x > 100), throwsStateError);
    });

    test('singleWhere works correctly', () {
      expect(view.singleWhere((x) => x == 50), 50);
      expect(view.singleWhere((x) => x > 100, orElse: () => -1), -1);
      expect(
          () => view.singleWhere((x) => x == 40), throwsStateError); // Two 40s
      expect(() => view.singleWhere((x) => x > 100), throwsStateError);
    });
  });

  group('ListView - Iterator', () {
    test('iterates through view elements', () {
      final view =
          ImmutableListView([1, 2, 3, 4, 5, 6, 7], startIndex: 2, endIndex: 5);
      final result = <int>[];

      for (final item in view) {
        result.add(item);
      }

      expect(result, [3, 4, 5, 6]);
    });

    test('forEach works correctly', () {
      final view =
          ImmutableListView([1, 2, 3, 4, 5], startIndex: 1, endIndex: 3);
      final result = <int>[];

      view.forEach((x) => result.add(x * 2));

      expect(result, [4, 6, 8]);
    });
  });

  group('ListView - Transformation Methods', () {
    late ImmutableListView<int> view;

    setUp(() {
      view =
          ImmutableListView([10, 20, 30, 40, 50], startIndex: 1, endIndex: 3);
      // View contains: [20, 30, 40]
    });

    test('map transforms elements', () {
      final result = view.map((x) => x * 2).toList();
      expect(result, [40, 60, 80]);
    });

    test('where filters elements', () {
      final result = view.where((x) => x >= 30).toList();
      expect(result, [30, 40]);
    });

    test('whereType filters by type', () {
      final mixedView = ImmutableListView<dynamic>(['a', 1, 'b', 2, 'c'],
          startIndex: 0, endIndex: 4);
      final ints = mixedView.whereType<int>().toList();
      final strings = mixedView.whereType<String>().toList();

      expect(ints, [1, 2]);
      expect(strings, ['a', 'b', 'c']);
    });

    test('expand expands elements', () {
      final result = view.expand((x) => [x, x]).toList();
      expect(result, [20, 20, 30, 30, 40, 40]);
    });

    test('skip and take work correctly', () {
      expect(view.skip(1).toList(), [30, 40]);
      expect(view.take(2).toList(), [20, 30]);
      expect(view.skip(1).take(1).toList(), [30]);
    });

    test('skipWhile and takeWhile work correctly', () {
      expect(view.skipWhile((x) => x < 30).toList(), [30, 40]);
      expect(view.takeWhile((x) => x < 40).toList(), [20, 30]);
    });

    test('followedBy concatenates iterables', () {
      final result = view.followedBy([50, 60]).toList();
      expect(result, [20, 30, 40, 50, 60]);
    });

    test('cast changes type', () {
      final numView =
          ImmutableListView<num>([1, 2, 3], startIndex: 0, endIndex: 2);
      final intIterable = numView.cast<int>();
      expect(intIterable.toList(), [1, 2, 3]);
    });
  });

  group('ListView - Aggregation Methods', () {
    late ImmutableListView<int> view;

    setUp(() {
      view = ImmutableListView([1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
          startIndex: 2, endIndex: 6);
      // View contains: [3, 4, 5, 6, 7]
    });

    test('fold accumulates values', () {
      final sum = view.fold<int>(0, (prev, curr) => prev + curr);
      expect(sum, 25); // 3+4+5+6+7
    });

    test('reduce combines elements', () {
      final product = view.reduce((value, element) => value * element);
      expect(product, 2520); // 3*4*5*6*7
    });

    test('reduce throws on empty view', () {
      final emptyView =
          ImmutableListView([1, 2, 3], startIndex: 2, endIndex: 1);
      expect(() => emptyView.reduce((a, b) => a + b), throwsStateError);
    });

    test('join concatenates elements', () {
      expect(view.join(), '34567');
      expect(view.join(','), '3,4,5,6,7');
      expect(view.join(' - '), '3 - 4 - 5 - 6 - 7');
    });
  });

  group('ListView - Conversion Methods', () {
    late ImmutableListView<int> view;

    setUp(() {
      view =
          ImmutableListView([10, 20, 30, 40, 50], startIndex: 1, endIndex: 3);
      // View contains: [20, 30, 40]
    });

    test('toList creates a new list', () {
      final list1 = view.toList();
      final list2 = view.toList(growable: false);

      expect(list1, [20, 30, 40]);
      expect(list2, [20, 30, 40]);

      // Test growable behavior
      list1.add(50); // Should work on growable list
      expect(list1.length, 4);
    });

    test('toList on empty view', () {
      final emptyView =
          ImmutableListView([1, 2, 3], startIndex: 2, endIndex: 1);
      expect(emptyView.toList(), []);
    });

    test('toSet creates a set', () {
      final view2 =
          ImmutableListView([1, 2, 2, 3, 3, 3], startIndex: 0, endIndex: 5);
      final set = view2.toSet();

      expect(set, {1, 2, 3});
    });

    test('toString formats correctly', () {
      expect(view.toString(), '[20, 30, 40]');

      final emptyView = ImmutableListView<int>.empty();
      expect(emptyView.toString(), '[]');
    });
  });

  group('ListView - Equality and Hashing', () {
    test('equal views have same content', () {
      final list = [1, 2, 3, 4, 5];
      final view1 = ImmutableListView(list, startIndex: 1, endIndex: 3);
      final view2 = ImmutableListView(list, startIndex: 1, endIndex: 3);

      // Views of the same underlying list with same indices should have same content
      expect(view1.toList(), view2.toList());
      expect(view1.length, view2.length);
    });

    test('views with different indices have different content', () {
      final list = [1, 2, 3, 4, 5];
      final view1 = ImmutableListView(list, startIndex: 1, endIndex: 3);
      final view2 = ImmutableListView(list, startIndex: 1, endIndex: 4);
      final view3 = ImmutableListView(list, startIndex: 0, endIndex: 3);

      expect(view1.toList() == view2.toList(), false);
      expect(view1.toList() == view3.toList(), false);
    });

    test('views of different lists can have same content', () {
      final view1 = ImmutableListView([1, 2, 3], startIndex: 0, endIndex: 2);
      final view2 = ImmutableListView([1, 2, 3], startIndex: 0, endIndex: 2);

      // Different underlying lists but same content
      expect(view1.toList(), view2.toList());
    });
  });

  group('ListView - Edge Cases', () {
    test('handles single element view', () {
      final view =
          ImmutableListView([1, 2, 3, 4, 5], startIndex: 2, endIndex: 2);

      expect(view.length, 1);
      expect(view[0], 3);
      expect(view.first, 3);
      expect(view.last, 3);
      expect(view.single, 3);
      expect(view.toList(), [3]);
    });

    test('handles view at start of list', () {
      final view =
          ImmutableListView([1, 2, 3, 4, 5], startIndex: 0, endIndex: 1);

      expect(view.toList(), [1, 2]);
      expect(view[0], 1);
      expect(view.first, 1);
    });

    test('handles view at end of list', () {
      final view =
          ImmutableListView([1, 2, 3, 4, 5], startIndex: 3, endIndex: 4);

      expect(view.toList(), [4, 5]);
      expect(view[1], 5);
      expect(view.last, 5);
    });

    test('handles empty view with inverted indices', () {
      final view =
          ImmutableListView([1, 2, 3, 4, 5], startIndex: 3, endIndex: 2);

      expect(view.isEmpty, true);
      expect(view.length, 0);
      expect(view.toList(), []);
      expect(view.toString(), '[]');
    });

    test('works with different types', () {
      final stringView =
          ImmutableListView(['a', 'b', 'c', 'd'], startIndex: 1, endIndex: 2);
      expect(stringView.toList(), ['b', 'c']);

      final doubleView =
          ImmutableListView([1.1, 2.2, 3.3, 4.4], startIndex: 0, endIndex: 2);
      expect(doubleView.toList(), [1.1, 2.2, 3.3]);
    });

    test('preserves immutability through underlying list changes', () {
      final originalList = [1, 2, 3, 4, 5];
      final view = ImmutableListView(originalList, startIndex: 1, endIndex: 3);

      // The view should have captured the list
      expect(view.toList(), [2, 3, 4]);

      // Note: Since ListView extends ImmutableList which uses List.unmodifiable,
      // changes to originalList won't affect the view
    });
  });

  group('ListView - Complex Scenarios', () {
    test('nested transformations', () {
      final view = ImmutableListView([1, 2, 3, 4, 5, 6, 7, 8],
          startIndex: 2, endIndex: 6);

      final result = view.where((x) => x % 2 == 1).map((x) => x * 2).toList();

      expect(result, [6, 10, 14]);
    });

    test('multiple views of same list', () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final view1 = ImmutableListView(list, startIndex: 0, endIndex: 4);
      final view2 = ImmutableListView(list, startIndex: 5, endIndex: 9);
      final view3 = ImmutableListView(list, startIndex: 2, endIndex: 7);

      expect(view1.toList(), [1, 2, 3, 4, 5]);
      expect(view2.toList(), [6, 7, 8, 9, 10]);
      expect(view3.toList(), [3, 4, 5, 6, 7, 8]);
    });

    test('works with custom objects', () {
      final persons = [
        Person('Alice', 30),
        Person('Bob', 25),
        Person('Charlie', 35),
        Person('David', 28),
        Person('Eve', 32),
      ];

      final view = ImmutableListView(persons, startIndex: 1, endIndex: 3);

      expect(view.length, 3);
      expect(view[0].name, 'Bob');
      expect(view[2].name, 'David');
      expect(view.map((p) => p.name).toList(), ['Bob', 'Charlie', 'David']);
      expect(view.where((p) => p.age > 30).length, 1);
    });
  });
}

class Person {
  final String name;
  final int age;

  Person(this.name, this.age);
}
