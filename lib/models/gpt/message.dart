import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Message{
  Message();

  late int? id;

  @JsonKey(name: 'chat_id')
  late int? chatId;

  /// 1from 2to
  late String? type;

  late String? message;

  /// 1成功 2 失败 3...
  late String? status;

  @JsonKey(name: 'create_time')
  late int? createTime;

  factory Message.fromJson(Map<String,dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}