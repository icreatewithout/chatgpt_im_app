import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatgpt_im/common/dio_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/sqlite.dart';
import '../models/profile.dart';

class Global {
  static late SharedPreferences _preferences;

  static Profile profile = Profile();
  static SqliteDb sqliteDb = SqliteDb();

  //是否为release版本
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  //初始化全局信息，在app启动时执行
  static Future init() async {
    //在初始化应用之前与flutter引擎通信
    WidgetsFlutterBinding.ensureInitialized();
    //从SharedPreferences中取出全局变量
    _preferences = await SharedPreferences.getInstance();
    String? storeProfile = _preferences.getString("profile");
    debugPrint(storeProfile);
    if (storeProfile != null) {
      try {
        Map<String, dynamic> map = jsonDecode(storeProfile);
        profile = Profile.fromJson(map);
      } catch (e) {
        debugPrint("异常信息：$e");
      }
    } else {
      profile = Profile()..locale = "zh_CN";
    }

    DioUtil.init();
    await sqliteDb.init();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
    );
  }

  //持久化Profile信息
  static saveProfile() =>
      _preferences.setString("profile", jsonEncode(profile.toJson()));
}
