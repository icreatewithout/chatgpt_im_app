// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      json['id'] as int?,
      json['type'] as String?,
      json['name'] as String?,
      json['des'] as String?,
      json['model'] as String?,
      json['api_key'] as String?,
      json['temperature'] as String?,
      json['seed'] as String?,
      json['max_token'] as String?,
      json['n'] as String?,
      json['size'] as String?,
      json['create_time'] as int?,
      json['message_size'] as String?,
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'model': instance.model,
      'name': instance.name,
      'des': instance.des,
      'api_key': instance.apiKey,
      'temperature': instance.temperature,
      'seed': instance.seed,
      'max_token': instance.maxToken,
      'n': instance.n,
      'size': instance.size,
      'create_time': instance.createTime,
      'message_size': instance.messageSize,
    };
