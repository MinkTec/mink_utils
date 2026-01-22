mixin CsvLine {
  String? csvHeader() => null;

  String toCsvLine();
}

extension CsvIterUtils on Iterable<CsvLine> {
  String toCsv() {
    if (isEmpty) return '\n';
    final header = first.csvHeader();
    return "${[
      if (header != null) header,
      ...map((e) => e.toCsvLine())
    ].join("\n")}\n";
  }
}
