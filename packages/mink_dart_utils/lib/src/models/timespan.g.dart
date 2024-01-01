// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timespan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timespan _$TimespanFromJson(Map<String, dynamic> json) => Timespan(
      begin: json['begin'] == null
          ? null
          : DateTime.parse(json['begin'] as String),
      end: json['end'] == null ? null : DateTime.parse(json['end'] as String),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
    );

Map<String, dynamic> _$TimespanToJson(Timespan instance) => <String, dynamic>{
      'begin': instance.begin.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
    };
