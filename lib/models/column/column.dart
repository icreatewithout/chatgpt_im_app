
import 'package:json_annotation/json_annotation.dart';

part 'column.g.dart';

@JsonSerializable()
class Columns{

  Columns();

  late String? id;

  late String? name;

  late String? iconUrl;

  late String? bgPictureUrl;

  late String? keyWord;
  late String? des;

  factory Columns.fromJson(Map<String,dynamic> json) => _$ColumnsFromJson(json);
  Map<String, dynamic> toJson() => _$ColumnsToJson(this);
}