import 'package:json_annotation/json_annotation.dart';
import 'package:chatgpt_im/models/user_vo.dart';

import 'gpt/chat.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  UserVo? user;

  bool status = false;

  String? token;

  String? locale;

  List<Chat> chats = List.of([], growable: true);

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
