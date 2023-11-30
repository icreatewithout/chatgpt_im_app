
import 'package:json_annotation/json_annotation.dart';
import 'package:chatgpt_im/models/course/course_intro.dart';
import 'package:chatgpt_im/models/course/course_l10n.dart';

part 'course.g.dart';

@JsonSerializable()
class Course{
  Course();

  late String? id;

  late String? name;

  late String? picture;

  late String? status;

  late String? charge;

  late double? price;

  late List<CourseIntro>? intros;

  late List<CourseL10n>? l10ns;

  late int? chapter;

  late int? study;

  factory Course.fromJson(Map<String,dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}