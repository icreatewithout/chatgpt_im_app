
import 'package:chatgpt_im/db/chat_table.dart';
import 'package:chatgpt_im/models/gpt/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../states/LocaleModel.dart';

class ChatMessage extends StatefulWidget {
  static const String path = "/gpt/chat";

  const ChatMessage({
    super.key,
    required this.arguments,
  });

  final Map arguments;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

enum SampleItem { itemOne, itemTwo, itemThree }

class _ChatMessageState extends State<ChatMessage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final Chat _chat;

  @override
  void initState() {
    super.initState();
    init();
    _focusNode.addListener(() => setState(() {}));
    _textController.addListener(() {
      setState(() {});
    });
  }

  void init() async {
    Chat? chat = await ChatProvider().get(widget.arguments['id']);
    if (chat != null) {
      setState(() {
        _chat = chat;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  void send(val) {
    if (_textController.text.isEmpty) {
      return;
    }



    setState(() {
      _textController.text = '';
    });
  }

  void unFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    // 键盘是否是弹起状态,弹出且输入完成时收起键盘
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    var gm = S.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.grey.shade100,
        ),
        centerTitle: true,
        title: Text(
          widget.arguments['title'],
          style: const TextStyle(fontSize: 16),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          MenuAnchor(
            builder: (BuildContext context, MenuController controller,
                Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_horiz),
              );
            },
            menuChildren: [
              GestureDetector(
                onTap: () => {},
                child: buildMenu('删除项目', Icons.delete_forever),
              ),
              const PopupMenuDivider(),
              GestureDetector(
                onTap: () => {},
                child: buildMenu('更新配置', Icons.settings),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<LocaleModel>(
            builder:
                (BuildContext context, LocaleModel localeModel, Widget? child) {
              return GestureDetector(
                onTap: () => unFocus(context),
                child: SizedBox(
                  height: double.infinity,
                  child: ListView(
                    children: [
                      Center(
                        child: Text('1'),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildFileButton(),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 42,
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: buildTextField(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildFileButton() {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.file_present_outlined,
          color: Colors.grey,
          size: 26,
        ),
      ),
    );
  }

  buildTextField() {
    return TextField(
      cursorColor: Colors.grey,
      autofocus: false,
      focusNode: _focusNode,
      maxLength: 2000,
      minLines: 1,
      maxLines: 6,
      controller: _textController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        counterText: '',
        hintText: '请输入内容',
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      style: const TextStyle(fontSize: 14),
      textInputAction: TextInputAction.send,
      keyboardType: TextInputType.multiline,
      onSubmitted: (val) => send(val),
      onEditingComplete: () {},
    );
  }

  buildMenu(String name, IconData iconData) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData, color: Colors.grey, size: 18),
          const SizedBox(
            width: 2,
          ),
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
