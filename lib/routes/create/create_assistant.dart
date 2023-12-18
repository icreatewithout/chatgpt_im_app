import 'package:chatgpt_im/db/chat_table.dart';
import 'package:chatgpt_im/states/ChatModel.dart';
import 'package:chatgpt_im/widgets/find/menu_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/gpt/chat.dart';
import '../../states/LocaleModel.dart';
import '../../widgets/find/select_models_widgets.dart';
import '../../widgets/ui/open_cn_button.dart';
import '../../widgets/ui/open_cn_text_field.dart';

class CreateAssistant extends StatefulWidget {
  static const String path = "/create/assistant";

  const CreateAssistant({super.key, this.arguments});

  final Map? arguments;

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
    if (widget.arguments != null) {
      init();
    }
    super.initState();
  }

  void init() async {
    Chat? chat = await ChatProvider().get(widget.arguments?['id']);
    if (chat != null) {
      setState(() {
        _nameController.text = chat.name!;
        _desController.text = chat.des!;
        _keyController.text = chat.apiKey!;
        _temperatureController.text = chat.temperature!;
        _seedController.text = chat.seed!;
        _maxTokensController.text = chat.maxToken!;
        _nController.text = chat.n!;
        _sizeController.text = chat.size!;
        modelsGlobalKey.currentState?.setVal(chat.model!);
      });
    }
  }

  void pop(BuildContext context) async {
    bool? b = await modelsGlobalKey.currentState?.validator();
    String? val;
    if (b!) {
      val = modelsGlobalKey.currentState?.selectedValue;
    }

    Chat chat = Chat();
    chat.id = null;
    chat.type = MenuItems.assistant.text;
    chat.name = _nameController.text.isEmpty
        ? MenuItems.assistant.text
        : _nameController.text;
    chat.des = _desController.text.isEmpty ? '一个有用的AI助手' : _desController.text;
    chat.model = val;
    chat.apiKey = _keyController.text;
    chat.temperature = _temperatureController.text.isEmpty
        ? '1.0'
        : _temperatureController.text;
    chat.seed = _seedController.text;
    chat.maxToken =
        _maxTokensController.text.isEmpty ? '500' : _maxTokensController.text;
    chat.n = _nController.text.isEmpty ? '1' : _nController.text;
    chat.size = _sizeController.text.isEmpty ? '1' : _sizeController.text;
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
        title: const Text(
          'Create Chat Completion',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
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
                      const Text('名称（Name）'),
                      const SizedBox(height: 8),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        maxLength: 20,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '输入一个名称',
                        controller: _nameController,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: const Text('指示（Instructions）'),
                      ),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        maxLength: 20,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '翻译助手',
                        controller: _desController,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: const Text('API Key'),
                      ),
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
                      const Text('随机性（temperature）'),
                      const SizedBox(height: 10),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '默认值：1.0',
                        controller: _temperatureController,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: const Text('Seed（Seed）'),
                      ),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '',
                        controller: _seedController,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: const Text('Token数量（maxTokens）'),
                      ),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '默认值：500',
                        controller: _maxTokensController,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: const Text('返回结果数量（n）'),
                      ),
                      OpenCnTextField(
                        height: 46,
                        radius: 10,
                        size: 12,
                        fontSize: 14,
                        maxLength: 200,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '默认值：1',
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
                      const SizedBox(height: 8),
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
