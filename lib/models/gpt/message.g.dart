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
      json['file_name'] as String?,
      json['status'] as String?,
      json['create_time'] as int?,
    )
      ..fileType = json['file_type'] as String?
      ..filePath = json['file_path'] as String?;

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'type': instance.type,
      'message': instance.message,
      'status': instance.status,
      'file_name': instance.fileName,
      'file_type': instance.fileType,
      'file_path': instance.filePath,
      'create_time': instance.createTime,
    };
