import 'package:mink_dart_utils/src/models/timespan.dart';

extension DurationConversion on String {
  Duration durationFromTimestamp() {
    List<String> strSplit = split(":");
    return Duration(
        hours: int.parse(strSplit[0]),
        minutes: int.parse(strSplit[1]),
        seconds: int.parse(strSplit[2]));
  }

  Timespan timespanFromTimestamp() =>
      Timespan(duration: durationFromTimestamp());

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

  String clean({whitespaceReplace = "-"}) =>
      trim().replaceUmlaute().replaceWhitespace(whitespaceReplace);

  String capitalizeFirst() =>
      this[0].toUpperCase() + substring(1).toLowerCase();

  DateTime dateTimeFromString() {
    List<String> strSplit = split("-");
    return DateTime(
        int.parse(strSplit[0]), int.parse(strSplit[1]), int.parse(strSplit[2]));
  }

  String removeBrackets() => replaceAll(RegExp(r'(\[|\])'), "");

  String toSnakeCase() => replaceAllMapped(
      RegExp(r'([A-Z])'), (Match match) => "_${match.group(0)!.toLowerCase()}");
}

extension Emptiness on String? {
  bool get isEmptyOrNull => this == null || this!.isEmpty;
}
