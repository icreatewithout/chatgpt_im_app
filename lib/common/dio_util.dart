import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:chatgpt_im/common/api.dart';
import 'package:uuid/uuid.dart';

import '../models/result.dart';
import 'global.dart';

const uuid = Uuid();
const String appId = "msA456OXkjf6BoBqFuZ";
const String secret = "1ytlqJJ9nAum64A4L3G2eCI4rgAy";

class DioUtil {
  BuildContext? buildContext;
  late Options _options;

  DioUtil([this.buildContext]) {
    _options = Options(extra: {"context": buildContext});
  }

  static Dio dio = Dio(
    BaseOptions(
      baseUrl: Api.baseUrl,
      headers: {HttpHeaders.contentTypeHeader: Headers.jsonContentType},
      responseType: ResponseType.json,
      validateStatus: (_) => true,
    ),
  );

  static void init() {
    if (Global.isRelease) {
      dio.options.baseUrl = Api.releaseUrl;
    }

    // 设置用户token（可能是null，代表未登录）
    if (Global.profile.token != null) {
      dio.options.headers['Authorization'] = 'Bearer ${Global.profile.token}';
    }
  }

  static setToken(String token) =>
      dio.options.headers['Authorization'] = 'Bearer $token';

  Future<Result> get(String api, [Map<String, dynamic>? data]) async {
    Response res = await dio.get(api, queryParameters: handleData(data ?? {}));

    if (res.statusCode == 401) {
      return Result.err(401, "需要登陆");
    }
    if (res.statusCode == 200) {
      return Result.fromJson(res.data, (json) => res.data['data']);
    }
    return Result.err();
  }

  Future<Result> post(String api, [Map<String, dynamic>? data]) async {
    Response res =
        await dio.post(api, data: json.encode(handleData(data ?? {})));
    if (res.statusCode == 401) {
      return Result.err(401, "需要登陆");
    }
    if (res.statusCode == 200) {
      return Result.fromJson(res.data, (json) => res.data['data']);
    }
    return Result.err();
  }

  Future<Result> put(String api, [Map<String, dynamic>? data]) async {
    Response res =
        await dio.post(api, data: json.encode(handleData(data ?? {})));
    if (res.statusCode == 401) {
      return Result.err(401, "需要登陆");
    }
    if (res.statusCode == 200) {
      return Result.fromJson(res.data, (json) => res.data['data']);
    }
    return Result.err();
  }

  Future<Result> delete(String api, [Map<String, dynamic>? data]) async {
    Response res =
        await dio.delete(api, data: json.encode(handleData(data ?? {})));
    if (res.statusCode == 401) {
      return Result.err(401, "需要登陆");
    }
    if (res.statusCode == 200) {
      return Result.fromJson(res.data, (json) => res.data['data']);
    }
    return Result.err();
  }

  Future<Result> upload(String api, String localPath, String name) async {
    Map<String, dynamic> data = handleData({});
    data['file'] = await MultipartFile.fromFile(localPath, filename: name);
    FormData fd = FormData.fromMap(data);

    Response res = await dio.post(api, data: fd);
    if (res.statusCode == 401) {
      return Result.err(401, "需要登陆");
    }

    if (res.statusCode == 200 && res.data['code'] == 200) {
      return Result.fromJson(res.data, (json) => res.data['data']);
    }
    return Result.err();
  }

  Future<Uint8List?> getBytesByUrl(String url) async {
    Response<Uint8List> response =
        await dio.get(url, options: Options(responseType: ResponseType.bytes));
    return response.data;
  }

  static Map<String, dynamic> handleData(Map<String, dynamic>? data) {
    data ??= {};

    data['appid'] = appId;
    data['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    data['randomStr'] = uuid.v4().toString();

    Iterable<String> keys = data.keys;
    List<String> keyList = keys.toList();
    keyList.sort((a, b) => a.compareTo(b));
    String str = '';
    Map<String, Object> param = {};
    for (var key in keyList) {
      param[key] = data[key]!;
      if (null != data[key]) {
        str = "$str$key=${data[key]}&";
      }
    }
    var bytes = utf8.encode(str + secret);
    String digest = sha256.convert(bytes).toString();
    param['signature'] = digest;
    return param;
  }
}
