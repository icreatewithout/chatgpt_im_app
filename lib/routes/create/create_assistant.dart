
import 'package:chatgpt_im/db/message_table.dart';
import 'package:chatgpt_im/states/MessageModel.dart';
import 'package:chatgpt_im/widgets/find/menu_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/message.dart';
import '../../states/LocaleModel.dart';
import '../../widgets/find/select_models_widgets.dart';
import '../../widgets/ui/open_cn_button.dart';
import '../../widgets/ui/open_cn_text_field.dart';

class CreateAssistant extends StatefulWidget {
  static const String path = "/create/assistant";

  const CreateAssistant({super.key});

  @override
  State<CreateAssistant> createState() => _CreateAssistantState();
}

class _CreateAssistantState extends State<CreateAssistant> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _desController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _seedController = TextEditingController();
  final TextEditingController _maxTokensController = TextEditingController();
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void pop(BuildContext context) async {
    bool? b = await modelsGlobalKey.currentState?.validator();
    String? val;
    if (b!) {
      val = modelsGlobalKey.currentState?.selectedValue;
    }

    Message message = Message(
      null,
      MenuItems.assistant.text,
      _nameController.text.isEmpty
          ? MenuItems.assistant.text
          : _nameController.text,
      _desController.text,
      val,
      _keyController.text,
      _temperatureController.text.isEmpty ? '1.0' : _temperatureController.text,
      _seedController.text,
      _maxTokensController.text.isEmpty ? '500' : _maxTokensController.text,
      _nController.text.isEmpty ? '1' : _nController.text,
      _sizeController.text.isEmpty ? '1' : _sizeController.text,
      DateTime.now().millisecondsSinceEpoch,
      '0',
    );

    await MessageProvider().insert(message);
    List<Message> messages = await MessageProvider().findList();
    if (context.mounted) {
      Provider.of<MessageModel>(context, listen: false).setMessages = messages;
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _desController.dispose();
    _keyController.dispose();
    _temperatureController.dispose();
    _seedController.dispose();
    _maxTokensController.dispose();
    _nController.dispose();
    _sizeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var gm = S.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create Chat Completion'),
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
                        hintText: '描述（des）,例如：翻译助手',
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
                      const Text('配置项'),
                      const SizedBox(height: 10),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '随机性（temperature），默认值：1.0',
                        controller: _temperatureController,
                      ),
                      buildLine(),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '确定性采样（seed）',
                        controller: _seedController,
                      ),
                      buildLine(),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: 'token数量（maxTokens），默认值：500',
                        controller: _maxTokensController,
                      ),
                      buildLine(),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        fontSize: 14,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '返回结果数量（n），默认值：1',
                        controller: _nController,
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
                      const Text('消息集合'),
                      const SizedBox(height: 10),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '历史消息（message size），默认值：1',
                        controller: _sizeController,
                      ),
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
