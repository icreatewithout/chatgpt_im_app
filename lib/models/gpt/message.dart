import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Message {
  int? id;

  @JsonKey(name: 'chat_id')
  int? chatId;

  /// 1from 2to
  String? type;

  String? message;

  /// 1成功 2 失败 3...
  String? status;

  ///gpt4 image name
  @JsonKey(name: 'file_name')
  String? fileName;

  ///类型，1本地，2网络url
  @JsonKey(name: 'file_type')
  String? fileType;

  @JsonKey(name: 'file_path')
  String? filePath;

  @JsonKey(name: 'create_time')
  int? createTime;

  Message(this.id, this.chatId, this.type, this.message, this.fileName, this.status,
      this.createTime);

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
