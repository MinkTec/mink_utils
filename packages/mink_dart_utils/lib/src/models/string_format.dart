import 'package:mink_dart_utils/mink_dart_utils.dart';

enum ValueType {
  numeric,
  duration,
  trigonometric,
  percent,
  compactNumeric,
  ;

  void format(Object value, {int fixed = 0}) => switch (this) {
        ValueType.numeric => (value as num).toStringAsFixed(fixed),
        ValueType.percent =>
          "${((value as num) * 100).toStringAsFixed(fixed)}%",
        ValueType.duration => Duration(seconds: (value as num).round()).hhmm,
        ValueType.trigonometric =>
          "${(value as num).toDeg().toStringAsFixed(fixed)}°",
        ValueType.compactNumeric => _formatCompactNumber(value as num, fixed),
      };

  static String _formatCompactNumber(num value, int decimals) {
    final absValue = value.abs();
    final sign = value < 0 ? '-' : '';
    
    if (absValue >= 1000000000) {
      return '$sign${(absValue / 1000000000).toStringAsFixed(decimals)}B';
    } else if (absValue >= 1000000) {
      return '$sign${(absValue / 1000000).toStringAsFixed(decimals)}M';
    } else if (absValue >= 10000) {
      return '$sign${(absValue / 1000).toStringAsFixed(decimals)}k';
    } else {
      return value.toStringAsFixed(decimals);
    }
  }
}

class StringFormat {
  final ValueType type;
  final int fixed;

  const StringFormat({this.type = ValueType.numeric, this.fixed = 0});

  format(Object value) => type.format(value, fixed: fixed);
}
