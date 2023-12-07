import 'package:chatgpt_im/routes/message/audio_message_page.dart';
import 'package:chatgpt_im/routes/message/chat_message_page.dart';
import 'package:chatgpt_im/routes/message/edits_message_page.dart';
import 'package:chatgpt_im/routes/message/fine_message_page.dart';
import 'package:chatgpt_im/routes/message/images_message_page.dart';
import 'package:chatgpt_im/routes/message/whisper_message_page.dart';
import 'package:chatgpt_im/routes/my_files.dart';
import 'package:flutter/material.dart';

import 'about_us.dart';
import 'create/create_assistant.dart';
import 'create/create_audio.dart';
import 'create/create_edits.dart';
import 'create/create_fine.dart';
import 'create/create_images.dart';
import 'create/create_whisper.dart';
import 'index_page.dart';
import 'language_setting_page.dart';
import 'login_page.dart';

final routes = <String, WidgetBuilder>{
  IndexPage.path: (BuildContext context, {arguments}) => const IndexPage(),
  LoginPage.path: (BuildContext context, {arguments}) => const LoginPage(),
  AboutUsPage.path: (BuildContext context, {arguments}) => const AboutUsPage(),
  LanguageSettingPage.path: (BuildContext context, {arguments}) =>
      const LanguageSettingPage(),
  CreateAssistant.path: (BuildContext context, {arguments}) =>
      CreateAssistant(arguments: arguments),
  CreateAudio.path: (BuildContext context, {arguments}) => const CreateAudio(),
  CreateEdits.path: (BuildContext context, {arguments}) => const CreateEdits(),
  CreateFine.path: (BuildContext context, {arguments}) => const CreateFine(),
  CreateImages.path: (BuildContext context, {arguments}) =>
      const CreateImages(),
  CreateWhisper.path: (BuildContext context, {arguments}) =>
      const CreateWhisper(),
  MyFiles.path: (BuildContext context, {arguments}) => const MyFiles(),
  AudioMessage.path: (BuildContext context, {arguments}) =>
      AudioMessage(arguments: arguments),
  ChatMessage.path: (BuildContext context, {arguments}) =>
      ChatMessage(arguments: arguments),
  EditsMessage.path: (BuildContext context, {arguments}) =>
      EditsMessage(arguments: arguments),
  FineMessage.path: (BuildContext context, {arguments}) =>
      FineMessage(arguments: arguments),
  ImagesMessage.path: (BuildContext context, {arguments}) =>
      ImagesMessage(arguments: arguments),
  WhisperMessage.path: (BuildContext context, {arguments}) =>
      WhisperMessage(arguments: arguments),
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
