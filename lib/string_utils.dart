extension StringCleaner on String {
  String replaceUmlaute() => replaceAll("ä", "ae")
      .replaceAll("ö", "oe")
      .replaceAll("ü", "ue")
      .replaceAll("Ä", "Ae")
      .replaceAll("Ö", "Oe")
      .replaceAll("Ü", "Ue")
      .replaceAll("ß", "ss");

  String replaceWhitespace([String target = "-"]) =>
      replaceAll(RegExp(r"\s"), target);


  List<String> get lines => split(RegExp(r"(\n|\r)+"));

  String clean() => trim().replaceUmlaute().replaceWhitespace();

  String capitalizeFirst() => this[0].toUpperCase() + substring(1).toLowerCase();
}
