
import 'package:json_annotation/json_annotation.dart';

part 'banner.g.dart';

@JsonSerializable()
class Banners{
  Banners();

  late String? id;

  late String? type;

  late String? title;

  late String? des;

  late String? picture;

  late String? link;

  factory Banners.fromJson(Map<String,dynamic> json) => _$BannersFromJson(json);
  Map<String, dynamic> toJson() => _$BannersToJson(this);
}