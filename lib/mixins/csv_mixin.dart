mixin CsvLine {
  String toCsvLine();
}

extension CsvIterUtils on Iterable<CsvLine> {
  String toCsv() => "${map((e) => e.toCsvLine()).join("\n")}\n";
}
