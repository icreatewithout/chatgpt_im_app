// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message()
  ..id = json['id'] as int?
  ..chatId = json['chat_id'] as int?
  ..type = json['type'] as String?
  ..message = json['message'] as String?
  ..status = json['status'] as String?
  ..createTime = json['create_time'] as int?;

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'type': instance.type,
      'message': instance.message,
      'status': instance.status,
      'create_time': instance.createTime,
    };
