

import 'package:json_annotation/json_annotation.dart';

part 'course_intro.g.dart';

@JsonSerializable()
class CourseIntro{
  CourseIntro();

  late String? id;

  late String? courseId;

  late String? l10n;

  late String? content;

  factory CourseIntro.fromJson(Map<String,dynamic> json) => _$CourseIntroFromJson(json);
  Map<String, dynamic> toJson() => _$CourseIntroToJson(this);
}