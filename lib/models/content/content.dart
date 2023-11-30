
import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

@JsonSerializable()
class Content{
  Content();

  late String? id;

  late String? cid;

  late String? categoryId;

  late String? name;
  late String? author;
  late String? source;

  late String? keyWord;
  late String? des;

  late List<String>? tag;

  late String? content;

  late String? pictureUrl;

  late String? releaseTime;

  late String? column;
  late String? category;

  late String? files;

  late int? views;

  factory Content.fromJson(Map<String,dynamic> json) => _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);
}