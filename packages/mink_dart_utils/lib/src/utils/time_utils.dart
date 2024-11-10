// DateTime ago(Duration d) => clock.now().subtract(d);

extension ToDateTime on int {
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this);
}

extension ListTimestampParser on List<int> {
  /// read timestamps in the format of
  /// [1934, 5, 4] -> [DateTime(1934, 5, 4)]
  /// [22, 11, 11] -> [DateTime(2022, 11, 11)]
  /// If the [first] is less than 100 it will be
  /// interpreted as [2000 + first]
  DateTime toDateTime() {
    final year = this[0] < 100 ? 2000 + this[0] : this[0];
    if (length == 8) {
      return DateTime(
        year,
        this[1],
        this[2],
        this[3],
        this[4],
        this[5],
        this[6],
        this[7],
      );
    }
    if (length == 7) {
      return DateTime(
        year,
        this[1],
        this[2],
        this[3],
        this[4],
        this[5],
        this[6],
      );
    }
    if (length == 6) {
      return DateTime(
        year,
        this[1],
        this[2],
        this[3],
        this[4],
        this[5],
      );
    } else if (length == 5) {
      return DateTime(year, this[1], this[2], this[3], this[4]);
    } else if (length == 4) {
      return DateTime(year, this[1], this[2], this[3]);
    } else if (length == 3) {
      return DateTime(year, this[1], this[2]);
    } else if (length == 2) {
      return DateTime(year, this[1]);
    } else if (length == 1) {
      return DateTime(year);
    } else {
      throw ArgumentError.value("Invalid Number of elements");
    }
  }
}
