import 'package:test/test.dart';
import 'package:mink_dart_utils/mink_dart_utils.dart';

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

  test("toSetBy", () {
    var numbers = [1, 2, 3, 3, 2, 1, 4, 5];
    var uniqueNumbers = numbers.toSetBy((n) => n).toList();
    expect(uniqueNumbers, equals([1, 2, 3, 4, 5]));

    // Test with objects using a specific property as key
    var persons = [
      Person('Alice', 30),
      Person('Bob', 25),
      Person('Charlie', 30),
      Person('Alice', 22),
    ];

    // Using name as key
    var uniqueByName = persons.toSetBy((p) => p.name).toList();
    expect(uniqueByName.length, 3);
    expect(uniqueByName.map((p) => p.name).toSet(),
        equals({'Alice', 'Bob', 'Charlie'}));

    // Using age as key
    var uniqueByAge = persons.toSetBy((p) => p.age).toList();
    expect(uniqueByAge.length, 3);
    expect(uniqueByAge.map((p) => p.age).toSet(), equals({30, 25, 22}));

    // Test with empty list
    Iterable<int> emptyList = <int>[];
    expect(emptyList.toSetBy((n) => n).toList(), isEmpty);
  });
  // Helper class for testing
}

class Person {
  final String name;
  final int age;

  Person(this.name, this.age);

  @override
  String toString() => 'Person($name, $age)';
}
