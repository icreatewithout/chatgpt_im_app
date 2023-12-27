import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:chatgpt_im/db/chat_table.dart';
import 'package:chatgpt_im/routes/create/create_speech.dart';
import 'package:chatgpt_im/states/ChatModel.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../common/assets.dart';
import '../../common/common_utils.dart';
import '../../db/message_table.dart';
import '../../generated/l10n.dart';
import '../../models/gpt/chat.dart';
import '../../models/gpt/message.dart';
import '../../states/LocaleModel.dart';
import '../../widgets/chat/chat_util.dart';

class AudioMessage extends StatefulWidget {
  static const String path = "/gpt/audio";

  const AudioMessage({super.key, required this.arguments});

  final Map arguments;

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage>
    with WidgetsBindingObserver {
  final _listenable = IndicatorStateListenable();
  bool _shrinkWrap = false;
  double? _viewportDimension;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isSending = false;
  late final Chat _chat;
  final List<dynamic> messages = List.of([], growable: true);
  late AudioPlayer _player = AudioPlayer();

  int _offset = 1;
  int limit = 20;

  String _path = '';
  bool isPlay = false;
  int isIndex = -1;

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

  @override
  void dispose() {
    _textController.dispose();
    _listenable.removeListener(_onHeaderChange);
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _player.stop();
    }
  }

  void init() async {
    Chat? chat = await ChatProvider().get(widget.arguments['id']);
    if (chat != null) {
      setState(() {
        _chat = chat;
        _path = '/speech/${chat.id}';
      });
      await findPage(chat.id!, limit, _offset);
    }
  }

  void updateChatInfo() async {
    Chat? chat = await ChatProvider().get(widget.arguments['id']);
    if (chat != null) {
      setState(() {
        _chat = chat;
      });
      OpenAI.apiKey = chat.apiKey ?? '';
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

  void send() async {
    if (_textController.text.isEmpty && isSending) {
      return;
    }
    setState(() {
      isSending = true;
    });
    try {
      OpenAI.apiKey = _chat.apiKey ?? '';

      //保存并显示发送的信息，发起openai请求，生成一条请求信息并显示请求中，接受返回的数据结果，保存返回结果并更新页面显示结果
      Message message = Message(null, _chat.id, '1', _textController.text, '',
          '200', DateTime.now().millisecondsSinceEpoch);

      String input = _textController.text;

      ///save sqlite
      Message? res = await MessageProvider().insert(message);
      setState(() {
        _textController.clear();
        messages.insert(0, res);
        jump();

        ///创建临时消息，状态202
        message = Message(null, _chat.id, '2', '', '', '202',
            DateTime.now().millisecondsSinceEpoch);
        messages.insert(0, message);
      });

      Directory directory = await CommonUtils.getAppDocumentsDir();
      _path = '${directory.path}$_path';
      Directory dir = Directory(_path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // The speech request.
      File speechFile = await OpenAI.instance.audio.createSpeech(
        model: _chat.model ?? 'tts-1',
        input: input,
        voice: _chat.voice ?? 'nova',
        responseFormat: ChatUtil.getAudio(_chat.responseFormat ?? 'mp3'),
        outputDirectory: await Directory(_path).create(),
        outputFileName: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      int sec = await ChatUtil.getDuration(speechFile.path, _player);

      var result = {
        'path': speechFile.path,
        'sec': sec,
        'hms': CommonUtils.hms(sec),
      };

      receive(json.encode(result), '200');
    } on RequestFailedException catch (e) {
      receive(e.message, '${e.statusCode}');
    } catch (e) {
      receive(e.toString(), '500');
    }
  }

  void receive(String msg, String status) async {
    Message message;
    if (status == '200') {
      message = messages[0];
      message.createTime = DateTime.now().millisecondsSinceEpoch;
      message.message = msg;
      message.status = status;
    } else {
      // 出现错误时生成错误信息存储
      message = Message(null, _chat.id, '2', msg, '', status,
          DateTime.now().millisecondsSinceEpoch);
    }

    ///save sqlite
    Message? res = await MessageProvider().insert(message);
    setState(() {
      messages[0] = res;
      isSending = false;
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
    Navigator.of(context).pushNamed(CreateAudio.path,
        arguments: {'id': _chat.id}).then((_) => updateChatInfo());
  }

  void playVoice(String path, int index) async {
    if (isPlay) {
      _player.stop();
      setState(() {
        isPlay = false;
        isIndex = -1;
      });
      return;
    }
    setState(() {
      isPlay = true;
      isIndex = index;
    });
    _player = AudioPlayer();
    await _player.setFilePath(path);
    await _player.play();
    setState(() {
      isPlay = false;
      isIndex = -1;
    });
  }

  void saveFile(String path) {
    File file = File(path);
    ChatUtil.downloadAudio(file);
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
          buildMenuAnchor(),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => unFocus(context),
          child: Stack(
            children: [
              Consumer<LocaleModel>(
                builder: (BuildContext context, LocaleModel localeModel,
                    Widget? child) {
                  return EasyRefresh(
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
                                return buildChatMessage(messages[index], index);
                              },
                              childCount: messages.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              buildTextField(),
            ],
          ),
        ),
      ),
    );
  }

  buildChatMessage(Message message, int index) {
    if (message.type == '1') {
      return userMessage(message);
    } else {
      return chatMessage(message, index);
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

  Widget chatMessage(Message message, int index) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(Assets.ic_launcher_72, width: 46),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: buildChatMessages(message, index),
            ),
          ),
        ],
      ),
    );
  }

  buildChatMessages(Message message, int index) {
    if (message.status != '200') {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6)),
        child: mdMessage(message.status!, message.message!),
      );
    }

    ///创建语音播放组建
    Map<String, dynamic> map = json.decode(message.message!);
    return GestureDetector(
      onTap: () => playVoice(map['path'], index),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                isPlay && index == isIndex
                    ? LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.red, size: 20)
                    : Image.asset(Assets.voice, height: 20, width: 20),
                const SizedBox(width: 8),
                Text(map['hms'] ?? '', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: () => saveFile(map['path']),
                icon: Icon(
                  Icons.download,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget mdMessage(String status, String? message) {
    if (status == '202') {
      return LoadingAnimationWidget.stretchedDots(color: Colors.red, size: 30);
    }
    return MarkdownBody(
      data: message ?? 'Empty message.',
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
        child: Container(
          constraints: const BoxConstraints(minHeight: 42),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                  child: ChatUtil.textField(
                      _textController, _focusNode, '请输入内容', () => send())),
              InkWell(
                  onTap: () => send(),
                  child: Icon(Icons.send, color: Colors.blue.shade300)),
            ],
          ),
        ),
      ),
    );
  }

  buildMenuAnchor() {
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
