import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/db/chat_table.dart';
import 'package:chatgpt_im/db/message_table.dart';
import 'package:chatgpt_im/models/gpt/chat.dart';
import 'package:chatgpt_im/models/gpt/message.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  final ScrollController _scrollController = ScrollController();
  late final Chat _chat;
  late String imageUrl = '';
  final List<dynamic> messages = List.of([], growable: true);

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

  void send(val) async {
    if (_textController.text.isEmpty) {
      return;
    }
    try {

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(_chat.des!),
        ],
        role: OpenAIChatMessageRole.system,
      );

      List<OpenAIChatCompletionChoiceMessageContentItemModel>? list = [];

      list.add(
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              _textController.text
          ),
      );

      if(imageUrl!=''){
        list.add(
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
                imageUrl
            ),
        );
      }

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          ...list,
        ],
        role: OpenAIChatMessageRole.user,
      );

      //保存并显示发送的信息，发起openai请求，生成一条请求信息并显示请求中，接受返回的数据结果，保存返回结果并更新页面显示结果
      Message message = Message(null, _chat.id, '1', _textController.text,
          '200', DateTime
              .now()
              .millisecondsSinceEpoch);

      ///save sqlite
      Message? res = await MessageProvider().insert(message);
      setState(() {
        _textController.text = '';
        messages.add(res);
        jump();
        receive('ImeCallback=ImeOnBackInvokedCallback@139008201', '200');
      });
    } on RequestFailedException catch (e) {
      debugPrint(e.message);
      debugPrint('${e.statusCode}');
      receive(e.message, '${e.statusCode}');
    }
  }

  void receive(String msg, String status) async {
    Message message = Message(null, _chat.id, '2', msg, status,
        DateTime
            .now()
            .millisecondsSinceEpoch);

    ///save sqlite
    Message? res = await MessageProvider().insert(message);
    setState(() {
      messages.add(res);
      jump();
    });
  }

  void jump() {
    Future.delayed(
        const Duration(milliseconds: 500),
            () =>
        {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent)
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
    Size size = MediaQuery
        .of(context)
        .size;
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
          buildMenuAnchor(),
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
                    controller: _scrollController,
                    shrinkWrap: true,
                    padding:
                    const EdgeInsets.only(left: 10, right: 10, bottom: 70),
                    children: [
                      ...messages.map((e) => buildChatMessage(e)),
                    ],
                  ),
                ),
              );
            },
          ),
          buildTextField(),
        ],
      ),
    );
  }

  buildChatMessage(Message message) {
    if (message.type == '1') {
      return userMessage(message);
    } else {
      return chatMessage(message);
    }
  }

  Widget userMessage(Message message) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(message.message!),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  Widget chatMessage(Message message) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            Assets.ic_launcher_48,
          ),
          Flexible(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: mdMessage(message.message!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mdMessage(String? message) {
    return MarkdownBody(
      data: message ?? '',
      selectable: true,
      onTapText: () {},
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
      styleSheet: MarkdownStyleSheet(
        codeblockDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        code: const TextStyle(
            color: Colors.blue, backgroundColor: Colors.transparent),
        p: Theme
            .of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Colors.black),
      ),
    );
  }

  buildTextField() {
    return Positioned(
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
                child: TextField(
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
                ),
              ),
            ),
          ],
        ),
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
          Icons.image,
          color: Colors.grey,
          size: 26,
        ),
      ),
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

  buildMenuAnchor() {
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
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
    );
  }
}
