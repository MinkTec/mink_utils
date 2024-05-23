import 'package:mink_dart_utils/mink_dart_utils.dart';

enum ValueType {
  numeric,
  duration,
  trigonometric,
  percent,
  ;

  format(Object value, {int fixed = 0}) => switch (this) {
        ValueType.numeric => (value as num).toStringAsFixed(fixed),
        ValueType.percent =>
          "${((value as num) * 100).toStringAsFixed(fixed)}%",
        ValueType.duration => Duration(seconds: (value as num).round()).hhmm,
        ValueType.trigonometric =>
          "${(value as num).toDeg().toStringAsFixed(fixed)}°"
      };
}

class StringFormat {
  final ValueType type;
  final int fixed;

  const StringFormat({this.type = ValueType.numeric, this.fixed = 0});

  format(Object value) => type.format(value, fixed: fixed);
}

