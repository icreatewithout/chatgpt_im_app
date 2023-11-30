// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course()
  ..id = json['id'] as String?
  ..name = json['name'] as String?
  ..picture = json['picture'] as String?
  ..status = json['status'] as String?
  ..charge = json['charge'] as String?
  ..price = (json['price'] as num?)?.toDouble()
  ..intros = (json['intros'] as List<dynamic>?)
      ?.map((e) => CourseIntro.fromJson(e as Map<String, dynamic>))
      .toList()
  ..l10ns = (json['l10ns'] as List<dynamic>?)
      ?.map((e) => CourseL10n.fromJson(e as Map<String, dynamic>))
      .toList()
  ..chapter = json['chapter'] as int?
  ..study = json['study'] as int?;

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'picture': instance.picture,
      'status': instance.status,
      'charge': instance.charge,
      'price': instance.price,
      'intros': instance.intros,
      'l10ns': instance.l10ns,
      'chapter': instance.chapter,
      'study': instance.study,
    };
