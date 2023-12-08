import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Message {
  late int? id;

  @JsonKey(name: 'chat_id')
  late int? chatId;

  /// 1from 2to
  late String? type;

  late String? message;

  /// 1成功 2 失败 3...
  late String? status;

  ///gpt4 image
  late String? file;

  @JsonKey(name: 'create_time')
  late int? createTime;

  Message(this.id, this.chatId, this.type, this.message, this.status,
      this.createTime);

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
