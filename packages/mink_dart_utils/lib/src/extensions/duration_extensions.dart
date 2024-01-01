import 'package:mink_dart_utils/src/utils/base.dart';

extension DurationToHHMMSS on Duration {
  String get hhmm => "$inHours:${twoDigits(inMinutes.remainder(60))}";
  String get hhmmss =>
      "$inHours:${twoDigits(inMinutes.remainder(60))}:${twoDigits(inSeconds.remainder(60))}";

  String get mmss =>
      "${inMinutes.remainder(60)}:${twoDigits(inSeconds.remainder(60))}";

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

  String toTimestamp() {
    double hours = inSeconds / 3600;
    int h = hours.floor();
    int m = ((hours - h) * 60).floor();
    int s = ((((hours - h) * 60) - m) * 60).floor();
    return "$h:$m:$s";
  }

  DateTime get ago => DateTime.now().subtract(this);

  Duration get zeroOrAbove => max(Duration.zero);

  Duration max(Duration d) => this > d ? this : d;
  Duration min(Duration d) => this < d ? this : d;

  String toExplainerString(
      {bool forceMinutes = false, bool forceHours = false}) {
    String hours = "";
    String minutes = "";

    if (inHours != 0 || forceHours) {
      hours = inHours == 1 ? "$inHours Stunde" : "$inHours Stunden";
    }

    if ((inMinutes % 60) != 0 || forceMinutes) {
      minutes = inMinutes % 60 == 1 ? "1 Minute" : "${inMinutes % 60} Minuten";
    }

    if (hours.isNotEmpty && minutes.isNotEmpty) {
      return "$hours und $minutes";
    } else if (hours.isNotEmpty) {
      return hours;
    } else if (minutes.isNotEmpty) {
      return minutes;
    } else {
      return toExplainerString(forceMinutes: true);
    }
  }
}
