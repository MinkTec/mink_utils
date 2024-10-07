import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';

enum LeaderboardReductionMode {
  leadingAndSymmetric,
  leadingAndAbove,
  leadingAndBelow,
  symmetric,
  below,
  above,
  ;

  Iterable<(int, T)> call<T>({
    required T seed,
    required List<T> data,
    required int maxValues,
  }) {
    assert(data.contains(seed));

    if (data.length <= maxValues) {
      return data.enumerate();
    }

    final int seedIndex = data.indexOf(seed);

    final enumeratedData = data.enumerate();

    switch (this) {
      case LeaderboardReductionMode.leadingAndSymmetric:
      case LeaderboardReductionMode.leadingAndAbove:
      case LeaderboardReductionMode.leadingAndBelow:
        int takeFromStart = (maxValues ~/ 2).clamp(1, 3);

        if (seedIndex < takeFromStart) {
          return enumeratedData.take(maxValues);
        }

        final mode = switch (this) {
          LeaderboardReductionMode.leadingAndSymmetric =>
            LeaderboardReductionMode.symmetric,
          LeaderboardReductionMode.leadingAndAbove =>
            LeaderboardReductionMode.above,
          LeaderboardReductionMode.leadingAndBelow =>
            LeaderboardReductionMode.below,
          _ => throw Never,
        };

        var reduced = mode(
          seed: seed,
          data: data.skip(takeFromStart).toList(),
          maxValues: maxValues - takeFromStart,
        ).map((x) => (x.$1 + takeFromStart, x.$2));

        return [
          ...enumeratedData.take(takeFromStart),
          ...reduced,
        ];

      case LeaderboardReductionMode.symmetric:
        if (seedIndex < maxValues ~/ 2) {
          return enumeratedData.take(maxValues);
        } else if ((data.length - seedIndex) <= maxValues ~/ 2) {
          return enumeratedData.takeLast(maxValues);
        } else {
          return enumeratedData
              .skip(seedIndex - maxValues ~/ 2)
              .take(maxValues);
        }
      case LeaderboardReductionMode.below:
        if (data.length - seedIndex < maxValues) {
          return enumeratedData.takeLast(maxValues);
        } else {
          return enumeratedData.skip(seedIndex).take(maxValues);
        }
      case LeaderboardReductionMode.above:
        if (seedIndex < maxValues) {
          return enumeratedData.take(maxValues);
        } else {
          return enumeratedData
              .toList()
              .sublist(1 + seedIndex - maxValues, seedIndex + 1);
        }
    }
  }
}
