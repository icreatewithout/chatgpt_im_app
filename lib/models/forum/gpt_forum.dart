
import 'package:chatgpt_im/models/user_vo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gpt_forum.g.dart';

@JsonSerializable()
class GptForum {
  GptForum();

  String? id;

  UserVo? userVo;

  String? des;

  String? type;

  List<dynamic>? pictures;

  List<dynamic>? tags;

  String? time;

  int? comment = 0;

  int? like = 0;

  bool? thumb;


  factory GptForum.fromJson(Map<String, dynamic> json) =>
      _$GptForumFromJson(json);

  Map<String, dynamic> toJson() => _$GptForumToJson(this);
}
