import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/common_utils.dart';
import '../../db/chat_table.dart';
import '../../generated/l10n.dart';
import '../../models/gpt/chat.dart';
import '../../states/LocaleModel.dart';
import '../../states/ChatModel.dart';
import '../../widgets/chat/chat_util.dart';
import '../../widgets/chat/select_widgets.dart';
import '../../widgets/find/menu_widgets.dart';

import '../../widgets/ui/open_cn_button.dart';
import '../../widgets/ui/open_cn_text_field.dart';

class CreateImages extends StatefulWidget {
  static const String path = "/create/images";

  const CreateImages({super.key, this.arguments});

  final Map? arguments;

  @override
  State<CreateImages> createState() => _CreateImagesState();
}

class _CreateImagesState extends State<CreateImages> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _desController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _nController = TextEditingController();

  String? modelVal;
  String? sizeVal;
  String? rfVal;
  String? styleVal;

  late Chat? _chat = Chat();

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
        _chat = chat;
        modelVal = chat.model;
        sizeVal = chat.size;
        styleVal = chat.style;
        _nameController.text = chat.name!;
        _desController.text = chat.des!;
        _keyController.text = chat.apiKey!;
        _nController.text = chat.n!;
      });
    }
  }

  void _getSelectModel(val) {
    modelVal = val;
  }

  void _getSelectStyleVal(val) {
    styleVal = val;
  }

  void _getSelectSizeVal(val) {
    sizeVal = val;
  }

  void _getSelectRfVal(val) {
    rfVal = val;
  }

  void pop(BuildContext context) async {
    if (modelVal == null) {
      CommonUtils.showToast('请选择model');
      return;
    }

    Chat chat = Chat();
    chat.type = MenuItems.images.text;
    chat.name = _nameController.text.isEmpty
        ? MenuItems.images.text
        : _nameController.text;
    chat.des = _desController.text.isEmpty ? '图片创作助手' : _desController.text;
    chat.model = modelVal;
    chat.apiKey = _keyController.text;
    chat.n = _nController.text.isEmpty ? '1' : _nController.text;
    chat.size = sizeVal;
    chat.style = styleVal;
    chat.createTime = DateTime.now().millisecondsSinceEpoch;
    chat.messageSize = '0';
    chat.responseFormat = rfVal;

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
    _nController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var gm = S.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create Images', style: TextStyle(fontSize: 16)),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context)),
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
                      SelectWidgets(
                        hint: 'Select Your Model',
                        valid: 'Please select model.',
                        dropdownItems: ChatUtil.models,
                        value: _chat?.model,
                        onChanged: (val) => _getSelectModel(val),
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
                        hintText: '描述（des）,例如：图片创作助手',
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
                      const Text('返回结果数量'),
                      const SizedBox(height: 10),
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
                      const Text('size（size）'),
                      const SizedBox(height: 10),
                      SelectWidgets(
                        hint: 'Select Image Size',
                        valid: 'Please select image size.',
                        dropdownItems: ChatUtil.size,
                        value: _chat?.size,
                        onChanged: (val) => _getSelectSizeVal(val),
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
                      const Text('style（style）'),
                      const SizedBox(height: 10),
                      SelectWidgets(
                        hint: 'Select Image Style',
                        valid: 'Please select image style.',
                        dropdownItems: ChatUtil.style,
                        value: _chat?.style,
                        onChanged: (val) => _getSelectStyleVal(val),
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
                      const Text('response_format'),
                      const SizedBox(height: 10),
                      SelectWidgets(
                        hint: 'Select Image Response Format',
                        valid: 'Please select image response format.',
                        dropdownItems: ChatUtil.imageFormat,
                        value: _chat?.responseFormat,
                        onChanged: (val) => _getSelectRfVal(val),
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
