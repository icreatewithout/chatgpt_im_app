import 'package:chatgpt_im/widgets/find/select_speech_response_format_widgets.dart';
import 'package:chatgpt_im/widgets/find/select_speech_voice_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/chat_table.dart';
import '../../generated/l10n.dart';
import '../../models/gpt/chat.dart';
import '../../states/LocaleModel.dart';
import '../../states/ChatModel.dart';
import '../../widgets/find/menu_widgets.dart';
import '../../widgets/find/select_models_widgets.dart';
import '../../widgets/ui/open_cn_button.dart';
import '../../widgets/ui/open_cn_text_field.dart';

class CreateAudio extends StatefulWidget {
  static const String path = "/create/audio";

  const CreateAudio({super.key, this.arguments});

  final Map? arguments;

  @override
  State<CreateAudio> createState() => _CreateAudioState();
}

class _CreateAudioState extends State<CreateAudio> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _desController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void pop(BuildContext context) async {
    String? val = modelsGlobalKey.currentState?.selectedValue;
    String? voice = speechVoiceGlobalKey.currentState?.selectedValue;
    String? rf = speechResponseFormatGlobalKey.currentState?.selectedValue;

    Chat chat = Chat();
    chat.type = MenuItems.audio.text;
    chat.name = _nameController.text.isEmpty
        ? MenuItems.audio.text
        : _nameController.text;
    chat.des = _desController.text.isEmpty ? '语音助手' : _desController.text;
    chat.model = val;
    chat.apiKey = _keyController.text;
    chat.speed = _speedController.text.isEmpty ? '1' : _speedController.text;
    chat.voice = voice;
    chat.responseFormat = rf ?? '';
    chat.createTime = DateTime.now().millisecondsSinceEpoch;
    chat.messageSize = '0';

    if (widget.arguments != null && widget.arguments!['id'] != null) {
      // update set id
      chat.id = widget.arguments!['id'];
      await ChatProvider().update(chat);
    } else {
      await ChatProvider().insert(chat);
    }
    List<Chat> chats = await ChatProvider().findList();
    if (context.mounted) {
      Provider.of<ChatModel>(context, listen: false).setChats = chats;
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _desController.dispose();
    _keyController.dispose();
    _speedController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var gm = S.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create Speech'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Consumer<LocaleModel>(
        builder:
            (BuildContext context, LocaleModel localeModel, Widget? child) {
          return SizedBox(
            height: double.infinity,
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('选择模型（model）'),
                      const SizedBox(height: 10),
                      SelectModels(key: modelsGlobalKey)
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('基本信息'),
                      const SizedBox(height: 10),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        maxLength: 20,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '名称（name）',
                        controller: _nameController,
                      ),
                      buildLine(),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        maxLength: 20,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '描述（des）,例如：语音助手',
                        controller: _desController,
                      ),
                      buildLine(),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        maxLength: 200,
                        size: 12,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: 'API KEY',
                        controller: _keyController,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('speed（speed）'),
                      const SizedBox(height: 10),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '速度，介于0.25-4.0之间，默认值：1.0',
                        controller: _speedController,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('voice（voice）'),
                      const SizedBox(height: 10),
                      SelectSpeechVoice(key: speechVoiceGlobalKey)
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('response_format（response_format）'),
                      const SizedBox(height: 10),
                      SelectSpeechResponseFormat(
                          key: speechResponseFormatGlobalKey)
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 15),
                  child: OpenCnButton(
                    title: '完成',
                    radius: 20,
                    color: Colors.white,
                    bgColor: Colors.grey.shade600,
                    fw: FontWeight.bold,
                    callBack: () => pop(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  buildLabel(String label) {
    return Container(
      width: 40,
      alignment: Alignment.centerLeft,
      child: Text(label),
    );
  }

  buildLine() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      decoration: BoxDecoration(
          border:
              Border(top: BorderSide(width: 0.3, color: Colors.grey.shade400))),
    );
  }
}