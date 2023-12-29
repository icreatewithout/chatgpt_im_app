// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpt_forum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GptForum _$GptForumFromJson(Map<String, dynamic> json) => GptForum()
  ..id = json['id'] as String?
  ..userVo = json['userVo'] == null
      ? null
      : UserVo.fromJson(json['userVo'] as Map<String, dynamic>)
  ..des = json['des'] as String?
  ..type = json['type'] as String?
  ..pictures =
      (json['pictures'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..tags = (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..time = json['time'] as String?
  ..comment = json['comment'] as int?
  ..like = json['like'] as int?
  ..thumb = json['thumb'] as bool?;

Map<String, dynamic> _$GptForumToJson(GptForum instance) => <String, dynamic>{
      'id': instance.id,
      'userVo': instance.userVo,
      'des': instance.des,
      'type': instance.type,
      'pictures': instance.pictures,
      'tags': instance.tags,
      'time': instance.time,
      'comment': instance.comment,
      'like': instance.like,
      'thumb': instance.thumb,
    };
