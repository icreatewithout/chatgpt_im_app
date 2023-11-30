import 'package:flutter/material.dart';


import 'about_us.dart';
import 'index_page.dart';
import 'language_setting_page.dart';
import 'login_page.dart';

final routes = <String, WidgetBuilder>{
  IndexPage.path: (BuildContext context, {arguments}) => const IndexPage(),
  LoginPage.path: (BuildContext context, {arguments}) => const LoginPage(),
  AboutUsPage.path: (BuildContext context, {arguments}) => const AboutUsPage(),
  LanguageSettingPage.path: (BuildContext context, {arguments}) =>
      const LanguageSettingPage(),
};

RouteFactory routeFactory = (RouteSettings settings) {
  final String? name = settings.name;
  final Function? widgetBuilder = routes[name];
  if (widgetBuilder != null) {
    if (settings.arguments == null) {
      return MaterialPageRoute(builder: (context) => widgetBuilder(context));
    }
    return MaterialPageRoute(
        builder: (context) =>
            widgetBuilder(context, arguments: settings.arguments));
  }
  return null;
};
