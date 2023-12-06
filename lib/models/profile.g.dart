// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile()
  ..user = json['user'] == null
      ? null
      : UserVo.fromJson(json['user'] as Map<String, dynamic>)
  ..status = json['status'] as bool
  ..token = json['token'] as String?
  ..locale = json['locale'] as String?
  ..messages = (json['messages'] as List<dynamic>)
      .map((e) => Message.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'user': instance.user,
      'status': instance.status,
      'token': instance.token,
      'locale': instance.locale,
      'messages': instance.messages,
    };
