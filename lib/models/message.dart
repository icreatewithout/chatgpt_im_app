import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Message {
  late int? id;
  late String? type;
  late String? model;
  late String? name;
  late String? des;

  @JsonKey(name: 'api_key')
  late String? apiKey;
  late String? temperature;
  late String? seed;
  @JsonKey(name: 'max_token')
  late String? maxToken;
  late String? n;
  late String? size;
  @JsonKey(name: 'create_time')
  late int? createTime;
  @JsonKey(name: 'message_size')
  late String? messageSize;

  Message(
    this.id,
    this.type,
    this.name,
    this.des,
    this.model,
    this.apiKey,
    this.temperature,
    this.seed,
    this.maxToken,
    this.n,
    this.size,
    this.createTime,
    this.messageSize,
  );

  factory Message.fromJson(Map<String,dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
