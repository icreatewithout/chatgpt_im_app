import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Result<T> {
  Result();

  @JsonKey(name: 'code')
  late int code;

  @JsonKey(name: 'message')
  late String message;

  @JsonKey(name: 'data')
  T? data;

  static Result err([int? code, String? message]) {
    Map<String, dynamic> json = {
      'code': code ?? 500,
      'message': message ?? '操作失败'
    };
    return Result.fromJson(json, (json) => json);
  }

  factory Result.fromJson(
          Map<String, dynamic> json, T Function(dynamic json) fromJsonT) =>
      _$ResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(dynamic Function(T value) toJsonT) =>
      _$ResultToJson(this, toJsonT);
}
