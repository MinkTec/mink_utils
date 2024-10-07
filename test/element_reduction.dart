import 'package:mink_utils/mink_utils.dart';
import 'package:test/test.dart';

main() {
  group("element reduction", () {
    final data = List<int>.generate(10, id);

    test("below", () {
      expect(
          LeaderboardReductionMode.below(
            seed: data[0],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 1, 2]);
      expect(
          LeaderboardReductionMode.below(
            seed: data[3],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [3, 4, 5]);

      expect(
          LeaderboardReductionMode.below(
            seed: data[9],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [7, 8, 9]);
    });

    test("above", () {
      expect(
          LeaderboardReductionMode.above(
            seed: data[0],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 1, 2]);
      expect(
          LeaderboardReductionMode.above(
            seed: data[3],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [1, 2, 3]);

      expect(
          LeaderboardReductionMode.above(
            seed: data[9],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [7, 8, 9]);
    });

    test("symmetric", () {
      expect(
          LeaderboardReductionMode.symmetric(
            seed: data[0],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 1, 2]);
      expect(
          LeaderboardReductionMode.symmetric(
            seed: data[3],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [2, 3, 4]);

      expect(
          LeaderboardReductionMode.symmetric(
            seed: data[9],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [7, 8, 9]);
    });

    test("leadingAndBelow", () {
      expect(
          LeaderboardReductionMode.leadingAndBelow(
            seed: data[0],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 1, 2]);
      expect(
          LeaderboardReductionMode.leadingAndBelow(
            seed: data[3],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 3, 4]);

      expect(
          LeaderboardReductionMode.leadingAndBelow(
            seed: data[9],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 8, 9]);
    });

    test("leadingAndAbove", () {
      expect(
          LeaderboardReductionMode.leadingAndAbove(
            seed: data[0],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 1, 2]);
      expect(
          LeaderboardReductionMode.leadingAndAbove(
            seed: data[3],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 2, 3]);

      expect(
          LeaderboardReductionMode.leadingAndAbove(
            seed: data[9],
            data: data,
            maxValues: 3,
          ).denumerate(),
          [0, 8, 9]);
    });

    test("leadingAndSymmetric", () {
      expect(
          LeaderboardReductionMode.leadingAndSymmetric(
            seed: data[0],
            data: data,
            maxValues: 5,
          ).denumerate(),
          [0, 1, 2, 3, 4]);

      expect(
          LeaderboardReductionMode.leadingAndSymmetric(
            seed: data[3],
            data: data,
            maxValues: 5,
          ).denumerate().toList(),
          [0, 1, 2, 3, 4]);

      expect(
          LeaderboardReductionMode.leadingAndSymmetric(
            seed: data[9],
            data: data,
            maxValues: 5,
          ).denumerate(),
          [0, 1, 7, 8, 9]);
    });
  });
}
