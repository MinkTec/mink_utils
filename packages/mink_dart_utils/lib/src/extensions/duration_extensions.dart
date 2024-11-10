import 'dart:io';

import 'package:mink_dart_utils/src/clock.dart';
import 'package:mink_dart_utils/src/utils/base.dart';

enum TimeWords {
  hour,
  hourAbb,
  hours,
  minute,
  minuteAbb,
  minuteShort,
  minutes,
  second,
  secondAbb,
  seconds,
  secondsShort,
  ;

  String tr() {
    return switch (Platform.localeName.split("_").first) {
      "de" => switch (this) {
          TimeWords.hour => "Stunde",
          TimeWords.hourAbb => "h",
          TimeWords.hours => "Stunden",
          TimeWords.minute => "Minute",
          TimeWords.minuteAbb => "m",
          TimeWords.minuteShort => "Min",
          TimeWords.minutes => "Minuten",
          TimeWords.second => "Sekunde",
          TimeWords.secondAbb => "s",
          TimeWords.seconds => "Sekunden",
          TimeWords.secondsShort => "Sec"
        },
      _ => switch (this) {
          TimeWords.hour => "hour",
          TimeWords.hourAbb => "h",
          TimeWords.hours => "hours",
          TimeWords.minute => "minute",
          TimeWords.minuteAbb => "m",
          TimeWords.minuteShort => "min",
          TimeWords.minutes => "minutes",
          TimeWords.second => "second",
          TimeWords.secondAbb => "s",
          TimeWords.seconds => "seconds",
          TimeWords.secondsShort => "sec",
        },
    };
  }

  @override
  String toString() => tr();
}

enum CommonWords {
  and,
  or,
  ;

  String tr() => switch (Platform.localeName.split("_").first) {
        "de" => switch (this) {
            CommonWords.and => "und",
            CommonWords.or => "oder",
          },
        _ => name,
      };

  @override
  String toString() => tr();
}

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
      return "${inSeconds.abs()} ${TimeWords.seconds}";
    } else if (inMinutes.abs() < 120) {
      return "${(inSeconds.abs() / 60).round()} ${TimeWords.minutes}";
    } else {
      return "${inHours.abs()} ${TimeWords.hours}";
    }
  }

  String toTimestamp() {
    double hours = inSeconds / 3600;
    int h = hours.floor();
    int m = ((hours - h) * 60).floor();
    int s = ((((hours - h) * 60) - m) * 60).floor();
    return "$h:$m:$s";
  }

  DateTime get ago => dartClock.now().subtract(this);

  Duration get zeroOrAbove => max(Duration.zero);

  Duration max(Duration d) => this > d ? this : d;
  Duration min(Duration d) => this < d ? this : d;

  String toExplainerString({
    bool forceMinutes = false,
    bool forceHours = false,
    bool forceSeconds = false,
    bool excludeSeconds = true,
    bool short = false,
  }) {
    String hours = "";
    String minutes = "";
    String seconds = "";

    int h = inHours;
    int min = inMinutes % 60;
    int sec = inSeconds % 60;

    if (inHours != 0 || forceHours) {
      hours = short
          ? "$h ${TimeWords.hourAbb}"
          : inHours == 1
              ? "$h ${TimeWords.hour}"
              : "$h ${TimeWords.hours}";
    }

    if (min != 0 || forceMinutes) {
      minutes = short
          ? "$min ${TimeWords.minuteShort}"
          : min == 1
              ? "$min ${TimeWords.minute}"
              : "$min ${TimeWords.minutes}";
    }

    if (!excludeSeconds && (sec != 0 || forceSeconds)) {
      seconds = short
          ? "$sec ${TimeWords.secondsShort}"
          : sec == 1
              ? "$sec ${TimeWords.second}"
              : "$sec ${TimeWords.seconds}";
    }

    if (hours.isNotEmpty || minutes.isNotEmpty || seconds.isNotEmpty) {
      return [hours, minutes, seconds]
          .where((x) => x.isNotEmpty)
          .join(short ? " " : " ${CommonWords.and} ");
    } else {
      return toExplainerString(
        forceMinutes: true,
        short: short,
        excludeSeconds: excludeSeconds,
      );
    }
  }
}
