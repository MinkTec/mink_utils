import 'package:mink_dart_utils/mink_dart_utils.dart';

mixin Timeserializable implements CsvLine, TimeBound {
  @override
  String? csvHeader() => null;
}
