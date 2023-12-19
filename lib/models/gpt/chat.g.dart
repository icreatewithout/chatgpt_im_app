// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat()
  ..id = json['id'] as int?
  ..type = json['type'] as String?
  ..model = json['model'] as String?
  ..name = json['name'] as String?
  ..des = json['des'] as String?
  ..apiKey = json['api_key'] as String?
  ..temperature = json['temperature'] as String?
  ..seed = json['seed'] as String?
  ..maxToken = json['max_token'] as String?
  ..n = json['n'] as String?
  ..size = json['size'] as String?
  ..style = json['style'] as String?
  ..speed = json['speed'] as String?
  ..voice = json['voice'] as String?
  ..responseFormat = json['response_format'] as String?
  ..createTime = json['create_time'] as int?
  ..messageSize = json['message_size'] as String?;

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
      'style': instance.style,
      'speed': instance.speed,
      'voice': instance.voice,
      'response_format': instance.responseFormat,
      'create_time': instance.createTime,
      'message_size': instance.messageSize,
    };
