// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_intro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseIntro _$CourseIntroFromJson(Map<String, dynamic> json) => CourseIntro()
  ..id = json['id'] as String?
  ..courseId = json['courseId'] as String?
  ..l10n = json['l10n'] as String?
  ..content = json['content'] as String?;

Map<String, dynamic> _$CourseIntroToJson(CourseIntro instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'l10n': instance.l10n,
      'content': instance.content,
    };
