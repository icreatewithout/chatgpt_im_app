// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Banners _$BannersFromJson(Map<String, dynamic> json) => Banners()
  ..id = json['id'] as String?
  ..type = json['type'] as String?
  ..title = json['title'] as String?
  ..des = json['des'] as String?
  ..picture = json['picture'] as String?
  ..link = json['link'] as String?;

Map<String, dynamic> _$BannersToJson(Banners instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'des': instance.des,
      'picture': instance.picture,
      'link': instance.link,
    };
