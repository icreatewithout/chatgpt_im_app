import 'package:chatgpt_im/states/ChatModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/routes/index_page.dart';
import 'package:chatgpt_im/routes/routes.dart';
import 'package:chatgpt_im/states/LocaleModel.dart';
import 'package:chatgpt_im/states/UserModel.dart';
import 'package:provider/provider.dart';
import 'common/global.dart';
import 'generated/l10n.dart';

void main() {
  Global.init().then((e) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => LocaleModel()),
        ChangeNotifierProvider(create: (_) => ChatModel()),
      ],
      child: Consumer<LocaleModel>(
        builder:
            (BuildContext context, LocaleModel localeModel, Widget? child) {
          return MaterialApp(
            theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: CommonUtils.white()),
            debugShowCheckedModeBanner: false,
            locale: localeModel.getLocale(),
            localizationsDelegates: const [
              //本地化代理类
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              //生成的代理类
              S.delegate
            ],
            supportedLocales: S.delegate.supportedLocales,
            localeResolutionCallback: (local, supportedLocales) {
              if (localeModel.getLocale() != null) {
                return localeModel.getLocale();
              } else {
                //跟随系统
                Locale tempLocale;
                if (supportedLocales.contains(local)) {
                  tempLocale = local!;
                } else {
                  //如果系统语言不是中文简体或美国英语，则默认使用美国英语
                  tempLocale = const Locale.fromSubtags(
                    languageCode: 'zh',
                    countryCode: 'CN',
                  );
                }
                return tempLocale;
              }
            },
            // initialRoute: IndexPage.path,
            initialRoute: IndexPage.path,
            onGenerateRoute: routeFactory,
            builder: FToastBuilder(),
          );
        },
      ),
    );
  }
}
