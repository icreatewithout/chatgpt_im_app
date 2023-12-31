import 'package:json_annotation/json_annotation.dart';

import '../user_vo.dart';

part 'gpt_forum_comment_vo.g.dart';

@JsonSerializable()
class GptForumCommentVo {
  GptForumCommentVo();

  String? prentId;

  String? id;

  String? ofId;

  UserVo? user;
  UserVo? replayUser;

  String? time;

  String? des;

  int? child;

  List<dynamic>? children;

  factory GptForumCommentVo.fromJson(Map<String, dynamic> json) =>
      _$GptForumCommentVoFromJson(json);

  Map<String, dynamic> toJson() => _$GptForumCommentVoToJson(this);
}
