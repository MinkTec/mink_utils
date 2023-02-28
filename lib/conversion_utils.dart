import 'dart:math';
import 'dart:ui';

import 'classes/timespan.dart';

extension TrigNum<T extends num> on T {
  double toRad() => this * pi / 180;
  double toDeg() => this * 180 / pi;

  T clamp(T n, T lower, T upper) => max(min(n, upper), lower);

  String get disp {
    final string = toStringAsFixed(0);
    return string == "-0" ? string.replaceAll("-", "") : string;
  }

  String get trigDisp {
    final string = toDeg().toStringAsFixed(0);
    return """${string == "-0" ? string.replaceAll("-", "") : string}°""";
  }
}

extension DurationToHHMMSS on Duration {
  String get hhmm => "$inHours:${twoDigits(inMinutes.remainder(60))}";
  String get hhmmss =>
      "$inHours:${twoDigits(inMinutes.remainder(60))}:${twoDigits(inSeconds.remainder(60))}";

  String humanReadable() =>
      "$inHours:${twoDigits(inMinutes.remainder(60))}:${twoDigits(inSeconds.remainder(60))}";
  String plotAxisLabel() {
    if (inSeconds.abs() < 120) {
      return "${inSeconds.abs()} Sekunden";
    } else if (inMinutes.abs() < 120) {
      return "${(inSeconds.abs() / 60).round()} Minuten";
    } else {
      return "${inHours.abs()} Stunden";
    }
  }
}

extension StringTimestamp on Duration {
  String toTimestamp() {
    double hours = inSeconds / 3600;
    int h = hours.floor();
    int m = ((hours - h) * 60).floor();
    int s = ((((hours - h) * 60) - m) * 60).floor();
    return "$h:$m:$s";
  }
}

extension DateTimeToHumanReadable on DateTime {
  String get hhmm => "$hour:${twoDigits(minute.remainder(60))}";
  String get hhmmss => "$hour:${twoDigits(minute.remainder(60))}:${twoDigits(second.remainder(60))}";
  String get hhmmssms => "$hour:${twoDigits(minute.remainder(60))}:${twoDigits(second.remainder(60))}.$millisecond";
  String humanReadable() => "$hour:${twoDigits(minute)}:${twoDigits(second)}";
}

extension DurationConversion on String {
  Duration durationFromTimestamp() {
    List<String> strSplit = split(":");
    return Duration(
        hours: int.parse(strSplit[0]),
        minutes: int.parse(strSplit[1]),
        seconds: int.parse(strSplit[2]));
  }

  Timespan timespanFromTimestamp() {
    return Timespan(duration: durationFromTimestamp());
  }
}

extension DateTimeConversion on String {
  DateTime dateTimeFromString() {
    List<String> strSplit = split("-");
    return DateTime(
        int.parse(strSplit[0]), int.parse(strSplit[1]), int.parse(strSplit[2]));
  }
}

String twoDigits(int n) => n.toString().padLeft(2, "0");

extension ReplacementExtension on String {
  String removeBrackets() => replaceAll(RegExp(r'(\[|\])'), "");
}

extension ColorConversion on Color {
  List<int> toColorCode() => [alpha, red, green, blue];
}
