import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../states/LocaleModel.dart';
import '../widgets/ui/open_cn_button.dart';

class LanguageSettingPage extends StatefulWidget {
  static const String path = "/language/setting";

  const LanguageSettingPage({super.key});

  @override
  State<LanguageSettingPage> createState() => _LanguageSettingPageState();
}

class _LanguageSettingPageState extends State<LanguageSettingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    S s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(s.language, style: const TextStyle(fontSize: 16)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<LocaleModel>(
        builder:
            (BuildContext context, LocaleModel localeModel, Widget? child) {
          return SizedBox(
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      buildLanguageItem("English", "en_US", localeModel),
                      buildLine(),
                      buildLanguageItem("Français", "fr_FR", localeModel),
                      buildLine(),
                      buildLanguageItem("Deutsch", "de_DE", localeModel),
                      buildLine(),
                      buildLanguageItem("Italiano", "it_IT", localeModel),
                      buildLine(),
                      buildLanguageItem("日本語", "ja_JP", localeModel),
                      buildLine(),
                      buildLanguageItem("한국어", "ko_KR", localeModel),
                      buildLine(),
                      buildLanguageItem("Русский язык", "ru_RU", localeModel),
                      buildLine(),
                      buildLanguageItem("中文简体", "zh_CN", localeModel),

                    ],
                  ),
                ),
                Positioned(
                  left: 30,
                  right: 30,
                  bottom: kBottomNavigationBarHeight,
                  child: OpenCnButton(
                    title: s.ok,
                    radius: 20,
                    color: Colors.white,
                    bgColor: Colors.grey.shade600,
                    fw: FontWeight.bold,
                    callBack: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  buildLanguageItem(String lang, String value, LocaleModel localeModel) {
    return ListTile(
      title: Text(lang),
      trailing: localeModel.locale == value
          ? const Icon(Icons.done, color: Colors.grey)
          : null,
      onTap: () => localeModel.locale = value,
    );
  }

  buildLine() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(width: 0.3, color: Colors.grey))),
    );
  }
}
