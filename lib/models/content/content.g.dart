// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Content _$ContentFromJson(Map<String, dynamic> json) => Content()
  ..id = json['id'] as String?
  ..cid = json['cid'] as String?
  ..categoryId = json['categoryId'] as String?
  ..name = json['name'] as String?
  ..author = json['author'] as String?
  ..source = json['source'] as String?
  ..keyWord = json['keyWord'] as String?
  ..des = json['des'] as String?
  ..tag = (json['tag'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..content = json['content'] as String?
  ..pictureUrl = json['pictureUrl'] as String?
  ..releaseTime = json['releaseTime'] as String?
  ..column = json['column'] as String?
  ..category = json['category'] as String?
  ..files = json['files'] as String?
  ..views = json['views'] as int?;

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
      'id': instance.id,
      'cid': instance.cid,
      'categoryId': instance.categoryId,
      'name': instance.name,
      'author': instance.author,
      'source': instance.source,
      'keyWord': instance.keyWord,
      'des': instance.des,
      'tag': instance.tag,
      'content': instance.content,
      'pictureUrl': instance.pictureUrl,
      'releaseTime': instance.releaseTime,
      'column': instance.column,
      'category': instance.category,
      'files': instance.files,
      'views': instance.views,
    };
