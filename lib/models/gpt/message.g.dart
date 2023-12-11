// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      json['id'] as int?,
      json['chat_id'] as int?,
      json['type'] as String?,
      json['message'] as String?,
      json['file'] as String?,
      json['status'] as String?,
      json['create_time'] as int?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'type': instance.type,
      'message': instance.message,
      'status': instance.status,
      'file': instance.file,
      'create_time': instance.createTime,
    };
