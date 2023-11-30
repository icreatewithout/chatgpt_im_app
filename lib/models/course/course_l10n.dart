import 'package:json_annotation/json_annotation.dart';

part 'course_l10n.g.dart';

@JsonSerializable()
class CourseL10n {

  CourseL10n();

  late String? id;

  late String? courseId;

  late String? type;

  late String? name;

  factory CourseL10n.fromJson(Map<String,dynamic> json) => _$CourseL10nFromJson(json);
  Map<String, dynamic> toJson() => _$CourseL10nToJson(this);
}
