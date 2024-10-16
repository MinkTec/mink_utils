import 'dart:math';
import 'dart:typed_data';

import 'package:mink_dart_utils/mink_dart_utils.dart';
import 'package:test/test.dart';

void main() {
  group("iterables", () {
    final l1 = [1, 2, 3];
    final l2 = [1, 2, 3, 4, 5, 6];
    final l3 = [1, -2, 3, -4, 5, -6];
    final l4 = [1, 2, 3, 4, 5, 6, 7];
    final l5 = [1, 1, 1, 1];

    test("rotate", () {
      expect(l1.rotate().toList(), [2, 3, 1]);
      expect(l1.rotate(1).toList(), [2, 3, 1]);
      expect(l1.rotate(2).toList(), [3, 1, 2]);
      expect(l1.rotate(18).toList(), [1, 2, 3]);
    });

    test("take", () {
      expect(l2.takeEveryNth(2).toList(), [1, 3, 5]);
      expect(l2.takeEveryNotNth(2).toList(), [2, 4, 6]);
      expect(l2.takeEveryNotNth(3).toList(), [2, 3, 5, 6]);
      expect([].takeEveryNth(1).toList(), []);
      expect([].takeEveryNotNth(1).toList(), []);
    });

    test("count", () {
      expect(l1.countElements(), {1: 1, 2: 1, 3: 1});
      expect(l2.countElementsMap((e) => e > 3), {true: 3, false: 3});
      expect([].countElements(), {});
    });

    test("repeat", () {
      expect(l1.repeat(0).length, 0);
      expect(l1.repeat(1), l1);
      expect(l1.repeat(2), [...l1, ...l1]);
    });

    test("other", () {
      expect(l1.lag, [
        [1, 2],
        [2, 3]
      ]);
      expect([].lag, []);

      expect(l2.decimate(1), [1]);
      expect(l3.decimate(3).length, 3);

      expect(l1.firstHalf.toList(), [1, 2]);
      expect(l1.secondHalf.toList(), [3]);
      expect(l2.firstHalf.toList(), [1, 2, 3]);
      expect(l2.secondHalf.toList(), [4, 5, 6]);

      expect(l3.diff.toList(), [-3, 5, -7, 9, -11]);
      expect(l3.absdiff.toList(), [1, 1, 1, 1, 1]);
      expect(l3.realabsdiff.toList(), [3, 5, 7, 9, 11]);

      expect([2, 0, 0].norm(), [1, 0, 0]);
      expect([0, 2, 0].norm(), [0, 1, 0]);
      expect([-1, 0, 0].norm(), [-1, 0, 0]);
      expect(Int16List.fromList([2, 0, 0]).norm(), [1, 0, 0]);

      expect(l1.group(1).toList(), [1, 2, 3]);
      expect(l1.group(2).toList(), [1.5]);
      expect(l1.group(3).toList(), [2]);

      expect(l2.pysublist(2, 4), [3, 4]);
      expect(l2.pysublist(0, 4), [1, 2, 3, 4]);
      expect(l2.pysublist(-2, -1), [6]);
      expect(l2.pysublist(-4, -1), [4, 5, 6]);

      expect(l2.at(-1), 6);
    });

    test("chunks", () {
      expect(l1.chunks(3).flatten().toList(), l1);
      expect(l1.chunks(1).flatten().toList(), l1);
      expect(l2.chunks(2).deepList(), [
        [1, 2],
        [3, 4],
        [5, 6]
      ]);
      expect(l2.chunks(3).deepList(), [
        [1, 2, 3],
        [4, 5, 6]
      ]);
      expect(l2.nchunks(3).deepList(), [
        [1, 2],
        [3, 4],
        [5, 6]
      ]);
      expect(l2.nchunks(2).deepList(), [
        [1, 2, 3],
        [4, 5, 6]
      ]);
      expect(l4.nchunks(2).deepList(), [
        [1, 2, 3, 4],
        [5, 6, 7]
      ]);
      expect(l4.nchunks(3).deepList(), [
        [1, 2, 3],
        [4, 5, 6],
        [7]
      ]);
      expect(l4.chunks(3).deepList(), [
        [1, 2, 3],
        [4, 5, 6],
        [7]
      ]);
      expect(() => l4.chunks(-1), throwsArgumentError);
    });

    test("largest", () {
      expect(l1.topIndices(3), [2, 1, 0]);
      expect(l1.topIndices(2), [2, 1]);
      expect(l1.topIndices(1), [2]);
      expect(l1.topIndices(0), []);

      expect(l3.topIndices(3), [4, 2, 0]);

      expect(l3.nLargest(3), [5, 3, 1]);
      expect(l1.nLargest(3), [3, 2, 1]);
      expect(l5.topIndices(4), [0, 1, 2, 3]);
    });
  });

  group("List<List<T>>", () {
    final l = [
      [1, 2, 3],
      [1, 2, 3]
    ];

    test("transpose", () {
      expect(l.transposed, [
        [1, 1],
        [2, 2],
        [3, 3]
      ]);
    });
  });

  group("monotonic", () {
    final l1 = [0, 1, 2, 3, 4, 5, 5, 6];
    final l2 = [58, 59, 0, 1, 2];
    final l3 = [23, 23, 23];

    test("basic", () {
      expect(l1.isMonotonic(), true);
      expect(l1.isMonotonic(strict: true), false);
      expect(l1.isMonotonic(increasing: false), false);
      expect(l1.reversed.isMonotonic(increasing: false), true);
      expect(l1.reversed.isMonotonic(strict: true, increasing: false), false);
      expect(l3.isIncreasing(), true);
      //expect(l3.isDecreasing(), true);
    });

    test("mod", () {
      expect(l2.isMonotonicMod(60), true);
      expect(l2.isMonotonicMod(60, increasing: false), false);
      expect(l2.reversed.isMonotonicMod(60, increasing: false), true);
      expect(l2.isMonotonicMod(40), false);
      expect(l3.isIncreasingMod(40), true);
      expect(l3.isDecreasingMod(40), true);
    });
  });
}
