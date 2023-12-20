import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/db/chat_table.dart';
import 'package:chatgpt_im/db/message_table.dart';
import 'package:chatgpt_im/models/gpt/chat.dart';
import 'package:chatgpt_im/models/gpt/message.dart';
import 'package:chatgpt_im/routes/create/create_assistant.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../common/api.dart';
import '../../common/dio_util.dart';
import '../../generated/l10n.dart';
import '../../models/result.dart';
import '../../states/ChatModel.dart';
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

class _ChatMessageState extends State<ChatMessage> {
  final String filePath = '/chat/';
  final _listenable = IndicatorStateListenable();
  bool _shrinkWrap = false;
  double? _viewportDimension;
  final ImagePicker picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final Chat _chat;
  late String? imageName = '';
  late String? imageUrl = '';
  final List<dynamic> messages = List.of([], growable: true);
  final List<dynamic> sysMessages = List.of([], growable: true);

  int _offset = 1;
  int limit = 20;

  @override
  void initState() {
    super.initState();
    init();
    _listenable.addListener(_onHeaderChange);
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
      OpenAI.apiKey = _chat.apiKey ?? '';
      await findPage(chat.id!, limit, _offset);
      await findLast(chat.id!, chat.size!);
    }
  }

  void updateChatInfo() async {
    Chat? chat = await ChatProvider().get(widget.arguments['id']);
    if (chat != null) {
      setState(() {
        _chat = chat;
      });
      OpenAI.apiKey = _chat.apiKey ?? '';
    }
  }

  Future<void> findPage(int chatId, int limit, int offset) async {
    List<Message> list =
        await MessageProvider().findPage(chatId, limit, offset);
    if (list.isNotEmpty) {
      setState(() {
        messages.addAll(list);
        _offset = _offset + 1;
      });
    }
  }

  Future<void> findLast(int chatId, String size) async {
    List<Message> list = await MessageProvider().findLastBySize(chatId, size);
    if (list.isNotEmpty) {
      sysMessages.clear();
      setState(() {
        sysMessages.addAll(list);
      });
    }
  }

  void _onHeaderChange() {
    final state = _listenable.value;
    if (state != null) {
      final position = state.notifier.position;
      _viewportDimension ??= position.viewportDimension;
      final shrinkWrap = state.notifier.position.maxScrollExtent == 0;
      if (_shrinkWrap != shrinkWrap &&
          _viewportDimension == position.viewportDimension) {
        setState(() {
          _shrinkWrap = shrinkWrap;
        });
      }
    }
  }

  void selectImage() async {
    XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      Result result = await DioUtil().upload(Api.upload, file.path, file.name);
      if (result.code == 200) {
        setState(() {
          imageName = file.name;
          imageUrl = result.data['file_url'];
        });
      } else {
        CommonUtils.showToast(result.message);
      }
    }
  }

  void delete() {
    File file = File(imageUrl!);
    file.delete();
    setState(() {
      imageName = '';
      imageUrl = '';
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _listenable.removeListener(_onHeaderChange);
    super.dispose();
  }

  buildMsg(Message msg) {
    if (msg.type == '1') {
      return OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.message!),
        ],
        role: OpenAIChatMessageRole.assistant,
      );
    } else {
      return OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.message!),
        ],
        role: OpenAIChatMessageRole.user,
      );
    }
  }

  void send() async {
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
            _textController.text),
      );
      if (imageUrl != '') {
        list.add(
          OpenAIChatCompletionChoiceMessageContentItemModel.text(imageUrl!),
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
          imageName, '200', DateTime.now().millisecondsSinceEpoch);
      message.fileType = '2'; //url类型
      message.filePath = imageUrl; //网络url

      ///save sqlite
      Message? res = await MessageProvider().insert(message);
      setState(() {
        _textController.clear();
        imageUrl = '';
        imageName = '';
        messages.insert(0, res);
        jump();
      });

      ///获取历史记录
      List<Message> historyMessage =
          await MessageProvider().findLastBySize(_chat.id!, _chat.size!);

      ///组装请求消息
      final List<OpenAIChatCompletionChoiceMessageModel> requestMessages = [
        systemMessage,
        ...historyMessage.map((msg) => buildMsg(msg)),
        userMessage,
      ];

      // the actual request.
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: _chat.model!,
        responseFormat: {"type": "json_object"},
        seed: int.tryParse(_chat.seed!),
        messages: requestMessages,
        temperature: double.tryParse(_chat.temperature!),
        maxTokens: int.tryParse(_chat.maxToken!),
      );
      receive(chatCompletion.toMap().toString(), '200');
    } on RequestFailedException catch (e) {
      debugPrint(e.message);
      debugPrint('${e.statusCode}');
      receive(e.message, '${e.statusCode}');
    } catch (e) {
      debugPrint(e.toString());
      receive(e.toString(), '500');
    }
  }

  void receive(String msg, String status) async {
    Message message = Message(null, _chat.id, '2', msg, '', status,
        DateTime.now().millisecondsSinceEpoch);

    ///save sqlite
    Message? res = await MessageProvider().insert(message);
    setState(() {
      messages.insert(0, res);
      jump();
    });
  }

  void jump() {
    Future.delayed(const Duration(milliseconds: 100),
        () => PrimaryScrollController.of(context).jumpTo(0));
  }

  void unFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    // 键盘是否是弹起状态,弹出且输入完成时收起键盘
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  void deleteChat(BuildContext context, MenuController controller) async {
    controller.close();
    OkCancelResult result = await showOkCancelAlertDialog(
        context: context, title: '提示', message: '确实删除该会话？');
    if (result.name == 'ok') {
      ///删除会话，清除关联数据
      await ChatProvider().delete(_chat.id!);
      List<Chat> chats = await ChatProvider().findList();
      if (context.mounted) {
        Provider.of<ChatModel>(context, listen: false).setChats = chats;
        Navigator.of(context).pop();
      }
    }
  }

  void updateChat(BuildContext context, MenuController controller) async {
    controller.close();
    Navigator.of(context).pushNamed(CreateAssistant.path,
        arguments: {'id': _chat.id}).then((_) => updateChatInfo());
  }

  @override
  Widget build(BuildContext context) {
    var gm = S.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          buildMenuAnchor(context),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            Consumer<LocaleModel>(
              builder: (BuildContext context, LocaleModel localeModel,
                  Widget? child) {
                return GestureDetector(
                  onTap: () => unFocus(context),
                  child: EasyRefresh(
                    clipBehavior: Clip.none,
                    onRefresh: () {},
                    onLoad: () async {
                      return await findPage(
                          widget.arguments['id'], limit, _offset);
                    },
                    header: ListenerHeader(
                      listenable: _listenable,
                      triggerOffset: 100000,
                      clamping: false,
                    ),
                    footer: BuilderFooter(
                      triggerOffset: 40,
                      clamping: false,
                      position: IndicatorPosition.above,
                      infiniteOffset: null,
                      processedDuration: Duration.zero,
                      builder: (context, state) {
                        return Stack(
                          children: [
                            SizedBox(
                              height: state.offset,
                              width: double.infinity,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                child: LoadingAnimationWidget.stretchedDots(
                                    color: Colors.red, size: 30),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.only(bottom: 70, left: 8, right: 8),
                      child: CustomScrollView(
                        reverse: true,
                        shrinkWrap: _shrinkWrap,
                        clipBehavior: Clip.none,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return buildChatMessage(messages[index]);
                              },
                              childCount: messages.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            buildTextField(),
          ],
        ),
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
          Expanded(
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
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
                              hintStyle:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            style: const TextStyle(fontSize: 14),
                            textInputAction: TextInputAction.send,
                            keyboardType: TextInputType.multiline,
                            onSubmitted: (val) => send(),
                            onEditingComplete: () {},
                          ),
                        ),
                        InkWell(
                          onTap: () => send(),
                          child: Icon(
                            Icons.send,
                            color: Colors.blue.shade300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildFileButton() {
    if (imageUrl != '') {
      return GestureDetector(
        onTap: () => selectImage(),
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: CommonUtils.image(imageUrl, 40, 40, 4, BoxFit.cover),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: () => delete(),
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            )
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => selectImage(),
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

  buildSelectFile() {
    return Visibility(
      visible: imageName != '',
      child: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                imageName!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            GestureDetector(
              onTap: () => delete(),
              child: const Icon(
                Icons.clear,
                color: Colors.red,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildMenuAnchor(BuildContext context) {
    late MenuController menuController;
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        menuController = controller;
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
          onTap: () => deleteChat(context, menuController),
          child: buildMenu('删除会话', Icons.delete_forever),
        ),
        const PopupMenuDivider(),
        GestureDetector(
          onTap: () => updateChat(context, menuController),
          child: buildMenu('更新配置', Icons.settings),
        ),
      ],
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
