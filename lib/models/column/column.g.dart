// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'column.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Columns _$ColumnsFromJson(Map<String, dynamic> json) => Columns()
  ..id = json['id'] as String?
  ..name = json['name'] as String?
  ..iconUrl = json['iconUrl'] as String?
  ..bgPictureUrl = json['bgPictureUrl'] as String?
  ..keyWord = json['keyWord'] as String?
  ..des = json['des'] as String?;

Map<String, dynamic> _$ColumnsToJson(Columns instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconUrl': instance.iconUrl,
      'bgPictureUrl': instance.bgPictureUrl,
      'keyWord': instance.keyWord,
      'des': instance.des,
    };
