// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpt_forum_comment_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GptForumCommentVo _$GptForumCommentVoFromJson(Map<String, dynamic> json) =>
    GptForumCommentVo()
      ..prentId = json['prentId'] as String?
      ..id = json['id'] as String?
      ..ofId = json['ofId'] as String?
      ..user = json['user'] == null
          ? null
          : UserVo.fromJson(json['user'] as Map<String, dynamic>)
      ..replayUser = json['replayUser'] == null
          ? null
          : UserVo.fromJson(json['replayUser'] as Map<String, dynamic>)
      ..time = json['time'] as String?
      ..des = json['des'] as String?
      ..child = json['child'] as int?
      ..children = (json['children'] as List<dynamic>?)
          ?.map((e) => GptForumCommentVo.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GptForumCommentVoToJson(GptForumCommentVo instance) =>
    <String, dynamic>{
      'prentId': instance.prentId,
      'id': instance.id,
      'ofId': instance.ofId,
      'user': instance.user,
      'replayUser': instance.replayUser,
      'time': instance.time,
      'des': instance.des,
      'child': instance.child,
      'children': instance.children,
    };
