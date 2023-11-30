import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      String? url, double height, double width, double radius, BoxFit fit) {
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
          borderRadius: BorderRadius.circular(radius),
        ),
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

}
