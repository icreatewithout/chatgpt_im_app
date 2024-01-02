import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:chatgpt_im/db/chat_table.dart';
import 'package:chatgpt_im/routes/create/create_transcription.dart';
import 'package:chatgpt_im/states/ChatModel.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../common/assets.dart';
import '../../common/common_utils.dart';
import '../../db/message_table.dart';
import '../../generated/l10n.dart';
import '../../models/gpt/chat.dart';
import '../../models/gpt/message.dart';
import '../../states/LocaleModel.dart';
import '../../widgets/chat/chat_util.dart';

class WhisperMessage extends StatefulWidget {
  static const String path = "/gpt/whisper";

  const WhisperMessage({super.key, required this.arguments});

  final Map arguments;

  @override
  State<WhisperMessage> createState() => _WhisperMessageState();
}

class _WhisperMessageState extends State<WhisperMessage>
    with WidgetsBindingObserver {
  final _listenable = IndicatorStateListenable();
  bool _shrinkWrap = false;
  double? _viewportDimension;
  late final Chat _chat;
  final List<dynamic> messages = List.of([], growable: true);
  late AudioPlayer _player = AudioPlayer();
  bool isSending = false;

  int _offset = 1;
  int limit = 20;

  late File? audioFile;
  late String? audioFileName = '';
  String _path = '';
  bool isPlay = false;
  int isIndex = -1;

  @override
  void initState() {
    super.initState();
    init();
    _listenable.addListener(_onHeaderChange);
  }

  @override
  void dispose() {
    _listenable.removeListener(_onHeaderChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  void init() async {
    Chat? chat = await ChatProvider().get(widget.arguments['id']);
    if (chat != null) {
      setState(() {
        _chat = chat;
        _path = '/tt/${chat.id}/';
        audioFile = null;
      });
      await findPage(chat.id!, limit, _offset);
    }
  }

  void updateChatInfo() async {
    Chat? chat = await ChatProvider().get(widget.arguments['id']);
    if (chat != null) {
      debugPrint('${chat.toJson()}');
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

  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        audioFile = file;
        audioFileName = result.files.single.name;
      });
    }
  }

  void delete() {
    setState(() {
      audioFile = null;
    });
  }

  void send() async {
    if (isSending) {
      return;
    }
    setState(() {
      isSending = true;
    });
    try {
      //保存并显示发送的信息，发起openai请求，生成一条请求信息并显示请求中，接受返回的数据结果，保存返回结果并更新页面显示结果
      OpenAI.apiKey = _chat.apiKey ?? '';
      int sec = await ChatUtil.getDuration(audioFile!.path, _player);

      var result = {
        'path': audioFile!.path,
        'sec': sec,
        'hms': CommonUtils.hms(sec),
      };

      Message message = Message(null, _chat.id, '1', json.encode(result), '',
          '200', DateTime.now().millisecondsSinceEpoch);

      ///save sqlite
      Message? res = await MessageProvider().insert(message);
      setState(() {
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

      OpenAIAudioModel transcription =
          await OpenAI.instance.audio.createTranscription(
        file: audioFile!,
        model: _chat.model ?? 'whisper-1',
        responseFormat: ChatUtil.getTT(_chat.responseFormat ?? 'text'),
      );

      receive(json.encode(transcription.toMap()), '200');
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
      audioFile = null;
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

  void deleteChat(BuildContext context, MenuController controller, S s) async {
    controller.close();
    OkCancelResult result = await showOkCancelAlertDialog(
        context: context, title: s.hint, message: s.hintDelChat);
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
    Navigator.of(context).pushNamed(CreateWhisper.path,
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

  late AudioRecorder record;
  String fileName = '';
  bool isRecoding = false;

  void recordVoice() async {
    record = AudioRecorder();
    if (await record.hasPermission()) {
      Directory directory = await CommonUtils.getAppDocumentsDir();
      _path = '${directory.path}$_path';
      Directory dir = Directory(_path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      String fName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      File file = File('$_path$fName');
      if (file.existsSync()) {
        file.createSync(recursive: true);
      }
      setState(() {
        isRecoding = true;
        fileName = fName;
      });
      await record.start(const RecordConfig(), path: file.path);
    }
  }

  void stopRecord() async {
    final path = await record.stop();
    setState(() {
      audioFile = File(path!);
      audioFileName = fileName;
      isRecoding = false;
    });
    record.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
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
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          buildMenuAnchor(s),
        ],
      ),
      body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
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
                        padding: const EdgeInsets.only(
                            bottom: 70, left: 8, right: 8),
                        child: CustomScrollView(
                          reverse: true,
                          shrinkWrap: _shrinkWrap,
                          clipBehavior: Clip.none,
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return buildChatMessage(
                                      messages[index], index);
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
                buildTextField(context, s),
              ],
            ),
          )),
    );
  }

  buildChatMessage(Message message, int index) {
    if (message.type == '1') {
      return userMessage(message, index);
    } else {
      return chatMessage(message);
    }
  }

  Widget userMessage(Message message, int index) {
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: buildAudioMsg(message, index),
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

  buildAudioMsg(Message message, int index) {
    Map<String, dynamic> map = json.decode(message.message!);
    return GestureDetector(
      onTap: () => playVoice(map['path'], index),
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 44),
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
    );
  }

  Widget chatMessage(Message message) {
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
              child: buildChatMessages(message),
            ),
          ),
        ],
      ),
    );
  }

  buildChatMessages(Message message) {
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

    Map<String, dynamic> map = json.decode(message.message!);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
      child: mdMessage('200', map['text']),
    );
  }

  Widget mdMessage(String status, String? message) {
    if (status == '202') {
      return LoadingAnimationWidget.stretchedDots(color: Colors.red, size: 30);
    }
    return MarkdownBody(
      data: message ?? 'Empty message.',
      selectable: true,
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
    );
  }

  buildTextField(BuildContext context, S s) {
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => selectFile(),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 2, bottom: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  audioFile == null
                                      ? s.selectAudioFile
                                      : audioFileName!,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: audioFile != null,
                            child: GestureDetector(
                              onTap: () => delete(),
                              child: const Icon(Icons.close,
                                  color: Colors.grey, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                        onTap: () => send(),
                        child: Icon(Icons.send, color: Colors.blue.shade300)),
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
    if (!isRecoding) {
      return GestureDetector(
        onTap: () => recordVoice(),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.settings_voice,
            color: Colors.blue,
            size: 26,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => stopRecord(),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: LoadingAnimationWidget.beat(color: Colors.red, size: 20),
        ),
      );
    }
  }

  buildMenuAnchor(S s) {
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
          onTap: () => deleteChat(context, menuController, s),
          child: buildMenu(s.delChat, Icons.delete_forever),
        ),
        const PopupMenuDivider(),
        GestureDetector(
          onTap: () => updateChat(context, menuController),
          child: buildMenu(s.updateSetting, Icons.settings),
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
