// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoImpl _$$MemoImplFromJson(Map<String, dynamic> json) => _$MemoImpl(
      id: json['id'] as String?,
      text: json['text'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdTime: const DateTimeTimestampConverter()
          .fromJson(json['createdTime'] as Timestamp),
    );

Map<String, dynamic> _$$MemoImplToJson(_$MemoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'isCompleted': instance.isCompleted,
      'createdTime':
          const DateTimeTimestampConverter().toJson(instance.createdTime),
    };
