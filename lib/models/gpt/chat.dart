import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Chat {
  int? id;
  String? type;
  String? model;
  String? name;
  String? des;

  @JsonKey(name: 'api_key')
  String? apiKey;

  String? temperature;
  String? seed;

  @JsonKey(name: 'max_token')
  String? maxToken;

  String? n;
  String? size; //消息集合、图片size
  String? style;
  String? speed;
  String? voice;

  @JsonKey(name: 'response_format')
  String? responseFormat;

  @JsonKey(name: 'create_time')
  int? createTime;

  @JsonKey(name: 'message_size')
  String? messageSize;

  Chat();

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);
}
