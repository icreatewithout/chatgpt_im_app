import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonUtils {
  static Future<bool?> showToast(
    String msg, {
    Toast? toast,
    ToastGravity? tg,
    int? time,
    Color? bgColor,
    Color? textColor,
    double? size,
  }) {
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: toast ?? Toast.LENGTH_SHORT,
      gravity: tg ?? ToastGravity.CENTER,
      timeInSecForIosWeb: time ?? 1,
      backgroundColor: bgColor ?? Colors.grey,
      textColor: textColor ?? Colors.white,
      fontSize: size ?? 16.0,
    );
  }

  static bool regexEmail(String email) {
    String regexEmail = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";
    return RegExp(regexEmail).hasMatch(email);
  }

  static MaterialColor white() {
    return const MaterialColor(
      _whitePrimaryValue,
      <int, Color>{
        50: Color(0xFFFFFFFF),
        100: Color(0xFFFFFFFF),
        200: Color(0xFFFFFFFF),
        300: Color(0xFFFFFFFF),
        400: Color(0xFFFFFFFF),
        500: Color(_whitePrimaryValue),
        600: Color(0xFFFFFFFF),
        700: Color(0xFFFFFFFF),
        800: Color(0xFFFFFFFF),
        900: Color(0xFFFFFFFF),
      },
    );
  }

  static const int _whitePrimaryValue = 0xFFFFFFFF;

  static image(
      String? url, double? height, double? width, double radius, BoxFit fit) {
    if (url == null) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: const Center(
          child: Icon(
            Icons.warning,
            color: Colors.grey,
            size: 20,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(radius)),
        child: const Center(
          child: Icon(
            Icons.warning,
            color: Colors.grey,
            size: 22,
          ),
        ),
      ),
    );
  }

  static Future<Directory> getTempDir() async {
    return await getTemporaryDirectory();
  }

  static Future<Directory> getAppDocumentsDir() async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<Directory> getAppCacheDir() async {
    return await getApplicationCacheDirectory();
  }

  static Future<Directory> getAppSupportDir() async {
    return await getApplicationSupportDirectory();
  }

  static Future<Directory> getLibraryDir() async {
    return await getLibraryDirectory();
  }

  static Future<Directory?> getExternalStorageDir() async {
    return await getExternalStorageDirectory();
  }

  static Future<Directory?> getDownloadsDir() async {
    return await getDownloadsDirectory();
  }

  /// 授予权限返回true， 否则返回false
  static Future<bool> requestScopePermission(Permission scope) async {
    // 获取当前的权限
    PermissionStatus status = await scope.status;
    if (status.isGranted) {
      // 已经授权
      return true;
    } else {
      // 未授权则发起一次申请
      status = await scope.request();
      if (status.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }



}
