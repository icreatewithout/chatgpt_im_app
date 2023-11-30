import 'package:json_annotation/json_annotation.dart';
import 'package:chatgpt_im/models/user_vo.dart';
import "user.dart";
part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  UserVo? user;

  bool status = false;

  String? token;

  String? locale;
  
  factory Profile.fromJson(Map<String,dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
